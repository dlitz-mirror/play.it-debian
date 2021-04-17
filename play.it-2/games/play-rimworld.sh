#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2017-2020, HS-157
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
# Rimworld
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201212.1

# Set game-specific variables

GAME_ID='rimworld'
GAME_NAME='Rimworld'

ARCHIVE_OFFICIAL='RimWorld1-1-2654Linux.zip'
ARCHIVE_OFFICIAL_URL='https://rimworldgame.com/getmygame/'
ARCHIVE_OFFICIAL_MD5='4391d550e8da14b7826a63dbd75cbc44'
ARCHIVE_OFFICIAL_VERSION='1.1.2654-official'
ARCHIVE_OFFICIAL_SIZE='350000'
ARCHIVE_OFFICIAL_TYPE='zip_unclean'

ARCHIVE_GAME_BIN_PATH='RimWorld1-1-2654Linux'
ARCHIVE_GAME_BIN_FILES='RimWorldLinux'

ARCHIVE_GAME_DATA_PATH='RimWorld1-1-2654Linux'
ARCHIVE_GAME_DATA_FILES='Data/Core RimWorldLinux_Data'

DATA_DIRS='./logs ./Mods'

APP_MAIN_TYPE='native'
APP_MAIN_ICON='RimWorldLinux_Data/Resources/UnityPlayer.png'
APP_MAIN_OPTIONS='-logfile ./logs/$(date +%F-%R).log'
APP_MAIN_EXE='RimWorldLinux'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++"

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon
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
