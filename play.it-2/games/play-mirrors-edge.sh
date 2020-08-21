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
# Mirror’s Edge
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200821.2

# Set game-specific variables

GAME_ID='mirrors-edge'
GAME_NAME='Mirrorʼs Edge'

ARCHIVES_LIST='
ARCHIVE_GOG_0
ARCHIVE_GOG_RAR_0'

ARCHIVE_GOG_0='setup_mirrors_edge_1.01_(40566).exe'
ARCHIVE_GOG_0_MD5='f0faffb76a2b46c3aca8342265a5f41b'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/mirrors_edge'
ARCHIVE_GOG_0_SIZE='12000000'
ARCHIVE_GOG_0_VERSION='1.01-gog40566'
ARCHIVE_GOG_0_PART1='setup_mirrors_edge_1.01_(40566)-1.bin'
ARCHIVE_GOG_0_PART1_MD5='cdfea6d6412de910eae6748eeb6af54e'
ARCHIVE_GOG_0_PART1_TYPE='innosetup'
ARCHIVE_GOG_0_PART2='setup_mirrors_edge_1.01_(40566)-2.bin'
ARCHIVE_GOG_0_PART2_MD5='6b4a66c9ac31c8c2f4e647957c64370a'
ARCHIVE_GOG_0_PART2_TYPE='innosetup'
ARCHIVE_GOG_0_PART3='setup_mirrors_edge_1.01_(40566)-3.bin'
ARCHIVE_GOG_0_PART3_MD5='8529e17c8faa54be07219106ffe00774'
ARCHIVE_GOG_0_PART3_TYPE='innosetup'

ARCHIVE_GOG_RAR_0='setup_mirrors_edge_2.0.0.3.exe'
ARCHIVE_GOG_RAR_0_URL='https://www.gog.com/game/mirrors_edge'
ARCHIVE_GOG_RAR_0_MD5='89381d67169f5c6f8f300e172a64f99c'
ARCHIVE_GOG_RAR_0_SIZE='7700000'
ARCHIVE_GOG_RAR_0_VERSION='1.0-gog2.0.0.3'
ARCHIVE_GOG_RAR_0_TYPE='rar'
ARCHIVE_GOG_RAR_0_PART1='setup_mirrors_edge_2.0.0.3-1.bin'
ARCHIVE_GOG_RAR_0_PART1_MD5='406b99108e1edd17fc60435d1f2c27f9'
ARCHIVE_GOG_RAR_0_PART1_TYPE='rar'
ARCHIVE_GOG_RAR_0_PART2='setup_mirrors_edge_2.0.0.3-2.bin'
ARCHIVE_GOG_RAR_0_PART2_MD5='18f2bd62201904c8e98a4b805a90ab2d'
ARCHIVE_GOG_RAR_0_PART2_TYPE='rar'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='binaries engine'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_RAR='game'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='me_icon.ico tdgame'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_RAR='game'

CONFIG_DIRS='./tdgame/config'
DATA_DIRS='./tdgame/savefiles'

APP_WINETRICKS='physx'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='binaries/mirrorsedge.exe'
APP_MAIN_ICON='me_icon.ico'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks"

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

case "$ARCHIVE" in
	('ARCHIVE_GOG_RAR_'*)
		ln --symbolic "$(readlink --canonicalize "$SOURCE_ARCHIVE_PART1")" "$PLAYIT_WORKDIR/$GAME_ID.r00"
		ln --symbolic "$(readlink --canonicalize "$SOURCE_ARCHIVE_PART2")" "$PLAYIT_WORKDIR/$GAME_ID.r01"
		extract_data_from "$PLAYIT_WORKDIR/$GAME_ID.r00"
		tolower "$PLAYIT_WORKDIR/gamedata"
	;;
	(*)
		extract_data_from "$SOURCE_ARCHIVE"
	;;
esac
prepare_package_layout

# Extract game icons

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
