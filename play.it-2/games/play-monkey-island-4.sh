#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c)      2020, macaron
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
# Monkey Island 4: Escape from Monkey Island
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201016.1

# Set game-specific variables

GAME_ID='monkey-island-4'
GAME_NAME='Monkey Island 4: Escape from Monkey Island'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0'

ARCHIVE_GOG_EN_0='setup_escape_from_monkey_islandtm_1.1_(20987).exe'
ARCHIVE_GOG_EN_0_MD5='54978965b60294d5c1639b71c0a8159a'
ARCHIVE_GOG_EN_0_URL='https://www.gog.com/game/escape_from_monkey_island'
ARCHIVE_GOG_EN_0_VERSION='1.1-gog20987'
ARCHIVE_GOG_EN_0_SIZE='1300000'
ARCHIVE_GOG_EN_0_PART1='setup_escape_from_monkey_islandtm_1.1_(20987)-1.bin'
ARCHIVE_GOG_EN_0_PART1_MD5='21bc4e362f73b76e6808649167ee9d20'
ARCHIVE_GOG_EN_0_PART1_TYPE='innosetup'

ARCHIVE_GOG_FR_0='setup_escape_from_monkey_islandtm_1.1_(french)_(20987).exe'
ARCHIVE_GOG_FR_0_MD5='5ca039d42d53ad7fe206b289abe15deb'
ARCHIVE_GOG_FR_0_URL='https://www.gog.com/game/escape_from_monkey_island'
ARCHIVE_GOG_FR_0_VERSION='1.1-gog20987'
ARCHIVE_GOG_FR_0_SIZE='1300000'
ARCHIVE_GOG_FR_0_PART1='setup_escape_from_monkey_islandtm_1.1_(french)_(20987)-1.bin'
ARCHIVE_GOG_FR_0_PART1_MD5='c5bf233f09cca2a8e33d78d25cf58329'
ARCHIVE_GOG_FR_0_PART1_TYPE='innosetup'

ARCHIVE_RESIDUALVM_PATCH_EN='MonkeyUpdate.exe'
ARCHIVE_RESIDUALVM_PATCH_EN_URL='https://www.residualvm.org/downloads/#extras'
ARCHIVE_RESIDUALVM_PATCH_EN_MD5='7c7dbd2349d49e382a2dea40bed448e0'
ARCHIVE_RESIDUALVM_PATCH_EN_TYPE='file'

ARCHIVE_RESIDUALVM_PATCH_FR='MonkeyUpdate_FRA.exe'
ARCHIVE_RESIDUALVM_PATCH_FR_URL='https://www.residualvm.org/downloads/#extras'
ARCHIVE_RESIDUALVM_PATCH_FR_MD5='cc5ff3bb8f78a0eb4b8e0feb9cdd2e87'
ARCHIVE_RESIDUALVM_PATCH_FR_TYPE='file'

ARCHIVE_DOC_L10N_PATH='.'
ARCHIVE_DOC_L10N_FILES='*.pdf *.txt'

ARCHIVE_GAME0_BIN_WINE_PATH='.'
ARCHIVE_GAME0_BIN_WINE_FILES='*.asi *.dll *.exe *.flt'

ARCHIVE_GAME1_BIN_WINE_PATH='__support/save'
ARCHIVE_GAME1_BIN_WINE_FILES='saves'

ARCHIVE_GAME_BIN_RESIDUALVM_PATH='.'
ARCHIVE_GAME_BIN_RESIDUALVM_FILES='MonkeyUpdate*.exe'

ARCHIVE_GAME_L10N_PATH='.'
ARCHIVE_GAME_L10N_FILES='movies art???.m4b i9n.m4b lip.m4b voice???.m4b'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='textures local.m4b patch.m4b sfx.m4b'

CONFIG_FILES='saves/efmi.cfg'
DATA_FILES='saves/efmi*.gsv'

APP_REGEDIT='install.reg'

APP_WINE_TYPE='wine'
APP_WINE_EXE='monkey4.exe'
APP_WINE_ICON='monkey4.exe' # This icon is actually shared for both WINE and ResidualVM launchers

