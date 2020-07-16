#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Heroes of Might and Magic Ⅳ
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200716.1

# Set game-specific variables

GAME_ID='heroes-of-might-and-magic-4'
GAME_NAME='Heroes of Might and Magic Ⅳ'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_1
ARCHIVE_GOG_FR_1
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0'

ARCHIVE_GOG_EN_1='setup_heroes_of_might_and_magic_4_complete_3.0_(22812).exe'
ARCHIVE_GOG_EN_1_MD5='d5e0a55e2bba4f0ac643ec1fb2ba17cc'
ARCHIVE_GOG_EN_1_TYPE='innosetup1.7'
ARCHIVE_GOG_EN_1_URL='https://www.gog.com/game/heroes_of_might_and_magic_4_complete'
ARCHIVE_GOG_EN_1_VERSION='3.0-gog22812'
ARCHIVE_GOG_EN_1_SIZE='1100000'
ARCHIVE_GOG_EN_1_PART1='setup_heroes_of_might_and_magic_4_complete_3.0_(22812)-1.bin'
ARCHIVE_GOG_EN_1_PART1_MD5='3457ead5c208a3d40498d6e1f08bf588'
ARCHIVE_GOG_EN_1_PART1_TYPE='innosetup1.7'

ARCHIVE_GOG_FR_1='setup_heroes_of_might_and_magic_4_complete_3.0_(french)_(22812).exe'
ARCHIVE_GOG_FR_1_MD5='e15ec7a308ea442bfeeb3410314b39d7'
ARCHIVE_GOG_FR_1_TYPE='innosetup1.7'
ARCHIVE_GOG_FR_1_URL='https://www.gog.com/game/heroes_of_might_and_magic_4_complete'
ARCHIVE_GOG_FR_1_VERSION='3.0-gog22812'
ARCHIVE_GOG_FR_1_SIZE='1100000'
ARCHIVE_GOG_FR_1_PART1='setup_heroes_of_might_and_magic_4_complete_3.0_(french)_(22812)-1.bin'
ARCHIVE_GOG_FR_1_PART1_MD5='7abff7182f6bed3199d2b71cdd60d926'
ARCHIVE_GOG_FR_1_PART1_TYPE='innosetup1.7'

ARCHIVE_GOG_EN_0='setup_homm4_complete_2.0.0.12.exe'
ARCHIVE_GOG_EN_0_MD5='74de66eb408bb2916dd0227781ba96dc'
ARCHIVE_GOG_EN_0_VERSION='3.0-gog2.0.0.12'
ARCHIVE_GOG_EN_0_SIZE='1100000'

ARCHIVE_GOG_FR_0='setup_homm4_complete_french_2.1.0.14.exe'
ARCHIVE_GOG_FR_0_MD5='2af96eb28226e563bbbcd62771f3a319'
ARCHIVE_GOG_FR_0_VERSION='3.0-gog2.1.0.14'
ARCHIVE_GOG_FR_0_SIZE='1100000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.chm *.pdf *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_EN_0='app'
ARCHIVE_DOC_DATA_PATH_GOG_FR_0='app'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.exe binkw32.dll drvmgt.dll mss32.dll mp3dec.asi data/*.dll'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_EN_0='app'
ARCHIVE_GAME_BIN_PATH_GOG_FR_0='app'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='data maps'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_EN_0='app'
ARCHIVE_GAME_DATA_PATH_GOG_FR_0='app'

DATA_DIRS='./games'
DATA_FILES='data/high_scores.dat *.log'

APP_WINETRICKS="vd=\$(xrandr | awk '/\\*/ {print \$1}')"

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='heroes4.exe'
APP_MAIN_ICON='heroes4.exe'

APP_EDITOR_TYPE='wine'
APP_EDITOR_ID="${GAME_ID}_edit"
APP_EDITOR_EXE='campaign_editor.exe'
APP_EDITOR_ICON='campaign_editor.exe'
APP_EDITOR_NAME="$GAME_NAME - campaign editor"

PACKAGES_LIST='PKG_BIN PKG_DATA'

# Arch-independent data — common properties
PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_PROVIDE="$PKG_DATA_ID"
PKG_DATA_DESCRIPTION='data'
# Arch-independent data — English version
PKG_DATA_ID_GOG_EN="${PKG_DATA_ID}-en"
PKG_DATA_DESCRIPTION_GOG_EN="${PKG_DATA_DESCRIPTION} - English version"
# Arch-independent data — French version
PKG_DATA_ID_GOG_FR="${PKG_DATA_ID}-fr"
PKG_DATA_DESCRIPTION_GOG_FR="${PKG_DATA_DESCRIPTION} - French version"

# Binaries — common properties
PKG_BIN_ARCH='32'
PKG_BIN_ID="$GAME_ID"
PKG_BIN_PROVIDE="$PKG_BIN_ID"
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks xrandr"
# Binaries — English version
PKG_BIN_ID_GOG_EN="${PKG_BIN_ID}-en"
PKG_BIN_DESCRIPTION_GOG_EN='English version'
# Binaries — French version
PKG_BIN_ID_GOG_FR="${PKG_BIN_ID}-fr"
PKG_BIN_DESCRIPTION_GOG_FR='French version'

# Load common functions

target_version='2.11'

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

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_EDITOR'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_EDITOR'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
