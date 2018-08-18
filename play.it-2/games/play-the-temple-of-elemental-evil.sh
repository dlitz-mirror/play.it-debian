#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# The Temple of Elemental Evil
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180813.1

# Set game-specific variables

GAME_ID='the-temple-of-elemental-evil'
GAME_NAME='The Temple of Elemental Evil'

ARCHIVE_GOG='setup_temple_of_elemental_evil_1.0_(15416).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_temple_of_elemental_evil'
ARCHIVE_GOG_MD5='1c7b493f71c2c92050a63535b3abec67'
ARCHIVE_GOG_TYPE='innosetup1.7'
ARCHIVE_GOG_VERSION='1.3-gog15416'
ARCHIVE_GOG_SIZE='1400000'

ARCHIVE_GOG_OLD0='setup_temple_of_elemental_evil_2.0.0.13.exe'
ARCHIVE_GOG_OLD0_MD5='44ea1e38ed1da26aefb32a39a899f770'
ARCHIVE_GOG_OLD0_VERSION='1.3-gog2.0.0.13'
ARCHIVE_GOG_OLD0_SIZE='1400000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='./*.pdf ./*.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_OLD0='app'

ARCHIVE_GAME0_BIN_PATH='.'
ARCHIVE_GAME0_BIN_FILES='./*.dll ./*.exe ./*.pyd ./miles'
# Keep compatibility with old archives
ARCHIVE_GAME0_BIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME1_BIN_PATH='__support/app'
ARCHIVE_GAME1_BIN_FILES='./*.cfg'
# Keep compatibility with old archives
ARCHIVE_GAME1_BIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='./toee.ico ./*.dat ./data ./modules'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_OLD0='app'

CONFIG_FILES='./toee.cfg'
DATA_DIRS='./data/maps ./data/save ./data/scr ./modules/toee'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='toee.exe'
APP_MAIN_ICON='toee.ico'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Load common functions

target_version='2.10'

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

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