APP_RESIDUALVM_TYPE='residualvm'
APP_RESIDUALVM_RESIDUALID='monkey4'

PACKAGES_LIST='PKG_BIN_WINE PKG_L10N PKG_DATA'
PACKAGES_LIST_RESIDUALVM="PKG_BIN_RESIDUALVM $PACKAGES_LIST"

# architecture-independent common data package
PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

# localization package — common properties
PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"

# localization package — English version
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'

# localization package — French version
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

# binaries packages — common properties
PKG_BIN_ID="$GAME_ID"

# binaries package — WINE — common properties
PKG_BIN_WINE_ID="${PKG_BIN_ID}-wine"
PKG_BIN_WINE_PROVIDE="$PKG_BIN_ID"
PKG_BIN_WINE_ARCH='32'
PKG_BIN_WINE_DEPS="$PKG_DATA_ID $PKG_L10N_ID wine"

# binaries package — WINE — English version
PKG_BIN_WINE_ID_GOG_EN="${PKG_BIN_WINE_ID}-en"
PKG_BIN_WINE_DESCRIPTION_GOG_EN='English version'

# binaries package — WINE — French version
PKG_BIN_WINE_ID_GOG_FR="${PKG_BIN_WINE_ID}-fr"
PKG_BIN_WINE_DESCRIPTION_GOG_FR='French version'

# binaries package — ResidualVM
PKG_BIN_RESIDUALVM_ID="${PKG_BIN_ID}-residualvm"
PKG_BIN_RESIDUALVM_PROVIDE="$PKG_BIN_ID"
PKG_BIN_RESIDUALVM_DEPS="$PKG_DATA_ID residualvm"

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

# Check presence of patch required by ResidualVM

###
# TODO
# A warning should be displayed if the patch required for ResidualVM support is missing
###
ARCHIVE_MAIN="$ARCHIVE"
case "$ARCHIVE_MAIN" in
	('ARCHIVE_GOG_EN'*)
		ARCHIVE_PATCH='ARCHIVE_RESIDUALVM_PATCH_EN'
	;;
	('ARCHIVE_GOG_FR'*)
		ARCHIVE_PATCH='ARCHIVE_RESIDUALVM_PATCH_FR'
	;;
esac
archive_set 'ARCHIVE_RESIDUALVM_PATCH' "$ARCHIVE_PATCH"
if [ -n "$ARCHIVE_RESIDUALVM_PATCH" ]; then
	PACKAGES_LIST="$PACKAGES_LIST_RESIDUALVM"
	# shellcheck disable=SC2086
	set_temp_directories $PACKAGES_LIST
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
if [ -n "$ARCHIVE_RESIDUALVM_PATCH" ]; then
	cp "$ARCHIVE_RESIDUALVM_PATCH" "$PLAYIT_WORKDIR/gamedata"
	prepare_package_layout 'PKG_BIN_RESIDUALVM'
fi

# Extract icons

PKG='PKG_BIN_WINE'
icons_get_from_package 'APP_WINE'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Register install path

cat > "${PKG_BIN_WINE_PATH}${PATH_GAME}/install.reg" << EOF
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\\Software\\LucasArts Entertainment Company LLC\\Monkey4\\Retail]
"Install Path"="C:\\\\$GAME_ID"
EOF

# Write launchers

PKG='PKG_BIN_WINE'
launchers_write 'APP_WINE'

if [ -n "$ARCHIVE_RESIDUALVM_PATCH" ]; then
	PKG='PKG_BIN_RESIDUALVM'
	launchers_write 'APP_RESIDUALVM'
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

printf '\n'
if [ -n "$ARCHIVE_RESIDUALVM_PATCH" ]; then
	printf 'ResidualVM:'
	print_instructions 'PKG_DATA' 'PKG_L10N' 'PKG_BIN_RESIDUALVM'
fi
printf 'WINE:'
print_instructions 'PKG_DATA' 'PKG_L10N' 'PKG_BIN_WINE'

exit 0
