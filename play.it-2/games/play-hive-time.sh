#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Hive Time
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201020.2

# Set game-specific variables

GAME_ID='hive-time'
GAME_NAME='Hive Time'

ARCHIVES_LIST='
ARCHIVE_ITCH_0'

ARCHIVE_ITCH_0='hive-time-linux-v1.1.zip'
ARCHIVE_ITCH_0_URL='https://cheeseness.itch.io/hive-time'
ARCHIVE_ITCH_0_MD5='5d63b490982d96620b0bbb7b6522be56'
ARCHIVE_ITCH_0_SIZE='180000'
ARCHIVE_ITCH_0_VERSION='1.1-itch'
ARCHIVE_ITCH_0_TYPE='zip'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='hive-time_linux_v1.1.x86_64'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='json hive-time_linux_v1.1.pck fonts'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='hive-time_linux_v1.1.x86_64'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx xcursor"
PKG_BIN_DEPS_ARCH='libx11 '
PKG_BIN_DEPS_DEB='libx11-6'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11'

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
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

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
