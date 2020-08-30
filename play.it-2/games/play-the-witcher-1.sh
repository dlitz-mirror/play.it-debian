#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, BetaRays
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
# The Witcher: Enhanced Edition
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200830.15

# Set game-specific variables

GAME_ID='the-witcher-1'
GAME_NAME='The Witcher'

# unix2dos (provided by dos2unix) is used to generate a .reg file
SCRIPT_DEPS='dos2unix'

ARCHIVE_GOG='setup_the_witcher_enhanced_edition_1.5_(a)_(10712).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_witcher'
ARCHIVE_GOG_MD5='2440cfb5fb4890ff4b9bc4b88b434d38'
ARCHIVE_GOG_VERSION='1.5.726-gog10712'
ARCHIVE_GOG_SIZE='15000000'
ARCHIVE_GOG_PART1='setup_the_witcher_enhanced_edition_1.5_(a)_(10712)-1.bin'
ARCHIVE_GOG_PART1_MD5='e530a1a2e86094740b45a14f63260804'
ARCHIVE_GOG_PART1_TYPE='innosetup'
ARCHIVE_GOG_PART2='setup_the_witcher_enhanced_edition_1.5_(a)_(10712)-2.bin'
ARCHIVE_GOG_PART2_MD5='fb3a478bcb6e4702e1e8d392cb55391d'
ARCHIVE_GOG_PART2_TYPE='innosetup'
ARCHIVE_GOG_PART3='setup_the_witcher_enhanced_edition_1.5_(a)_(10712)-3.bin'
ARCHIVE_GOG_PART3_MD5='2df8369af401815a736f5d88f85fbf8d'
ARCHIVE_GOG_PART3_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='manual.pdf readme.rtf release.txt'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.exe installed thewitchergdf.dll launcher register system'

ARCHIVE_GAME_VOICES_PATH='app'
ARCHIVE_GAME_VOICES_FILES='data/voices_*.bif'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='data'

ARCHIVE_ADDONS_PATH='app/__support/add/the witcher'
ARCHIVE_ADDONS_FILES='*'

# Fix texture issues
# cf. https://bugs.winehq.org/show_bug.cgi?id=46553
APP_WINETRICKS='d3dx9_35'

APP_MAIN_TYPE='wine'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Include "Enhanced Edition" add-ons
if [ ! -e "$WINEPREFIX/drive_c/users/Public/Documents/the witcher" ]; then
	mkdir --parents "$WINEPREFIX/drive_c/users/Public/Documents/the witcher"
	ln --symbolic "$PATH_GAME"/addons/* "$WINEPREFIX/drive_c/users/Public/Documents/the witcher"
fi'
APP_MAIN_EXE='system/witcher.exe'
APP_MAIN_ICON='system/witcher.exe'

PACKAGES_LIST='PKG_BIN PKG_VOICES PKG_DATA'

PKG_VOICES_ID="${GAME_ID}-voices"
PKG_VOICES_DESCRIPTION='voices'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DEPS="$PKG_VOICES_ID"

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks glx xcursor"

# Use persistent storage for game settings and key bindings

CONFIG_DIRS="$CONFIG_DIRS ./registry-dumps"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Set path for persistent dumps of game settings and key bindings
registry_dump_settings="registry-dumps/settings.reg"
registry_dump_bindings="registry-dumps/bindings.reg"'
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'
# Dump game settings and key bindings
regedit -E "$registry_dump_settings" "HKEY_CURRENT_USER\Software\CD Projekt RED\Witcher\Settings"
regedit -E "$registry_dump_bindings" "HKEY_CURRENT_USER\Software\CD Projekt RED\Witcher\Bindings"'
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Load dumps of game settings and key bindings
for registry_dump in \
	"$registry_dump_settings" \
	"$registry_dump_bindings"
do
	if [ -e "$registry_dump" ]; then
		regedit "$registry_dump"
	fi
done'

# Store saved games in persistent paths

DATA_DIRS="$DATA_DIRS ./saves"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store saved games in persistent paths
saves_path_prefix="$WINEPREFIX/drive_c/users/$USER/My Documents/The Witcher/saves"
saves_path_persistent="$PATH_PREFIX/saves"
if [ ! -h "$saves_path_prefix" ]; then
	if [ -d "$saves_path_prefix" ]; then
		# Migrate existing saves to the persistent path
		mv "$saves_path_prefix"/* "$saves_path_persistent"
		rmdir "$saves_path_prefix"
	fi
	# Create link from prefix to persistent path
	mkdir --parents "$(dirname "$saves_path_prefix")"
	ln --symbolic "$saves_path_persistent" "$saves_path_prefix"
fi'

# Load common functions

target_version='2.12'

if [ -z "$PLAYIT_LIB2" ]; then
	: "${XDG_DATA_HOME:="$HOME/.local/share"}"
	for path in\
		"$PWD"\
		"$XDG_DATA_HOME/play.it"\
		'/usr/local/share/games/play.it'\
		'/usr/local/share/play.it'\
		'/usr/share/games/play.it'\
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

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Include "Enhanced Edition" add-ons

PKG='PKG_DATA'
organize_data 'ADDONS' "$PATH_GAME/addons"
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Set up required registry keys

registry_dump="${PKG_BIN_PATH}${PATH_GAME}/${APP_REGEDIT:=init.reg}"

cat > "$registry_dump" << EOF
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\\Software\\CD Projekt Red\\The Witcher]
"InstallFolder"="C:\\\\${GAME_ID}\\\\"
"IsDjinniInstalled"=dword:00000001
"Language"="3"
"RegionVersion"="WE"
EOF

# Work around invisible models and flickering
# cf. https://bugs.winehq.org/show_bug.cgi?id=34052

cat >> "$registry_dump" << 'EOF'

[HKEY_CURRENT_USER\Software\Wine\Direct3D]
"CheckFloatConstants"="enabled"
EOF

unix2dos "$registry_dump" 2>/dev/null

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
