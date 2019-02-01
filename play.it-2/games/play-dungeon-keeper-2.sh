#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
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
# Dungeon Keeper 2
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190101.1

# Set game-specific variables

GAME_ID='dungeon-keeper-2'
GAME_NAME='Dungeon Keeper II'

ARCHIVE_GOG='setup_dungeon_keeper_2_1.7_(22280).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/dungeon_keeper_2'
ARCHIVE_GOG_TYPE='innosetup1.7'
ARCHIVE_GOG_MD5='eeb2229ee49518504884a9ac65f611ad'
ARCHIVE_GOG_VERSION='1.7-gog22280'
ARCHIVE_GOG_SIZE='510000'

ARCHIVE_GOG_OLD0='setup_dungeon_keeper2_2.0.0.32.exe'
ARCHIVE_GOG_OLD0_URL='https://www.gog.com/game/dungeon_keeper_2'
ARCHIVE_GOG_OLD0_MD5='92d04f84dd870d9624cd18449d3622a5'
ARCHIVE_GOG_OLD0_VERSION='1.7-gog2.0.0.32'
ARCHIVE_GOG_OLD0_SIZE='510000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.pdf *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_OLD0='app'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='data dk2texturecache'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_OLD0='app'

CONFIG_DIRS='./data/settings'
DATA_DIRS='./data/save'
DATA_FILES='./*.LOG'

APP_WINETRICKS='csmt=off'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='dkii-dx.exe'
APP_MAIN_ICON='dkii.exe'

APP_SOFTWARE_ID="${GAME_ID}_software"
APP_SOFTWARE_TYPE='wine'
APP_SOFTWARE_EXE='dkii.exe'
APP_SOFTWARE_OPTIONS='-softwarefilter -32bitdisplay -disablegamma -shadows 1 -software'
APP_SOFTWARE_NAME="$GAME_NAME (software rendering)"
APP_SOFTWARE_ICON="$APP_MAIN_ICON"

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks"

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	: ${XDG_DATA_HOME:="$HOME/.local/share"}
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
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_SOFTWARE'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN' 'APP_SOFTWARE'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
