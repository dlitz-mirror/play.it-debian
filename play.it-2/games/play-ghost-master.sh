#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Ghost Master
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210529.5

# Set game-specific variables

GAME_ID='ghost-master'
GAME_NAME='Ghost Master'

ARCHIVE_BASE_1='setup_ghost_master_20171020_(15806).exe'
ARCHIVE_BASE_1_MD5='bbc7b8d6ed9b08c54cba6f2b1048a0fd'
ARCHIVE_BASE_1_TYPE='innosetup'
ARCHIVE_BASE_1_SIZE='680000'
ARCHIVE_BASE_1_VERSION='1.1-gog15806'
ARCHIVE_BASE_1_URL='https://www.gog.com/game/ghost_master'

ARCHIVE_BASE_0='setup_ghost_master_2.0.0.3.exe'
ARCHIVE_BASE_0_MD5='f581e0e08d7d9dfc89838c3ac892611a'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_SIZE='650000'
ARCHIVE_BASE_0_VERSION='1.1-gog2.0.0.3'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='*.pdf *.txt'

ARCHIVE_GAME_BIN_PATH='app/ghostdata'
ARCHIVE_GAME_BIN_FILES='*.cfg *.dll *.exe'

ARCHIVE_GAME_DATA_PATH='app/ghostdata'
ARCHIVE_GAME_DATA_FILES='*.txt characters cursors fonts icons levels movies music new_animations otherobjects psparams pstextures scenarios screenshots scripts sound text ui voice'

CONFIG_FILES='./*.cfg'
DATA_DIRS='./screenshots'
DATA_FILES='./*.log'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='ghost.exe'
APP_MAIN_ICON='ghost.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine glx"

# Load common functions

target_version='2.13'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
		'/usr/share/play.it'
	do
		if [ -e "${path}/libplayit2.sh" ]; then
			PLAYIT_LIB2="${path}/libplayit2.sh"
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

# Get game icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Use persistent storage for saved games

APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"'
savegames:users/Public/Documents/Ghost Master/SaveGames'
DATA_DIRS="${DATA_DIRS} ./savegames"

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
