#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
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
# Contract Demon
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210603.16

# Set game-specific variables

GAME_ID='contract-demon'
GAME_NAME='Contract Demon'

ARCHIVE_BASE_1='contractdemon-1.8.0-pc.zip'
ARCHIVE_BASE_1_MD5='269db9bdbf6f40c7362814de7c8f46da'
ARCHIVE_BASE_1_SIZE='200000'
ARCHIVE_BASE_1_VERSION='1.8.0-itch.2021.05.08'
ARCHIVE_BASE_1_URL='https://nomnomnami.itch.io/contract-demon'

ARCHIVE_BASE_0='contractdemon-1.7.1-pc.zip'
ARCHIVE_BASE_0_MD5='81de84b69550eae7ae13e019a4aec3bf'
ARCHIVE_BASE_0_SIZE='150000'
ARCHIVE_BASE_0_VERSION='1.7.1-itch'

ARCHIVE_GAME_BIN32_PATH='contractdemon-1.8.0-pc'
ARCHIVE_GAME_BIN32_FILES='lib/linux-i686'

ARCHIVE_GAME_BIN64_PATH='contractdemon-1.8.0-pc'
ARCHIVE_GAME_BIN64_FILES='lib/linux-x86_64'

ARCHIVE_GAME_DATA_PATH='contractdemon-1.8.0-pc'
ARCHIVE_GAME_DATA_FILES='lib/python2.7 game contractdemon.py renpy'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='lib/linux-i686/contractdemon'
APP_MAIN_EXE_BIN64='lib/linux-x86_64/contractdemon'
APP_MAIN_ICON='contractdemon-1.8.0-pc/contractdemon.exe'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc libstdc++ glx"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Provide support for old archives

ARCHIVE_GAME_BIN32_PATH_0='contractdemon-1.7.1-pc'
ARCHIVE_GAME_BIN64_PATH_0='contractdemon-1.7.1-pc'
ARCHIVE_GAME_DATA_PATH_0='contractdemon-1.7.1-pc'
ARCHIVE_GAME_DATA_FILES_0="${ARCHIVE_GAME_DATA_FILES} lib/pythonlib2.7"
APP_MAIN_ICON_0='contractdemon-1.7.1-pc/contractdemon.exe'

# Load common functions

target_version='2.13'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
		'/usr/share/play.it'
	do
		if [ -e "${path}/libplayit2.sh" ]; then
			PLAYIT_LIB2="${path}/libplayit2.sh"
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

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'

# Clean up temporary directories

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
