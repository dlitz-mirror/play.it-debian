#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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
# The Adventures of Shuggy
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200518.2

# Set game-specific variables

GAME_ID='the-adventures-of-shuggy'
GAME_NAME='The Adventures of Shuggy'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='gog_the_adventures_of_shuggy_2.0.0.2.sh'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/the_adventures_of_shuggy'
ARCHIVE_GOG_0_MD5='7d031b4cbbbf88beb5bdaa077892215d'
ARCHIVE_GOG_0_SIZE='120000'
ARCHIVE_GOG_0_VERSION='1.10.10222015-gog2.0.0.2'
ARCHIVE_GOG_0_TYPE='mojosetup'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game'
ARCHIVE_DOC1_DATA_FILES='info.txt Linux.README'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='lib Shuggy.bin.x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='lib64 Shuggy.bin.x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='mono *.dll *.dll.config fx GameFont.xnb gateways gfx growingpains deadunderground maps recordings sfx Shuggy Shuggy.bmp Shuggy.exe text video'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016                                           
APP_MAIN_PRERUN='# Work around terminfo Mono bug, cf. https://github.com/mono/mono/issues/6752
export TERM="${TERM%-256color}"'                                      
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'                                   
# Work around Mono unpredictable behaviour with non-US locales        
export LANG=C' 
APP_MAIN_EXE_BIN32='Shuggy.bin.x86'
APP_MAIN_EXE_BIN64='Shuggy.bin.x86_64'
APP_MAIN_ICON='Shuggy.bmp'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ openal sdl2 glx alsa"

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

# Get game icon

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
