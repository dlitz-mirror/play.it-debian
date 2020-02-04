#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2017-2020, Jacek Szafarkiewicz
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
# Xenonauts
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200204.2

# Set game-specific variables

GAME_ID='xenonauts'
GAME_NAME='Xenonauts'

ARCHIVE_GOG='xenonauts_en_1_65_21328.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/xenonauts'
ARCHIVE_GOG_MD5='bff1d949f13f2123551a964475ea655e'
ARCHIVE_GOG_SIZE='2900000'
ARCHIVE_GOG_VERSION='1.65-gog21328'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_xenonauts_2.1.0.4.sh'
ARCHIVE_GOG_OLD0_MD5='7830dee208e779f97858ee81a97c9327'
ARCHIVE_GOG_OLD0_SIZE='2900000'
ARCHIVE_GOG_OLD0_VERSION='1.63-gog2.1.0.4'

ARCHIVE_HUMBLE='Xenonauts-DRMFree-Linux-2016-03-03.sh'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/xenonauts'
ARCHIVE_HUMBLE_MD5='f4369e987381b84fde64be569fbab913'
ARCHIVE_HUMBLE_SIZE='2700000'
ARCHIVE_HUMBLE_VERSION='1.65-humble160303'
ARCHIVE_HUMBLE_TYPE='mojosetup'

ARCHIVE_DOC_PATH_GOG='data/noarch/game'
ARCHIVE_DOC_PATH_HUMBLE='data/noarch'
ARCHIVE_DOC_FILES='README.linux *.pdf'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='data/x86'
ARCHIVE_GAME_BIN_FILES='Xenonauts.bin.x86 lib'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='data/noarch'
ARCHIVE_GAME_DATA_FILES='assets extras Icon.*'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Xenonauts.bin.x86'
APP_MAIN_ICON='Icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx sdl2 alsa"
PKG_BIN_DEPS_ARCH='lib32-libx11 lib32-libxinerama lib32-libxxf86vm lib32-libxext'
PKG_BIN_DEPS_DEB='libx11-6, libxinerama1, libxxf86vm1, libxext6'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11[abi_x86_32] x11-libs/libXinerama[abi_x86_32] x11-libs/libXxf86vm[abi_x86_32] x11-libs/libXext[abi_x86_32]'

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

# Get game icon

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
