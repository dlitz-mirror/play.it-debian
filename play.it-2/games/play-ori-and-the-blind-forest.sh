#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2017-2018, Solène Huault
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
# Ori and the Blind Forest
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180714.2

# Set game-specific variables

GAME_ID='ori-and-the-blind-forest'
GAME_NAME='Ori and the Blind Forest'

ARCHIVE_GOG='setup_ori_and_the_blind_forest_de_2.0.0.2.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/ori_and_the_blind_forest_definitive_edition'
ARCHIVE_GOG_MD5='1dedfb0663ebbe82d051a62dc68149b5'
ARCHIVE_GOG_SIZE='11000000'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.2'
ARCHIVE_GOG_TYPE='rar'
ARCHIVE_GOG_PART1='setup_ori_and_the_blind_forest_de_2.0.0.2-1.bin'
ARCHIVE_GOG_PART1_MD5='d5ec4ea264c372a4fdd52b5ecbd9efe6'
ARCHIVE_GOG_PART1_TYPE='rar'
ARCHIVE_GOG_PART2='setup_ori_and_the_blind_forest_de_2.0.0.2-2.bin'
ARCHIVE_GOG_PART2_MD5='94c3d33701eadca15df9520de55f6f03'
ARCHIVE_GOG_PART2_TYPE='rar'

DATA_FILES='./oride_data/output_log.txt'

ARCHIVE_GAME_ASSETS_PATH='game'
ARCHIVE_GAME_ASSETS_FILES='./oride_data/*.assets ./oride_data/*.assets.ress'

ARCHIVE_GAME_DATA_PATH='game'
ARCHIVE_GAME_DATA_FILES='./oride_data'

ARCHIVE_GAME_BIN_PATH='game'
ARCHIVE_GAME_BIN_FILES='./oride.exe ./oride_data/managed ./oride_data/mono ./oride_data/plugins'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='oride.exe'
APP_MAIN_OPTIONS='-force-d3d9'
APP_MAIN_ICON='oride.exe'

PACKAGES_LIST='PKG_ASSETS PKG_DATA PKG_BIN'

PKG_ASSETS_ID="${GAME_ID}-assets"
PKG_ASSETS_DESCRIPTION='assets'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_ASSETS_ID $PKG_DATA_ID wine"

# Load common functions

target_version='2.9'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	for path in\
		'./'\
		"$XDG_DATA_HOME/play.it/"\
		"$XDG_DATA_HOME/play.it/play.it-2/lib/"\
		'/usr/local/share/games/play.it/'\
		'/usr/local/share/play.it/'\
		'/usr/share/games/play.it/'\
		'/usr/share/play.it/'
	do
		if [ -z "$PLAYIT_LIB2" ] && [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
	if [ -z "$PLAYIT_LIB2" ]; then
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
. "$PLAYIT_LIB2"

# Extract game data

ln --symbolic "$(readlink --canonicalize "$SOURCE_ARCHIVE_PART1")" "$PLAYIT_WORKDIR/$GAME_ID.r00"
ln --symbolic "$(readlink --canonicalize "$SOURCE_ARCHIVE_PART2")" "$PLAYIT_WORKDIR/$GAME_ID.r01"
extract_data_from "$PLAYIT_WORKDIR/$GAME_ID.r00"
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
