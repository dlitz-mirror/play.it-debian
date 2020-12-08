#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, BetaRays
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
# Age of Wonders
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200926.4

# Set game-specific variables

GAME_ID='age-of-wonders-1'
GAME_NAME='Age of Wonders'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0'

ARCHIVE_GOG_1='setup_age_of_wonders_1.36.0053_(22161).exe'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/age_of_wonders'
ARCHIVE_GOG_1_MD5='e9c045b1a915d0af6f838ec0ad27d910'
ARCHIVE_GOG_1_VERSION='1.36.0053-gog22161'
ARCHIVE_GOG_1_SIZE='320000'
ARCHIVE_GOG_1_TYPE='innosetup'

ARCHIVE_GOG_0='setup_age_of_wonders_2.0.0.13.exe'
ARCHIVE_GOG_0_MD5='9ee2ccc5223c41306cf6695fc09a5634'
ARCHIVE_GOG_0_VERSION='1.36.0053-gog2.0.0.13'
ARCHIVE_GOG_0_SIZE='330000'
ARCHIVE_GOG_0_TYPE='innosetup'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='aow.exe aowed.exe'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='readme.txt quickstart.pdf'

ARCHIVE_GAME0_DATA_PATH='.'
ARCHIVE_GAME0_DATA_FILES='*.wav *.dpl int dict edimages images release scenario sfx songs tcmaps'

# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_0='app'
ARCHIVE_DOC_DATA_PATH_GOG_0='app'
ARCHIVE_GAME0_DATA_PATH_GOG_0='app'

DATA_DIRS='./emailin ./emailout ./save ./user'

# "icodecs" winetricks verb is required for correct intro movie playback
APP_WINETRICKS='icodecs'


APP_MAIN_TYPE='wine'
APP_MAIN_EXE='aow.exe'
APP_MAIN_ICON='aow.exe'

APP_EDITOR_ID="${GAME_ID}_editor"
APP_EDITOR_TYPE='wine'
APP_EDITOR_EXE='aowed.exe'
APP_EDITOR_ICON='aowed.exe'
APP_EDITOR_NAME="$GAME_NAME - editor"

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine glx"

# Load common functions

target_version='2.12'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
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

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_EDITOR'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_EDITOR'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
