#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2020, Hoël Bézier
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
# Dead Cells
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200708.1

# Set game-specific variables

GAME_ID='dead-cells'
GAME_NAME='Dead Cells'

ARCHIVE_GOG='dead_cells_1_9_1_39495.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/dead_cells'
ARCHIVE_GOG_MD5='d39f39354e1546e9fb940e7738992b16'
ARCHIVE_GOG_SIZE='690000'
ARCHIVE_GOG_VERSION='1.9.1-gog39495'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD='dead_cells_1_8_0_37766.sh'
ARCHIVE_GOG_OLD_MD5='93a03894720c4e232566300c61ee153b'
ARCHIVE_GOG_OLD_SIZE='670000'
ARCHIVE_GOG_OLD_VERSION='1.8.0-gog37766'
ARCHIVE_GOG_OLD_TYPE='mojosetup'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/support'
ARCHIVE_DOC1_DATA_FILES='*.txt'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='deadcells libhl.so *.hdll'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='hlboot.dat res.pak'

DATA_DIRS='./logs ./save'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='libhl.so *.hdll'
APP_MAIN_EXE_BIN='deadcells'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libmbedtls.so.12 libopenal.so.1 libpng16.so.16 libSDL2-2.0.so.0 libturbojpeg.so.0 libuv.so.1 libvorbisfile.so.3"


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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'

# Remove unused data

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
