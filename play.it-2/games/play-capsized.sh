#!/bin/sh
set -o errexit

###
# Copyright (c) 2018-2019, VA
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
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
# Capsized
# build native packages from the original installers
# send your bug reports to dev+playit@indigo.re
###

script_version=20190927.4

# Set game-specific variables

GAME_ID='capsized'
GAME_NAME='Capsized'

ARCHIVE_GOG='gog_capsized_2.0.0.2.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/capsized'
ARCHIVE_GOG_MD5='f516c52b4614d63c3cfa4e1ed43934b8'
ARCHIVE_GOG_SIZE='670000'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.2'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_HUMBLE='capsized-12212015-bin'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/capsized'
ARCHIVE_HUMBLE_MD5='10515ca5f73e38151e17766cba97f3ed'
ARCHIVE_HUMBLE_SIZE='650000'
ARCHIVE_HUMBLE_VERSION='1.0-humble151221'
ARCHIVE_HUMBLE_TYPE='mojosetup'

ARCHIVE_DOC0_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC0_DATA_PATH_HUMBLE='data'
ARCHIVE_DOC0_DATA_FILES='Linux.README'

ARCHIVE_DOC1_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC1_DATA_FILES_GOG='*'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='data'
ARCHIVE_GAME_BIN32_FILES='NePlusUltra.bin.x86 lib'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='data'
ARCHIVE_GAME_BIN64_FILES='NePlusUltra.bin.x86_64 lib64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='data'
ARCHIVE_GAME_DATA_FILES='*.config *.dll Capsized.bmp Content NePlusUltra.exe de es fr it mono'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='export TERM="${TERM%-256color}"'
APP_MAIN_EXE_BIN32='NePlusUltra.bin.x86'
APP_MAIN_EXE_BIN64='NePlusUltra.bin.x86_64'
APP_MAIN_ICON='Capsized.bmp'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ sdl2 glx alsa openal vorbis theora libudev1"

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
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

for PKG in PKG_BIN32 PKG_BIN64; do
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

