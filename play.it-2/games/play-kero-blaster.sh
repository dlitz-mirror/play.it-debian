#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, BetaRays
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
# Kero Blaster
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180923.1

# Set game-specific variables

GAME_ID='kero-blaster'
GAME_NAME='Kero Blaster'

ARCHIVE_PLAYISM='KeroBlaster_EN_v1501a.zip'
ARCHIVE_PLAYISM_URL='http://playism-games.com/game/141/kero-blaster'
ARCHIVE_PLAYISM_MD5='c6ba58d37b5344d08c7d9a94506266b0'
ARCHIVE_PLAYISM_VERSION='1.501-playism1501a'
ARCHIVE_PLAYISM_SIZE='20000'
ARCHIVE_PLAYISM_TYPE='zip'

ARCHIVE_DOC_DATA_PATH='KeroBlasterEn'
ARCHIVE_DOC_DATA_FILES='ReadmeEn.txt'

ARCHIVE_GAME_BIN_PATH='KeroBlasterEn'
ARCHIVE_GAME_BIN_FILES='KeroBlaster.exe'

ARCHIVE_GAME_DATA_PATH='KeroBlasterEn'
ARCHIVE_GAME_DATA_FILES='rsc_k'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='KeroBlaster.exe'
APP_MAIN_ICON='KeroBlaster.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"
PKG_BIN_DEPS_ARCH='lib32-mpg123 lib32-alsa-lib'

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

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

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
