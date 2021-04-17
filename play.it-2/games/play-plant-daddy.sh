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
# Plant Daddy
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210411.7

# Set game-specific variables

GAME_ID='plant-daddy'
GAME_NAME='Plant Daddy'

ARCHIVES_LIST='
ARCHIVE_BASE_2
ARCHIVE_BASE_1
ARCHIVE_BASE_0'

ARCHIVE_BASE_2='plantdaddy-linux-1.2.2.zip'
ARCHIVE_BASE_2_MD5='e64ec41dec67d889cfac4763147af384'
ARCHIVE_BASE_2_SIZE='130000'
ARCHIVE_BASE_2_VERSION='1.2.2-itch1'
ARCHIVE_BASE_2_URL='https://overfull.itch.io/plantdaddy'

ARCHIVE_BASE_1='plantdaddy-linux-1.2.1.zip'
ARCHIVE_BASE_1_MD5='1a863b49a4fe6e4c5ad136d808912058'
ARCHIVE_BASE_1_SIZE='140000'
ARCHIVE_BASE_1_VERSION='1.2.1-itch1'

ARCHIVE_BASE_0='plantdaddy-linux-1.2.0.zip'
ARCHIVE_BASE_0_MD5='b626d5a0512cc0334749de3ec137c492'
ARCHIVE_BASE_0_SIZE='140000'
ARCHIVE_BASE_0_VERSION='1.2.0-itch1'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='plantdaddy_Data/MonoBleedingEdge plantdaddy_Data/Plugins plantdaddy UnityPlayer.so'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='plantdaddy_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='plantdaddy'
APP_MAIN_ICON='plantdaddy_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc libgobject-2.0.so.0 libglib-2.0.so.0"
PKG_BIN_DEPS_ARCH='gtk3'
PKG_BIN_DEPS_DEB='libgtk-3-0'
PKG_BIN_DEPS_GENTOO='x11-libs/gtk+:3'

# Work around Unity3D poor support for non-US locales

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Work around Unity3D poor support for non-US locales
export LANG=C'

# Use a per-session dedicated file for logs

APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'

# Keep compatibility with old archives

ARCHIVE_GAME_BIN_FILES_BASE_0='plantdaddy-linux-1.2.0 plantdaddy-linux-1.2_Data/MonoBleedingEdge UnityPlayer.so'
ARCHIVE_GAME_DATA_FILES_BASE_0='plantdaddy-linux-1.2_Data'
APP_MAIN_EXE_BASE_0='plantdaddy-linux-1.2.0'
APP_MAIN_ICON_BASE_0='plantdaddy-linux-1.2_Data/Resources/UnityPlayer.png'

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
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
use_archive_specific_value 'APP_MAIN_EXE'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
