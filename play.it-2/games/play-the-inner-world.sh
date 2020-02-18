#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Solène "Mopi" Huault
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
# The Inner World
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200206.3

# Set game-specific variables

GAME_ID='the-inner-world'
GAME_NAME='The Inner World'

ARCHIVE_GOG='setup_the_inner_world_1.2.1_(26675).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_inner_world'
ARCHIVE_GOG_MD5='2379e9c64c4fe06d6892474637aa405b'
ARCHIVE_GOG_SIZE='1500000'
ARCHIVE_GOG_VERSION='1.2.1-gog26675'

ARCHIVE_GOG_OLD0='setup_the_inner_world_2.0.0.2.exe'
ARCHIVE_GOG_OLD0_MD5='b5778aa9770ba7fc7d1a3884154c136b'
ARCHIVE_GOG_OLD0_SIZE='1500000'
ARCHIVE_GOG_OLD0_VERSION='1.2.1-gog2.0.0.2'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.rtf'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_OLD0='app'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.exe *.swf adobe?air meta-inf mimetype'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='*.url media'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_OLD0='app'

APP_MAIN_TYPE='wine'
# shellcheck disable=SC1004
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Enable CSMT patches on WINE staging
if
	[ "$(wine --version | sed "s/.\+(\(.\+\))/\\1/")" = "Staging" ] && \
	[ ! -e csmt_enabled ]
then
	winetricks csmt=on
	touch csmt_enabled
fi'
APP_MAIN_EXE='theinnerworld.exe'
APP_MAIN_ICON='theinnerworld.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine xcursor"

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

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

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
