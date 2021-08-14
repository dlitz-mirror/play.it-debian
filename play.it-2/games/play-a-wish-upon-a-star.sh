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
# A Wish Upon a Star
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210518.3

# Set game-specific variables

GAME_ID='a-wish-upon-a-star'
GAME_NAME='A Wish Upon a Star'

ARCHIVE_BASE_32BIT_0='AWishUponAStar_v1_2_0_WIN32.zip'
ARCHIVE_BASE_32BIT_0_MD5='6644015a399d7485f7c73491f9462854'
ARCHIVE_BASE_32BIT_0_SIZE='260000'
ARCHIVE_BASE_32BIT_0_VERSION='1.2.0-itch.2018.07.07'
ARCHIVE_BASE_32BIT_0_URL='https://fabiandenter.itch.io/wish-upon-a-star'

ARCHIVE_BASE_64BIT_0='AWishUponAStar_WIN_v1_2_0.zip'
ARCHIVE_BASE_64BIT_0_MD5='1c76b283aabf5d64bc05fbf489cf3a25'
ARCHIVE_BASE_64BIT_0_SIZE='260000'
ARCHIVE_BASE_64BIT_0_VERSION='1.2.0-itch.2018.07.07'
ARCHIVE_BASE_64BIT_0_URL='https://fabiandenter.itch.io/wish-upon-a-star'

ARCHIVE_GAME_BIN_PATH_32BIT='AWishUponAStar_v1_2_0_WIN32'
ARCHIVE_GAME_BIN_PATH_64BIT='AWishUponAStar_WIN_v1_2_0'
ARCHIVE_GAME_BIN_FILES='AWishUponAStar.exe AWishUponAStar_Data/Mono UnityPlayer.dll'

ARCHIVE_GAME_DATA_PATH_32BIT='AWishUponAStar_v1_2_0_WIN32'
ARCHIVE_GAME_DATA_PATH_64BIT='AWishUponAStar_WIN_v1_2_0'
ARCHIVE_GAME_DATA_FILES='AWishUponAStar_Data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='AWishUponAStar.exe'
APP_MAIN_ICON='AWishUponAStar.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH_32BIT='32'
PKG_BIN_ARCH_64BIT='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

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

# Extract icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Use persistent storage for game progress and settings

REGISTRY_KEY='HKEY_CURRENT_USER\Software\Fabian Denter\A Wish Upon A Star'
REGISTRY_DUMP='registry-dumps/persistent.reg'

DATA_DIRS="${DATA_DIRS} ./$(dirname "$REGISTRY_DUMP")"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN

# Set path for persistent dump of registry keys
REGISTRY_KEY='$REGISTRY_KEY'
REGISTRY_DUMP='$REGISTRY_DUMP'"
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'

# Dump registry keys
wine regedit.exe -E "$REGISTRY_DUMP" "$REGISTRY_KEY"'
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Load dump of registry keys
if [ -e "$REGISTRY_DUMP" ]; then
	wine regedit.exe "$REGISTRY_DUMP"
fi'

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
