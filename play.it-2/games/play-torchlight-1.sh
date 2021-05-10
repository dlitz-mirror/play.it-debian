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
# Torchlight
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210511.2

# Set game-specific variables

GAME_ID='torchlight-1'
GAME_NAME='Torchlight'

ARCHIVE_BASE_1='setup_torchlight_1.15(a)_(23675).exe'
ARCHIVE_BASE_1_MD5='a29e51f55aae740f4046d227d33fa64b'
ARCHIVE_BASE_1_TYPE='innosetup'
ARCHIVE_BASE_1_VERSION='1.15-gog23675'
ARCHIVE_BASE_1_SIZE='460000'
ARCHIVE_BASE_1_URL='https://www.gog.com/game/torchlight'

ARCHIVE_BASE_0='setup_torchlight_2.0.0.12.exe'
ARCHIVE_BASE_0_MD5='4b721e1b3da90f170d66f42e60a3fece'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_VERSION='1.15-gog2.0.0.12'
ARCHIVE_BASE_0_SIZE='460000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.pdf'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='torchlight.exe *.cfg *.dll'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='buildver.txt runicgames.ico torchlight.ico logo.bmp pak.zip icons music programs'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='torchlight.exe'
APP_MAIN_ICON='torchlight.ico'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine xcursor glx"

# Use persistent storage for user data

APP_WINE_LINK_DIRS='userdata:users/${USER}/Application Data/runic games/torchlight'
CONFIG_FILES="${CONFIG_FILES} ./userdata/local_settings.txt ./userdata/settings.txt"
DATA_DIRS="${DATA_DIRS} ./userdata/save"

# Keep compatibility with old archives

ARCHIVE_DOC_DATA_PATH_0='app'
ARCHIVE_GAME_BIN_PATH_0='app'
ARCHIVE_GAME_DATA_PATH_0='app'

# Easier upgrade from packages generated with pre-20181021.2 scripts

PKG_DATA_PROVIDE='torchlight-data'
PKG_BIN_PROVIDE='torchlight'

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

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
