#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
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
# FlatOut 2
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190928.1

# Set game-specific variables

GAME_ID='flatout-2'
GAME_NAME='FlatOut 2'

ARCHIVE_GOG='flatout_2_gog_3_23461.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/flatout_2'
ARCHIVE_GOG_TYPE='mojosetup'
ARCHIVE_GOG_MD5='5529dcd679eae03f23d9807efd22a182'
ARCHIVE_GOG_VERSION='1.2-gog23461'
ARCHIVE_GOG_SIZE='3800000'

ARCHIVE_GOG_OLD1='gog_flatout_2_2.1.0.6.sh'
ARCHIVE_GOG_OLD1_MD5='77cbd07105aa202ef808edebda15833a'
ARCHIVE_GOG_OLD1_VERSION='1.2-gog2.1.0.6'
ARCHIVE_GOG_OLD1_SIZE='3400000'

ARCHIVE_GOG_OLD0='gog_flatout_2_2.0.0.4.sh'
ARCHIVE_GOG_OLD0_MD5='cdc453f737159ac62bd9f59540002610'
ARCHIVE_GOG_OLD0_VERSION='1.2-gog2.0.0.4'
ARCHIVE_GOG_OLD0_SIZE='3600000'

ARCHIVE_DOC_DATA_PATH='data/noarch/prefix/drive_c/gog games/flatout 2'
ARCHIVE_DOC_DATA_FILES='*.pdf readme.htm'

ARCHIVE_GAME_BIN_PATH='data/noarch/prefix/drive_c/gog games/flatout 2'
ARCHIVE_GAME_BIN_FILES='flatout2.exe'

ARCHIVE_GAME_DATA_PATH='data/noarch/prefix/drive_c/gog games/flatout 2'
ARCHIVE_GAME_DATA_FILES='filesystem flatout2.ico fo2?.bfs patch patch1.bfs'

DATA_DIRS='./savegame'

APP_WINETRICKS='d3dx9'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='flatout2.exe'
APP_MAIN_ICON='flatout2.ico'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine glx winetricks"

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
tolower "$PLAYIT_WORKDIR/gamedata/data/noarch/prefix/drive_c"
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
