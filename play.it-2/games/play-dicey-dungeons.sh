#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2018-2021, ahub
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

script_version=20210413.2

# Set game-specific variables

GAME_ID='dicey-dungeons'
GAME_NAME='Dicey Dungeons'

ARCHIVES_LIST='
ARCHIVE_BASE_1
ARCHIVE_BASE_0'

ARCHIVE_BASE_1='dicey-dungeons-linux64.zip'
ARCHIVE_BASE_1_MD5='7561697f602e3a0af054569e3a8114b3'
ARCHIVE_BASE_1_SIZE='110000'
ARCHIVE_BASE_1_VERSION='1.11-itch.2021.03.18'
ARCHIVE_BASE_1_URL='https://terrycavanagh.itch.io/dicey-dungeons'

ARCHIVE_BASE_0='dicey-dungeons-linux64.zip'
ARCHIVE_BASE_0_MD5='14879aa94aef2291d6aec0c4c9e760c5'
ARCHIVE_BASE_0_SIZE='450000'
ARCHIVE_BASE_0_VERSION='1.10-itch.2020.11.05'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='diceydungeons lime.ndll'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='data manifest mods soundstuff'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='diceydungeons'
APP_MAIN_ICON='data/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ sdl2 sdl2_mixer"

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Build 512×512 icon from the 1024×1024 provided one
# 1024×1024 is too big for some desktop environments to use the provided icon

PATH_ICON="${PATH_ICON_BASE}/512x512/apps"
mkdir --parents "${PKG_DATA_PATH}${PATH_ICON}"
convert "${PKG_DATA_PATH}${PATH_GAME}/${APP_MAIN_ICON}" -resize 512 "${PKG_DATA_PATH}${PATH_ICON}/${GAME_ID}.png"

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
