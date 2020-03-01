#!/bin/sh
set -o errexit

###
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
# Distance
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200215.2

# Set game-specific variables

GAME_ID='distance'
GAME_NAME='Distance'

ARCHIVE_HUMBLE='distance_6895_linux.tar.gz'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/distance'
ARCHIVE_HUMBLE_MD5='8c71eb4ebd4dbe0b89ee90ba538eadd9'
ARCHIVE_HUMBLE_VERSION='1.4.0-humble190905'
ARCHIVE_HUMBLE_SIZE='2600000'

ARCHIVE_HUMBLE_OLD4='distance_6842_linux.tar.gz'
ARCHIVE_HUMBLE_OLD4_MD5='58e05033c1a0ae206718be5d5ee800db'
ARCHIVE_HUMBLE_OLD4_VERSION='1.3.1-humble190618'
ARCHIVE_HUMBLE_OLD4_SIZE='2400000'

ARCHIVE_HUMBLE_OLD3='distance_6839_linux.tar.gz'
ARCHIVE_HUMBLE_OLD3_MD5='308b8276a490f641476098900180d1d3'
ARCHIVE_HUMBLE_OLD3_VERSION='1.3.0-humble190609'
ARCHIVE_HUMBLE_OLD3_SIZE='2400000'

ARCHIVE_HUMBLE_OLD2='distance_6802_linux.tar.gz'
ARCHIVE_HUMBLE_OLD2_MD5='e98812e71ce42e667c33cdf3f38793b7'
ARCHIVE_HUMBLE_OLD2_VERSION='1.2.4-humble190418'
ARCHIVE_HUMBLE_OLD2_SIZE='2400000'

ARCHIVE_HUMBLE_OLD1='distance_6714_linux.tar.gz'
ARCHIVE_HUMBLE_OLD1_MD5='6b82a258c4fe4c5fe5dcf3ec70f7c326'
ARCHIVE_HUMBLE_OLD1_VERSION='1.1.1-humble190120'
ARCHIVE_HUMBLE_OLD1_SIZE='2300000'

ARCHIVE_HUMBLE_OLD0='distance_6670_linux.tar.gz'
ARCHIVE_HUMBLE_OLD0_MD5='7542f19db3aa2f00368b4efb91907a4f'
ARCHIVE_HUMBLE_OLD0_VERSION='1.0.2-humble181103'
ARCHIVE_HUMBLE_OLD0_SIZE='1800000'

ARCHIVE_DOC_PATH='.'
ARCHIVE_DOC_FILES='EULA.txt'

ARCHIVE_GAME_BIN_PATH='bin'
ARCHIVE_GAME_BIN_FILES='Distance Distance_Data/Mono Distance_Data/Plugins'

ARCHIVE_GAME_DATA_PATH='bin'
ARCHIVE_GAME_DATA_FILES='Distance_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Distance'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='Distance_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx xcursor libxrandr libudev1 sdl2"
PKG_BIN_DEPS_ARCH='lib32-libx11'
PKG_BIN_DEPS_DEB='libx11-6'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11[abi_x86_32]'

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
