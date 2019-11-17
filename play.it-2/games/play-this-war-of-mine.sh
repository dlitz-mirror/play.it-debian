#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2019, Solène "Mopi" Huault
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
# This War of Mine
# build native packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20191217.2

# Set game-specific variables

GAME_ID='this-war-of-mine'
GAME_NAME='This War of Mine'

ARCHIVE_GOG='this_war_of_mine_5_1_0_26027.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/this_war_of_mine'
ARCHIVE_GOG_MD5='8c9221653e6fc94a6898f5ef66a3325f'
ARCHIVE_GOG_VERSION='5.1.0-gog26027'
ARCHIVE_GOG_SIZE='2200000'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='this_war_of_mine_4_0_1_25361.sh'
ARCHIVE_GOG_OLD2_MD5='c6d96f0722a35821ea30500d8e7658d8'
ARCHIVE_GOG_OLD2_VERSION='4.0.1-gog25361'
ARCHIVE_GOG_OLD2_SIZE='2200000'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='this_war_of_mine_4_0_1_24802.sh'
ARCHIVE_GOG_OLD1_MD5='17daac7e70ee2c783b12114573cb7757'
ARCHIVE_GOG_OLD1_VERSION='4.0.1-gog24802'
ARCHIVE_GOG_OLD1_SIZE='1500000'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='this_war_of_mine_en_4_0_0_29_01_2018_18230.sh'
ARCHIVE_GOG_OLD0_MD5='165f4d6158425c3d2861c533f10b5713'
ARCHIVE_GOG_OLD0_VERSION='4.0.0-gog18230'
ARCHIVE_GOG_OLD0_SIZE='1500000'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_DOC_PATH='data/noarch/docs'
ARCHIVE_DOC_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='libcurl.so.4 libOpenAL.so KosovoLinux This?War?of?Mine TWOMLinux'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='*.dat *.idx *.str CustomContent LocalizationPacks svnrev.txt WorkshopData'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='KosovoLinux'
APP_MAIN_ICON='data/noarch/support/icon.png'
# Keep compatibility with old archives
APP_MAIN_EXE_GOG_OLD1='This War of Mine'
APP_MAIN_EXE_GOG_OLD0='TWOMLinux'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx openal libcurl alsa"
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
prepare_package_layout

# Extract icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
use_archive_specific_value 'APP_MAIN_EXE'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
