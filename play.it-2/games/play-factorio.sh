#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2017-2021, HS-157
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
# Factorio
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210320.3

# Set game-specific variables

GAME_ID='factorio'
GAME_NAME='Factorio'

ARCHIVES_LIST='
ARCHIVE_OFFICIAL_2
ARCHIVE_OFFICIAL_1
ARCHIVE_OFFICIAL_0'

ARCHIVE_OFFICIAL_2='factorio_alpha_x64_1.1.27.tar.xz'
ARCHIVE_OFFICIAL_2_MD5='71c370e0363c40e95f0a9af56b8f4a9b'
ARCHIVE_OFFICIAL_2_TYPE='tar'
ARCHIVE_OFFICIAL_2_SIZE='1800000'
ARCHIVE_OFFICIAL_2_VERSION='1.1.27-official1'
ARCHIVE_OFFICIAL_2_URL='https://www.factorio.com/'

ARCHIVE_OFFICIAL_1='factorio_alpha_x64_1.1.19.tar.xz'
ARCHIVE_OFFICIAL_1_MD5='ffe7310259e6176d20fc4add10d8a3d3'
ARCHIVE_OFFICIAL_1_TYPE='tar'
ARCHIVE_OFFICIAL_1_SIZE='1800000'
ARCHIVE_OFFICIAL_1_VERSION='1.1.19-official1'

ARCHIVE_OFFICIAL_0='factorio_alpha_x64_1.0.0.tar.xz'
ARCHIVE_OFFICIAL_0_MD5='001910cafbfa8f4ac61b2897f91fe77e'
ARCHIVE_OFFICIAL_0_TYPE='tar'
ARCHIVE_OFFICIAL_0_SIZE='1700000'
ARCHIVE_OFFICIAL_0_VERSION='1.0.0-official1'

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
PKG_BIN_DEPS="$PKG_DATA_ID glibc glx libxrandr xcursor alsa"

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
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
