#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# This software is provided by the copyright holders and contributors "as is"
# and any express or implied warranties, including, but not limited to, the
# implied warranties of merchantability and fitness for a particular purpose
# are disclaimed. In no event shall the copyright holder or contributors be
# liable for any direct, indirect, incidental, special, exemplary, or
# consequential damages (including, but not limited to, procurement of
# substitute goods or services; loss of use, data, or profits; or business
# interruption) however caused and on any theory of liability, whether in
# contract, strict liability, or tort (including negligence or otherwise)
# arising in any way out of the use of this software, even if advised of the
# possibility of such damage.
###

###
# Sherlock Holmes Versus Jack the Ripper
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210411.1

# Set game-specific variables

GAME_ID='sherlock-holmes-versus-jack-the-ripper'
GAME_NAME='Sherlock Holmes Versus Jack the Ripper'

ARCHIVES_LIST='
ARCHIVE_BASE_0'

ARCHIVE_BASE_0='setup_sherlock_holmes_vs_jack_the_ripper_2.0.0.2.exe'
ARCHIVE_BASE_0_MD5='65d2d3ee20a5d4db4017c90701ab91cd'
ARCHIVE_BASE_0_TYPE='rar'
ARCHIVE_BASE_0_PART1='setup_sherlock_holmes_vs_jack_the_ripper_2.0.0.2-1.bin'
ARCHIVE_BASE_0_PART1_MD5='17c054477fe1fe12e79513ae71ff1a5d'
ARCHIVE_BASE_0_PART1_TYPE='rar'
ARCHIVE_BASE_0_PART2='setup_sherlock_holmes_vs_jack_the_ripper_2.0.0.2-2.bin'
ARCHIVE_BASE_0_PART2_MD5='26eebfcd9a171eb3a380876681803597'
ARCHIVE_BASE_0_PART2_TYPE='rar'
ARCHIVE_BASE_0_VERSION='1.0-gog2.0.0.2'
ARCHIVE_BASE_0_SIZE='3200000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/sherlock_holmes_versus_jack_the_ripper'

ARCHIVE_GAME_BIN_PATH='game'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe'

ARCHIVE_GAME0_BIN_PATH='support/app'
ARCHIVE_GAME0_BIN_FILES='user.ini'

ARCHIVE_GAME_L10N_EN_PATH='game'
ARCHIVE_GAME_L10N_EN_FILES='000/en.pak 000/sounds_en.pak'

ARCHIVE_GAME_L10N_FR_PATH='game'
ARCHIVE_GAME_L10N_FR_FILES='000/fr.pak 000/sounds_fr.pak'

ARCHIVE_GAME_DATA_PATH='game'
ARCHIVE_GAME_DATA_FILES='logo data.txt shaders.0050 splash_screen.jpg 000/game.pak 000/sounds.pak 000/texture.pak 000/texture3d.pak'

CONFIG_FILES='*.ini'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='game.exe'
APP_MAIN_ICON='game.exe'

PACKAGES_LIST='PKG_BIN PKG_L10N_EN PKG_L10N_FR PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_L10N_ID="${GAME_ID}-l10n"

PKG_L10N_EN_ID="${PKG_L10N_ID}-en"
PKG_L10N_EN_PROVIDE="$PKG_L10N_ID"
PKG_L10N_EN_DESCRIPTION='English localization'

PKG_L10N_FR_ID="${PKG_L10N_ID}-fr"
PKG_L10N_FR_PROVIDE="$PKG_L10N_ID"
PKG_L10N_FR_DESCRIPTION='French localization'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} ${PKG_L10N_ID} wine"

# Load common functions

target_version='2.12'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
		'/usr/share/play.it'
	do
		if [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
fi
if [ -z "$PLAYIT_LIB2" ]; then
	printf '\n\033[1;31mError:\033[0m\n'
	printf 'libplayit2.sh not found.\n'
	exit 1
fi
# shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

ln --symbolic "$(readlink --canonicalize "$SOURCE_ARCHIVE_PART1")" "$PLAYIT_WORKDIR/$GAME_ID.r00"
ln --symbolic "$(readlink --canonicalize "$SOURCE_ARCHIVE_PART2")" "$PLAYIT_WORKDIR/$GAME_ID.r01"

extract_data_from "$PLAYIT_WORKDIR/$GAME_ID.r00"
prepare_package_layout

# Get icon

###
# TODO
# We should add the ability to pass --language option to wrestool
###
icon_extract_ico_from_exe() {
	[ "$DRY_RUN" -eq 1 ] && return 0
	local destination
	local file
	local options
	file="$1"
	destination="$2"
	[ "$wrestool_id" ] && options="--name=$wrestool_id"
	options="${options} --language=0"
	wrestool --extract --type=14 $options --output="$destination" "$file" 2>/dev/null
}
PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

# Include language-specific configuration file

source_file="${PLAYIT_WORKDIR}/gamedata/game/_loc/en"
destination_file="${PKG_L10N_EN_PATH}${PATH_GAME}/game.ini"
mkdir --parents "$(dirname "$destination_file")"
mv "$source_file" "$destination_file"

source_file="${PLAYIT_WORKDIR}/gamedata/game/_loc/fr"
destination_file="${PKG_L10N_FR_PATH}${PATH_GAME}/game.ini"
mkdir --parents "$(dirname "$destination_file")"
mv "$source_file" "$destination_file"

# Install PhysX in the WINE prefix
# Provided installers can not be used:
# - with PhysX-9.13.0604-SystemSoftware-Legacy.msi, the game fails to load PhysX
# - with PhysX-9.15.0428-SystemSoftware.exe, PhysX installation fails

PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks"
APP_WINETRICKS="${APP_WINETRICKS} physx"

# Store saved games in a persistent path

DATA_DIRS="${DATA_DIRS} ./saves"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Store saved games in a persistent path
saves_path_persistent="$PATH_PREFIX/saves"
for saves_path_prefix in \
	"$WINEPREFIX/drive_c/users/$USER/Application Data/Games/sherlock holmes versus jack the ripper/save" \
	"$WINEPREFIX/drive_c/users/$USER/Application Data/Games/sherlock holmes contre jack l'\''eventreur/save"
do
	if [ ! -h "$saves_path_prefix" ]; then
		if [ -d "$saves_path_prefix" ]; then
			# Migrate existing user data to the persistent path
			mv "$saves_path_prefix"/* "$saves_path_persistent"
			rmdir "$saves_path_prefix"
		fi
		# Create link from prefix to persistent path
		mkdir --parents "$(dirname "$saves_path_prefix")"
		ln --symbolic "$saves_path_persistent" "$saves_path_prefix"
	fi
done'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

case "${LANG%_*}" in
	('fr')
		lang_string='version %s :'
		lang_en='anglaise'
		lang_fr='française'
	;;
	('en'|*)
		lang_string='%s version:'
		lang_en='English'
		lang_fr='French'
	;;
esac
printf '\n'
printf "$lang_string" "$lang_en"
print_instructions 'PKG_L10N_EN' 'PKG_DATA' 'PKG_BIN'
printf "$lang_string" "$lang_fr"
print_instructions 'PKG_L10N_FR' 'PKG_DATA' 'PKG_BIN'

exit 0
