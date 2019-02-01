#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
# Copyright (c) 2018-2019, Solène Huault
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
# Inner Space
# build native packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20190113.1

# Set game-specific variables

GAME_ID='inner-space'
GAME_NAME='Inner Space'

ARCHIVE_HUMBLE='InnerSpace_v1.2_Linux.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/innerspace'
ARCHIVE_HUMBLE_MD5='10f0c5247a1404f9f40ee8cd01ab9b66'
ARCHIVE_HUMBLE_SIZE='2000000'
ARCHIVE_HUMBLE_VERSION='1.2-humble180610'
ARCHIVE_HUMBLE_TYPE='zip'

ARCHIVE_GAME_BIN_PATH='IS_180416_01_LIN_DRMFREE'
ARCHIVE_GAME_BIN_FILES='InnerSpace.x86_64 InnerSpace_Data/*/x86'

ARCHIVE_GAME_DATA_PATH='IS_180416_01_LIN_DRMFREE'
ARCHIVE_GAME_DATA_FILES='InnerSpace_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
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
fi
export LANG=C'
APP_MAIN_EXE='InnerSpace.x86_64'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='InnerSpace_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++"

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

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
