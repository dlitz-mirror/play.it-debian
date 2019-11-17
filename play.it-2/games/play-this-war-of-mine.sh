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

script_version=20191221.1

# Set game-specific variables

GAME_ID='this-war-of-mine'
GAME_NAME='This War of Mine'

ARCHIVE_GOG='this_war_of_mine_6_0_8_a_34693.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/this_war_of_mine'
ARCHIVE_GOG_MD5='cc7afc1412ae1b92db5b992c2dd76818'
ARCHIVE_GOG_VERSION='6.0.8a-gog34693'
ARCHIVE_GOG_SIZE='2800000'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD8='this_war_of_mine_6_0_8_34211.sh'
ARCHIVE_GOG_OLD8_MD5='13d21027e6950b03946071bf4c06cb9e'
ARCHIVE_GOG_OLD8_VERSION='6.0.8-gog34211'
ARCHIVE_GOG_OLD8_SIZE='2800000'
ARCHIVE_GOG_OLD8_TYPE='mojosetup'

ARCHIVE_GOG_OLD7='this_war_of_mine_6_0_7_33947.sh'
ARCHIVE_GOG_OLD7_MD5='f983657b4cd3bad71047d1cc62654b34'
ARCHIVE_GOG_OLD7_VERSION='6.0.7-gog33947'
ARCHIVE_GOG_OLD7_SIZE='2800000'
ARCHIVE_GOG_OLD7_TYPE='mojosetup'

ARCHIVE_GOG_OLD6='this_war_of_mine_6_0_6_32269.sh'
ARCHIVE_GOG_OLD6_MD5='65b0332c4355046d09e5c49f1925cec9'
ARCHIVE_GOG_OLD6_VERSION='6.0.6-32269'
ARCHIVE_GOG_OLD6_SIZE='2700000'
ARCHIVE_GOG_OLD6_TYPE='mojosetup'

ARCHIVE_GOG_OLD5='this_war_of_mine_6_0_5_32074.sh'
ARCHIVE_GOG_OLD5_MD5='8cb7bc50a58162242f215df36ae3ccdb'
ARCHIVE_GOG_OLD5_VERSION='6.0.5-gog32074'
ARCHIVE_GOG_OLD5_SIZE='2700000'
ARCHIVE_GOG_OLD5_TYPE='mojosetup'

ARCHIVE_GOG_OLD4='this_war_of_mine_6_0_0_s3788_a10718_31527.sh'
ARCHIVE_GOG_OLD4_MD5='b317099aa7c0c0a4942845893e4f7386'
ARCHIVE_GOG_OLD4_VERSION='6.0.0-gog31527'
ARCHIVE_GOG_OLD4_SIZE='2700000'
ARCHIVE_GOG_OLD4_TYPE='mojosetup'

ARCHIVE_GOG_OLD3='this_war_of_mine_5_1_0_26027.sh'
ARCHIVE_GOG_OLD3_MD5='8c9221653e6fc94a6898f5ef66a3325f'
ARCHIVE_GOG_OLD3_VERSION='5.1.0-gog26027'
ARCHIVE_GOG_OLD3_SIZE='2200000'
ARCHIVE_GOG_OLD3_TYPE='mojosetup'

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
APP_MAIN_EXE='This War of Mine'
APP_MAIN_ICON='data/noarch/support/icon.png'
# Keep compatibility with old archives
APP_MAIN_EXE_GOG_OLD3='KosovoLinux'
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
