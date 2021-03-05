#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2021, Antoine "vv221/vv222" Le Gonidec
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
# Broken Sword 3: The Sleeping Dragon
# build native Linux packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210305.2

# Set game-specific variables

GAME_ID='broken-sword-3'
GAME_NAME='Broken Sword 3: The Sleeping Dragon'

ARCHIVE_GOG='setup_broken_sword_3_-_the_sleeping_dragon_1.0_(19115).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/broken_sword_3__the_sleeping_dragon'
ARCHIVE_GOG_MD5='e53f974fa1042cb65a8f5fd9d2ee3b58'
ARCHIVE_GOG_SIZE='1900000'
ARCHIVE_GOG_VERSION='1.0-gog19115'
ARCHIVE_GOG_TYPE='innosetup'

ARCHIVE_GOG_PART1='setup_broken_sword_3_-_the_sleeping_dragon_1.0_(19115)-1.bin'
ARCHIVE_GOG_PART1_MD5='3901d740c9071b43eae5b5e3566ef4c6'
ARCHIVE_GOG_PART1_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='manual.pdf readme.txt'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='binkw32.dll bstsd.exe'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='data data.pak'

DATA_DIRS='./saves'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='bstsd.exe'
APP_MAIN_ICON='bstsd.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

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

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

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
