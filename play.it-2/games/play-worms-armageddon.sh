#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
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
# Worms Armageddon
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210404.1

# Set game-specific variables

GAME_ID='worms-armageddon'
GAME_NAME='Worms Armageddon'

ARCHIVES_LIST='
ARCHIVE_GOG_2
ARCHIVE_GOG_1
ARCHIVE_GOG_0'

ARCHIVE_GOG_2='setup_worms_armageddon_gog-2_(40354).exe'
ARCHIVE_GOG_2_URL='https://www.gog.com/game/worms_armageddon'
ARCHIVE_GOG_2_MD5='db2087029ee8c069c9006ebeedc76bbf'
ARCHIVE_GOG_2_VERSION='3.8-gog40354'
ARCHIVE_GOG_2_SIZE='650000'

ARCHIVE_GOG_1='setup_worms_armageddon_gog-7_(40119).exe'
ARCHIVE_GOG_1_MD5='8e904d462327917452a47572a38b772a'
ARCHIVE_GOG_1_VERSION='3.8-gog40119'
ARCHIVE_GOG_1_SIZE='660000'

ARCHIVE_GOG_0='setup_worms_armageddon_2.0.0.2.exe'
ARCHIVE_GOG_0_MD5='7f0bb89729662ebe74b7c9c2cd97d1c8'
ARCHIVE_GOG_0_VERSION='3.7.2.1-gog2.0.0.2'
ARCHIVE_GOG_0_SIZE='570000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='wa_manual.pdf worms?armageddon?update?documentation.rtf'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.dll wa.exe user/bankeditor.exe'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='data fesfx graphics tweaks user'

ARCHIVE_GAME0_DATA_PATH='__support'
ARCHIVE_GAME0_DATA_FILES='save'

DATA_DIRS='./save ./user'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='wa.exe'
APP_MAIN_ICON='wa.exe'
PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine"

# Keep compatibility with old archives

ARCHIVE_DOC_DATA_PATH_GOG_0='app'
ARCHIVE_GAME_BIN_PATH_GOG_0='app'
ARCHIVE_GAME_DATA_PATH_GOG_0='app'
ARCHIVE_GAME0_DATA_PATH_GOG_0='app/__support'

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
PKG='PKG_DATA'
organize_data "GAME_DATA_SAVE"  "$PATH_GAME"

# Get game icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Create required empty file prior to game run

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Create required empty file prior to game run
touch steam.dat'

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
