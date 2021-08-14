#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Unavowed
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210313.2

# Set game-specific variables

GAME_ID='unavowed'
GAME_NAME='Unavowed'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='setup_unavowed_1.1_(22770).exe'
ARCHIVE_GOG_0_MD5='95f026c76f26868347cc14c9df299636'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_VERSION='1.1-gog22770'
ARCHIVE_GOG_0_SIZE='2500000'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/unavowed'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.cfg *.dll *.exe steam_appid.txt'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='*.vox'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='unavowed.exe'
APP_MAIN_ICON='unavowed.exe'

APP_CONFIG_ID="${GAME_ID}-config"
APP_CONFIG_NAME="${GAME_NAME} - configuration"
APP_CONFIG_CAT='Settings'
APP_CONFIG_TYPE='wine'
APP_CONFIG_EXE='winsetup.exe'
APP_CONFIG_ICON='winsetup.exe'

CONFIG_FILES='./*.cfg'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine"

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

# Get game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_CONFIG'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Store saved games in persistent paths

DATA_DIRS="$DATA_DIRS ./saves"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store saved games in persistent paths
saves_path_prefix="$WINEPREFIX/drive_c/users/$USER/Saved Games/Unavowed"
saves_path_persistent="$PATH_PREFIX/saves"
if [ ! -h "$saves_path_prefix" ]; then
	if [ -d "$saves_path_prefix" ]; then
		# Migrate existing user data to the persistent path
		mv "$saves_path_prefix"/* "$saves_path_persistent"
		rmdir "$saves_path_prefix"
	fi
	# Create link from prefix to persistent path
	mkdir --parents "$(dirname "$saves_path_prefix")"
	ln --symbolic "$saves_path_persistent" "$saves_path_prefix"
fi'

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
