#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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
# Far From Noise
# build native Linux packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200926.2

# Set game-specific variables

GAME_ID='far-from-noise'
GAME_NAME='Far From Noise'

ARCHIVE_ITCH='Windows.zip'
ARCHIVE_ITCH_URL='https://georgebatch.itch.io/far-from-noise'
ARCHIVE_ITCH_MD5='7861db608070316a1a329fb140d90b8f'
ARCHIVE_ITCH_SIZE='300000'
ARCHIVE_ITCH_VERSION='1.0-itch1'

ARCHIVE_GAME_BIN_PATH='Windows'
ARCHIVE_GAME_BIN_FILES='FarFromNoise.exe FarFromNoise_Data/Plugins FarFromNoise_Data/Mono FarFromNoise_Data/Managed'

ARCHIVE_GAME_DATA_PATH='Windows'
ARCHIVE_GAME_DATA_FILES='FarFromNoise_Data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='FarFromNoise.exe'
APP_MAIN_ICON='FarFromNoise.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine glx"

# Use persistent storage for saved games and settings

DATA_DIRS="$CONFIG_DIRS ./registry-dumps"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Set path for persistent dump of saved games and settings
registry_dump_persistent="registry-dumps/persistent.reg"'
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'
# Dump saved games and settings
regedit -E "$registry_dump_persistent" "HKEY_CURRENT_USER\Software\George Batchelor\Far from Noise"'
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Load dump of saved games and settings
if [ -e "$registry_dump_persistent" ]; then
	regedit "$registry_dump_persistent"
fi'

# Load common functions

target_version='2.12'

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

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

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
