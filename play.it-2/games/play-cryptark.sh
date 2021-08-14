#!/bin/sh
set -o errexit

###
# Copyright (c) 2018-2020, VA
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Cryptark
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200302.3

# Set game-specific variables

GAME_ID='cryptark'
GAME_NAME='Cryptark'

ARCHIVE_GOG='cryptark_en_1_2_15203.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/cryptark'
ARCHIVE_GOG_MD5='53083f1fef847a30eb99914821c8649a'
ARCHIVE_GOG_SIZE='700000'
ARCHIVE_GOG_VERSION='1.2-gog15203'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='lib/libmojoshader.so lib/libogg.so.0 lib/libopenal.so.1 lib/libpng15.so.15 lib/libSDL2-2.0.so.0 lib/libSDL2_image-2.0.so.0 lib/libtheoradec.so.1 lib/libtheorafile.so lib/libvorbis.so.0'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='lib64/libmojoshader.so lib64/libogg.so.0 lib64/libopenal.so.1 lib64/libpng15.so.15 lib64/libSDL2-2.0.so.0 lib64/libSDL2_image-2.0.so.0 lib64/libtheoradec.so.1 lib64/libtheorafile.so lib64/libvorbis.so.0'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Cryptark.exe *.dll Content Cryptark.png FNA.dll.config gamecontrollerdb.txt monoconfig monomachineconfig'

APP_MAIN_TYPE='mono'
APP_MAIN_LIBS_BIN32='lib'
APP_MAIN_LIBS_BIN64='lib64'
APP_MAIN_EXE='Cryptark.exe'
APP_MAIN_ICON='Cryptark.png'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID mono openal sdl2 sdl2_image vorbis theora"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icon

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
