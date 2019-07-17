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
# Tetrobot and Co.
# build native packages from the original installers
# send your bug reports to dev+playit@indigo.re
###

script_version=20190927.3

# Set game-specific variables

GAME_ID='tetrobot-and-co'
GAME_NAME='Tetrobot and Co.'

ARCHIVE_GOG='gog_tetrobot_and_co_2.1.0.6.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/tetrobot-and-co'
ARCHIVE_GOG_MD5='2ad2969e64e19d5753f8822e407c148c'
ARCHIVE_GOG_SIZE='530000'
ARCHIVE_GOG_VERSION='1.2.1-gog2.1.0.6'

ARCHIVE_GOG_OLD0='gog_tetrobot_and_co_2.1.0.5.sh'
ARCHIVE_GOG_OLD0_MD5='7d75f9813e1ec154158875c8e69e9dc8'
ARCHIVE_GOG_OLD0_SIZE='530000'
ARCHIVE_GOG_OLD0_VERSION='1.2.1-gog2.1.0.5'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='Tetrobot?and?Co.x86 Data/Mono'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Tetrobot and Co.x86'
APP_MAIN_ICON='Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glu glx xcursor"
PKG_BIN_DEPS_ARCH='lib32-libx11 lib32-libxext lib32-gcc-libs'
PKG_BIN_DEPS_DEB='libx11-6, libxext6, libgcc1'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11[abi_x86_32] x11-libs/libXext[abi_x86_32] sys-devel/gcc[abi_x86_32]'

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

