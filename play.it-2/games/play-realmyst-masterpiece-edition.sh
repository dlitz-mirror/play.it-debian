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
# realMyst: Masterpiece Edition
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210511.3

# Set game-specific variables

GAME_ID='realmyst-masterpiece-edition'
GAME_NAME='realMyst: Masterpiece Edition'

ARCHIVE_BASE_0='setup_real_myst_masterpiece_edition_2.2_rev_10535_(64bit)_(23829).exe'
ARCHIVE_BASE_0_MD5='fcb23e0256ab826e9a2ba9cad00d9a66'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_PART1='setup_real_myst_masterpiece_edition_2.2_rev_10535_(64bit)_(23829)-1.bin'
ARCHIVE_BASE_0_PART1_MD5='038b24ec51a18b325574293d7f2d0ec2'
ARCHIVE_BASE_0_PART1_TYPE='innosetup'
ARCHIVE_BASE_0_VERSION='2.2.10535-gog23829'
ARCHIVE_BASE_0_SIZE='2800000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/real_myst_masterpiece_edition'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='realmyst.exe realmyst_data/mono'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='realmyst_data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='realmyst.exe'
APP_MAIN_ICON='realmyst.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="${PKG_DATA_ID} wine glx"

# Use persistent storage for user data

CONFIG_FILES="${DATA_FILES} ./userdata/*.ini"
DATA_FILES="${DATA_DIRS} ./userdata/*.sav ./userdata/*.png"
APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"'
userdata:users/${USER}/AppData/LocalLow/Cyan Worlds/realMyst'

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

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

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
