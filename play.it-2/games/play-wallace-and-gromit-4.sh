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
# Wallace and Gromit: Episode 4 - The Bogey Man
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210731.4

# Set game-specific variables

GAME_ID='wallace-and-gromit-4'
GAME_NAME='Wallace and Gromit: Episode 4 - The Bogey Man'

ARCHIVE_BASE_0='setup_wallace_and_gromits_episode_4_-_the_bogey_man_1.0_(43022).exe'
ARCHIVE_BASE_0_MD5='1bd26fe8706be1d452bbcebd8a31a1fb'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_VERSION='1.0-gog43022'
ARCHIVE_BASE_0_SIZE='560000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/wallace_gromits_grand_adventures'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='
wallacegromit104.exe
fmodex.dll
language_setup.ini
language_setup.exe'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='
pack
language_setup.png'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='wallacegromit104.exe'
APP_MAIN_ICON='wallacegromit104.exe'

APP_LANGUAGE_TYPE='wine'
APP_LANGUAGE_EXE='language_setup.exe'
APP_LANGUAGE_ID="${GAME_ID}_language"
APP_LANGUAGE_NAME="$GAME_NAME - Language setup"
APP_LANGUAGE_CAT='Settings'
APP_LANGUAGE_ICON='language_setup.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine glx"

# Use persistent storage for saved games and settings

APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"'
userdata:users/${USER}/My Documents/Telltale Games/wallace-and-gromit-4'
CONFIG_FILES="$CONFIG_FILES userdata/prefs.prop"
DATA_FILES="$DATA_FILES userdata/*.save"

# Load common functions

target_version='2.13'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
		'/usr/share/play.it'
	do
		if [ -e "${path}/libplayit2.sh" ]; then
			PLAYIT_LIB2="${path}/libplayit2.sh"
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
icons_get_from_package 'APP_MAIN' 'APP_LANGUAGE'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_LANGUAGE'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
