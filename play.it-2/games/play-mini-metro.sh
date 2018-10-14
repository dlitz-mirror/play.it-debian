#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, Solène Huault
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
# Mini Metro
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180926.4

# Set game-specific variables

GAME_ID='mini-metro'
GAME_NAME='Mini Metro'

ARCHIVE_HUMBLE='MiniMetro-release-37a-linux.tar.gz'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/mini-metro'
ARCHIVE_HUMBLE_MD5='879d12ce7255feebf7406f65519112dd'
ARCHIVE_HUMBLE_VERSION='1.37a-humble180913'
ARCHIVE_HUMBLE_SIZE='310000'

ARCHIVE_HUMBLE_OLD2='MiniMetro-release-37-linux.tar.gz'
ARCHIVE_HUMBLE_OLD2_MD5='0ee6efa77a16e7775253334640b6d20a'
ARCHIVE_HUMBLE_OLD2_VERSION='1.37-humble1'
ARCHIVE_HUMBLE_OLD2_SIZE='310000'

ARCHIVE_HUMBLE_OLD1='MiniMetro-release-36b-linux.tar.gz'
ARCHIVE_HUMBLE_OLD1_MD5='5c6b16404cd0c3fc00be295721ec7bdd'
ARCHIVE_HUMBLE_OLD1_VERSION='1.36b-humble180605'
ARCHIVE_HUMBLE_OLD1_SIZE='310000'

ARCHIVE_HUMBLE_OLD0='MiniMetro-gamma35b-linux.tar.gz'
ARCHIVE_HUMBLE_OLD0_MD5='5548397ea5eddd915aa33247a38dad74'
ARCHIVE_HUMBLE_OLD0_VERSION='1.35b-humble1'
ARCHIVE_HUMBLE_OLD0_SIZE='310000'

ARCHIVE_GAME_BIN32_PATH='.'
ARCHIVE_GAME_BIN32_FILES='Mini?Metro.x86 Mini?Metro_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH='.'
ARCHIVE_GAME_BIN64_FILES='Mini?Metro.x86_64 Mini?Metro_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='Mini?Metro_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='export LANG=C'
APP_MAIN_EXE_BIN32='Mini Metro.x86'
APP_MAIN_EXE_BIN64='Mini Metro.x86_64'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='Mini Metro_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ gtk2 glx"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
