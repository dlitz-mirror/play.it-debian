#!/bin/sh -e
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
# A Mortician’s Tale
# build native Linux packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20200925.1

# Set game-specific variables

GAME_ID='a-morticians-tale'
GAME_NAME='A Mortician’s Tale'

ARCHIVES_LIST='ARCHIVE_ITCH_32 ARCHIVE_ITCH_64'

ARCHIVE_ITCH_32="A Mortician's Tale - Windows x86.zip"
ARCHIVE_ITCH_32_URL='https://laundrybear.itch.io/morticians-tale'
ARCHIVE_ITCH_32_MD5='02a3fbfd4121a88f462b6b3884d6a75e'
ARCHIVE_ITCH_32_SIZE='180000'
ARCHIVE_ITCH_32_VERSION='1.0-itch'

ARCHIVE_ITCH_64="A Mortician's Tale - Windows x64.zip"
ARCHIVE_ITCH_64_URL='https://laundrybear.itch.io/morticians-tale'
ARCHIVE_ITCH_64_MD5='581b86b6e5f20eeb497b07659aaa0991'
ARCHIVE_ITCH_64_SIZE='180000'
ARCHIVE_ITCH_64_VERSION='1.0-itch'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='morticianstale.exe UnityPlayer.dll morticianstale_Data/Mono morticianstale_Data/Plugins'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='morticianstale_Data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='morticianstale.exe'
APP_MAIN_ICON='morticianstale.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH_ITCH_32='32'
PKG_BIN_ARCH_ITCH_64='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

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

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary directories

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
