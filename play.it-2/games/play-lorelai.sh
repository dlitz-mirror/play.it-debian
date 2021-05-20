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
# Lorelai
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210518.4

# Set game-specific variables

GAME_ID='lorelai'
GAME_NAME='Lorelai'

ARCHIVE_BASE_0='setup_lorelai_1.1.0a_(40070).exe'
ARCHIVE_BASE_0_MD5='41931b22bd91c8a61835f1ab5b317b38'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_PART1='setup_lorelai_1.1.0a_(40070)-1.bin'
ARCHIVE_BASE_0_PART1_MD5='3c93e5c60612965bd44ddc2480c57987'
ARCHIVE_BASE_0_PART1_TYPE='innosetup'
ARCHIVE_BASE_0_VERSION='1.1.0a-gog40070'
ARCHIVE_BASE_0_SIZE='11000000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/lorelai'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='lorelai.exe lorelai_data/mono lorelai_data/plugins'

ARCHIVE_GAME_DATA_ASSETS_PATH='.'
ARCHIVE_GAME_DATA_ASSETS_FILES='lorelai_data/sharedassets*.assets*'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='lorelai_data lorelai_icon2.ico ost'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='lorelai.exe'
APP_MAIN_ICON='lorelai_icon2.ico'

PACKAGES_LIST='PKG_BIN PKG_DATA_ASSETS PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_DATA_ASSETS_ID="${PKG_DATA_ID}-sharedassets"
PKG_DATA_ASSETS_DESCRIPTION="${PKG_DATA_DESCRIPTION} - shared assets"
PKG_DATA_DEPS="${PKG_DATA_DEPS} ${PKG_DATA_ASSETS_ID}"

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="${PKG_DATA_ID} wine"

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Use persistent storage for saved games

APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"'
userdata:users/${USER}/AppData/LocalLow/Harvester Games/Lorelai'
DATA_FILES="${DATA_FILES} userdata/*.save"

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
