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
# Anna's Quest
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210502.2

# Set game-specific variables

GAME_ID='annas-quest'
GAME_NAME='Anna’s Quest'

ARCHIVES_LIST='
ARCHIVE_BASE_0'

ARCHIVE_BASE_0='gog_anna_s_quest_2.1.0.3.sh'
ARCHIVE_BASE_0_MD5='cb4cf167a13413b6df8238397393298a'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='1100000'
ARCHIVE_BASE_0_VERSION='1.0.0202-gog2.1.0.3'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/annas_quest'

ARCHIVE_DOC1_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC1_DATA_FILES='*'

ARCHIVE_DOC2_DATA_PATH='data/noarch/game/documents/licenses'
ARCHIVE_DOC2_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='anna config.ini libs64'

ARCHIVE_GAME_VIDEO_PATH='data/noarch/game'
ARCHIVE_GAME_VIDEO_FILES='videos'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='characters data.vis lua scenes'

CONFIG_FILES='./config.ini'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='anna'
APP_MAIN_LIBS='libs64'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_VIDEO PKG_DATA PKG_BIN'

PKG_VIDEO_ID="${GAME_ID}-videos"
PKG_VIDEO_DESCRIPTION='videos'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS_DEB="${PKG_VIDEO_ID}, ${PKG_DATA_ID}, libgl1-mesa-glx | libgl1, libopenal1"
PKG_BIN_DEPS_ARCH="${PKG_VIDEO_ID} ${PKG_DATA_ID} libgl openal"

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

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get game icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'

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

print_instructions

exit 0
