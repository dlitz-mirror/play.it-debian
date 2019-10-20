#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2019, Mopi
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
# Among the Sleep
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20191215.2

# Set game-specific variables

GAME_ID='among-the-sleep'
GAME_NAME='Among the Sleep'

ARCHIVE_HUMBLE='Among_the_Sleep_Linux.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/among-the-sleep'
ARCHIVE_HUMBLE_MD5='0d7296eb48bfebeb9a37827ee94bd34c'
ARCHIVE_HUMBLE_VERSION='1.0-humble1'
ARCHIVE_HUMBLE_SIZE='2900000'
ARCHIVE_HUMBLE_TYPE='zip'

ARCHIVE_GAME_BIN32_PATH='.'
ARCHIVE_GAME_BIN32_FILES='./*.x86 ./*_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH='.'
ARCHIVE_GAME_BIN64_FILES='./*.x86_64 ./*_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='./*_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='if ! command -v pulseaudio >/dev/null 2>&1; then
	mkdir --parents libs
	ln --force --symbolic /dev/null libs/libpulse-simple.so.0
	export LD_LIBRARY_PATH="libs:$LD_LIBRARY_PATH"
else
	if [ -e "libs/libpulse-simple.so.0" ]; then
		rm libs/libpulse-simple.so.0
		rmdir --ignore-fail-on-non-empty libs
	fi
	pulseaudio --start
fi'
APP_MAIN_EXE_BIN32='Among the Sleep.x86'
APP_MAIN_EXE_BIN64='Among the Sleep.x86_64'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='Among the Sleep_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glx xcursor glibc libstdc++ libxrandr libudev1"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
