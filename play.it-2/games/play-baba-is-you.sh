#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2019-2020, Erwann Duclos
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
# Baba Is You
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200301.2

# Set game-specific variables

GAME_ID='baba-is-you'
GAME_NAME='Baba Is You'

ARCHIVE_ITCH='BIY_linux.tar.gz'
ARCHIVE_ITCH_URL='https://hempuli.itch.io/baba'
ARCHIVE_ITCH_MD5='3694afc5579cdaad7448c9744aa8d063'
ARCHIVE_ITCH_VERSION='1.0-itch1'
ARCHIVE_ITCH_SIZE='87000'

ARCHIVE_GAME_BIN32_PATH='Baba Is You/bin32'
ARCHIVE_GAME_BIN32_FILES='Chowdren'

ARCHIVE_GAME_BIN64_PATH='Baba Is You/bin64'
ARCHIVE_GAME_BIN64_FILES='Chowdren'

ARCHIVE_GAME_DATA_PATH='Baba Is You'
ARCHIVE_GAME_DATA_FILES='Data icon.bmp Assets.dat gamecontrollerdb.txt'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Chowdren'
APP_MAIN_EXE_BIN64='Chowdren'
APP_MAIN_ICON='icon.bmp'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glx glibc libstdc++"

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
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers
for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
