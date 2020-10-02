#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2020, Emmanuel Gil Peyrot <linkmauve@linkmauve.fr>
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
# Touhou Koumakyou ~ the Embodiment of Scarlet Devil - Demo
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200930.1

# Set game-specific variables

GAME_ID='touhou-koumakyou-the-embodiment-of-scarlet-devil-demo'
GAME_NAME='Touhou Koumakyou ~ the Embodiment of Scarlet Devil - Demo'

SCRIPT_DEPS='convmv iconv'

ARCHIVE_ZUN='kouma_tr013.lzh'
ARCHIVE_ZUN_URL='http://www16.big.or.jp/~zun/html/th06.html'
ARCHIVE_ZUN_MD5='7ea4be414a7f256429a2c5e4666c9881'
ARCHIVE_ZUN_VERSION='0.13-zun1'
ARCHIVE_ZUN_SIZE='4500'
ARCHIVE_ZUN_TYPE='lha'

ARCHIVE_DOC_DATA_PATH='東方紅魔郷　体験版'
ARCHIVE_DOC_DATA_FILES='*.txt マニュアル'

ARCHIVE_GAME_BIN_PATH='東方紅魔郷　体験版'
ARCHIVE_GAME_BIN_FILES='*.exe'

ARCHIVE_GAME_DATA_PATH='東方紅魔郷　体験版'
ARCHIVE_GAME_DATA_FILES='*.DAT'

# Store saved games and settings outside of WINE prefix
CONFIG_FILES='./東方紅魔郷.cfg'
DATA_FILES='./log.txt ./score.dat'
DATA_DIRS='./replay'

APP_MAIN_TYPE='wine'
APP_MAIN_PRERUN='export LANG=ja_JP.UTF-8'
APP_MAIN_EXE='東方紅魔郷.exe'
APP_MAIN_ICON='東方紅魔郷.exe'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_TYPE='wine'
APP_CONFIG_PRERUN='export LANG=ja_JP.UTF-8'
APP_CONFIG_EXE='custom.exe'
APP_CONFIG_ICON='custom.exe'
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_CAT='Settings'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine glx"
PKG_BIN_DEPS_DEB='fonts-wqy-microhei'
PKG_BIN_DEPS_ARCH='wqy-microhei'
PKG_BIN_DEPS_GENTOO='media-fonts/wqy-microhei'

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

# Convert the file names to UTF-8 encoding

if [ $DRY_RUN -eq 0 ]; then
	convmv -f CP932 -t UTF-8 --notest -r "$PLAYIT_WORKDIR"/gamedata >/dev/null
fi

# Convert the text files to UTF-8 encoding

if [ $DRY_RUN -eq 0 ]; then
	find "$PLAYIT_WORKDIR" \( -name '*.txt' -o -name '*.html' \) -exec\
		sh -c 'contents=$(iconv --from-code CP932 --to-code UTF-8 "$1"); printf "%s" "$contents" > "$1"' -- '{}' \;
fi

prepare_package_layout

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_CONFIG'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_CONFIG'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
