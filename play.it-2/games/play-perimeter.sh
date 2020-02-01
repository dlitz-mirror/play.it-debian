#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
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
# Perimeter
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20191003.1

# Set game-specific variables

GAME_ID='perimeter'
GAME_NAME='Perimeter'

ARCHIVE_GOG='setup_perimeter_1.03_(19064).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/perimeter'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_MD5='a65c86a8de9b938bc070bcbe5900aef2'
ARCHIVE_GOG_VERSION='1.03-gog19064'
ARCHIVE_GOG_SIZE='3800000'
ARCHIVE_GOG_PART1='setup_perimeter_1.03_(19064)-1.bin'
ARCHIVE_GOG_PART1_TYPE='innosetup'
ARCHIVE_GOG_PART1_MD5='ba08f50e95ce6424d214f57383d338c8'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='manual.pdf readme.txt'

ARCHIVE_GAME0_BIN_PATH='app'
ARCHIVE_GAME0_BIN_FILES='*.exe binkw32.dll'

ARCHIVE_GAME1_BIN_PATH='app/__support/app'
ARCHIVE_GAME1_BIN_FILES='*'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='perimeter.ico cache_font resource scripts'

CONFIG_FILES='./*.ini resource/*.ini'
DATA_DIRS='resource/saves'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='perimeter.exe'
APP_MAIN_ICON='perimeter.ico'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine glx xcursor"

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

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
