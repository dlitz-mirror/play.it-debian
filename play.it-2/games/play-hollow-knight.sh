#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2017-2018, Solène Huault
# Copyright (c) 2018, VA
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
# Hollow Knight
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181024.1

# Set game-specific variables

GAME_ID='hollow-knight'
GAME_NAME='Hollow Knight'

ARCHIVE_GOG='hollow_knight_1_4_3_2_23987.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/hollow_knight'
ARCHIVE_GOG_MD5='520af5ebe8ac3977faaafc5d2ed8a779'
ARCHIVE_GOG_SIZE='9200000'
ARCHIVE_GOG_VERSION='1.4.3.2-gog23987'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='hollow_knight_en_1_3_1_5_20240.sh'
ARCHIVE_GOG_OLD1_MD5='197d9ffc7e0be447849e22a04da836e4'
ARCHIVE_GOG_OLD1_SIZE='7100000'
ARCHIVE_GOG_OLD1_VERSION='1.3.1.5-gog20240'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_hollow_knight_2.1.0.2.sh'
ARCHIVE_GOG_OLD0_MD5='0d18baf29d5552dc094ca2bfe5fcaae6'
ARCHIVE_GOG_OLD0_SIZE='9200000'
ARCHIVE_GOG_OLD0_VERSION='1.0.3.1-gog2.1.0.2'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/support'
ARCHIVE_DOC1_DATA_FILES='*.txt'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='hollow_knight.x86_64 hollow_knight_Data/Mono hollow_knight_Data/Plugins'

ARCHIVE_GAME_ASSETS_PATH='data/noarch/game'
ARCHIVE_GAME_ASSETS_FILES='hollow_knight_Data/*.assets hollow_knight_Data/*.assets.resS'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='hollow_knight_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN='hollow_knight.x86_64'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='hollow_knight_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_ASSETS PKG_DATA'

PKG_ASSETS_ID="${GAME_ID}-assets"
PKG_ASSETS_DESCRIPTION='assets'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_ASSETS_ID $PKG_DATA_ID glibc libstdc++ glu xcursor libxrandr"

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	: ${XDG_DATA_HOME:="$HOME/.local/share"}
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
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_ASSETS' 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
