#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, BetaRays
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
# Element4l
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190210.1

# Set game-specific variables

GAME_ID='element4l'
GAME_NAME='Element4l'

ARCHIVE_PLAYISM='Element4l-WIN-1.2.3.zip'
ARCHIVE_PLAYISM_URL='https://playism.com/product/element4l'
ARCHIVE_PLAYISM_MD5='04f761ddf4e9e9b14cad67ae32c1598e'
ARCHIVE_PLAYISM_SIZE='320000'
ARCHIVE_PLAYISM_VERSION='1.2.3-playism'
ARCHIVE_PLAYISM_TYPE='zip'

ARCHIVE_GAME_BIN_PATH='Update-1.2.3-WIN'
ARCHIVE_GAME_BIN_FILES='element4l.exe element4l_Data/Mono element4l_Data/Managed'

ARCHIVE_GAME_DATA_PATH='Update-1.2.3-WIN'
ARCHIVE_GAME_DATA_FILES='element4l_Data/Resources element4l_Data/level* element4l_Data/*.assets element4l_Data/sharedassets* element4l_Data/mainData element4l_Data/hints element4l_Data/replays'

DATA_DIRS='./logs'
DATA_FILES='./game_data.reg'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='element4l.exe'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='element4l.exe'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='
if [ -f "$WINEPREFIX/drive_c/$GAME_ID/game_data.reg" ]; then
	regedit "C:\\\\$GAME_ID\\\\game_data.reg"
fi'
# shellcheck disable=SC2016
APP_MAIN_POSTRUN='regedit -E "C:\\\\$GAME_ID\\\\game_data.reg" HKEY_CURRENT_USER\\\\Software\\\\I-Illusions\\\\element4l'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine alsa glx"

# Load common functions

target_version='2.11'

if [ -z "$PLAYIT_LIB2" ]; then
	: "${XDG_DATA_HOME:="$HOME/.local/share"}"
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
# shellcheck source=play.it-2/lib/libplayit2.sh
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
launcher_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
