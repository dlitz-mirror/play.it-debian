#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, Solène Huault
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
# Puzzle Agent
# build native Linux packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20180911.1

# Set game-specific variables

GAME_ID='puzzle-agent'
GAME_NAME='Puzzle Agent'

ARCHIVE_GOG='setup_puzzle_agent_1.0_(21444).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/puzzle_agent'
ARCHIVE_GOG_MD5='b986c9a9ed5bce6f8329cc76965ee295'
ARCHIVE_GOG_SIZE='260000'
ARCHIVE_GOG_VERSION='1.0-gog21444'
ARCHIVE_GOG_TYPE='innosetup1.7'

ARCHIVE_GOG_OLD0='setup_puzzle_agent_2.0.0.3.exe'
ARCHIVE_GOG_OLD0_MD5='68155b4aff9aa9e28c107f5b2ff994b5'
ARCHIVE_GOG_OLD0_SIZE='260000'
ARCHIVE_GOG_OLD0_VERSION='1.0-gog2.0.0.3'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_PATH_GOG_OLD0='app'
ARCHIVE_GAME_BIN_FILES='./fmodex.dll ./grickle101.exe ./steam_api.dll'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_PATH_GOG_OLD0='app'
ARCHIVE_GAME_DATA_FILES='./pack'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='grickle101.exe'
APP_MAIN_ICON='grickle101.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine-staging"

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
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
