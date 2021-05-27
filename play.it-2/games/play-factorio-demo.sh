#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2018-2021, BetaRays
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
# Factorio (demo)
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210527.2

# Set game-specific variables

GAME_ID='factorio-demo'
GAME_NAME='Factorio (demo)'

ARCHIVE_BASE_0='factorio_demo_x64_0.16.51.tar.xz'
ARCHIVE_BASE_0_MD5='130267c91df0be6c2034b64fb05d389b'
ARCHIVE_BASE_0_TYPE='tar'
ARCHIVE_BASE_0_VERSION='0.16.51-1'
ARCHIVE_BASE_0_SIZE='680000'
ARCHIVE_BASE_0_URL='https://www.factorio.com/download-demo'

ARCHIVE_GAME_BIN_PATH='factorio'
ARCHIVE_GAME_BIN_FILES='bin/x64/factorio'

ARCHIVE_GAME_DATA_PATH='factorio'
ARCHIVE_GAME_DATA_FILES='config-path.cfg data'

CONFIG_FILES='./config-path.cfg'
CONFIG_DIRS='./config'
DATA_FILES='./*.dat ./player-data.json'
DATA_DIRS='./saves ./mods'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='bin/x64/factorio'
APP_MAIN_ICON='data/core/graphics/factorio-icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc glx libxrandr xcursor alsa"

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

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Delete temporary files

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
