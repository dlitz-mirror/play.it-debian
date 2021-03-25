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
# My Memory of Us
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210520.5

# Set game-specific variables

GAME_ID='my-memory-of-us'
GAME_NAME='My Memory of Us'

ARCHIVE_BASE_0='setup_my_memory_of_us_1.13057.1_(64bit)_(25548).exe'
ARCHIVE_BASE_0_MD5='44d0900cd3677e8811eea558ed237c56'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_PART1='setup_my_memory_of_us_1.13057.1_(64bit)_(25548)-1.bin'
ARCHIVE_BASE_0_PART1_MD5='a2e2e199681aaa136cc109df60b6eefc'
ARCHIVE_BASE_0_PART1_TYPE='innosetup'
ARCHIVE_BASE_0_SIZE='5000000'
ARCHIVE_BASE_0_VERSION='1.13057.1-gog25548'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/my_memory_of_us'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='mmou.exe mmou_data/plugins mmou_data/mono galaxy64.dll galaxycsharpglue.dll'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='mmou_data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='mmou.exe'
APP_MAIN_ICON='mmou.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="${PKG_DATA_ID} wine"
PKG_BIN_DEPS_ARCH='gst-plugins-good gst-libav'
PKG_BIN_DEPS_DEB='gstreamer1.0-plugins-good, gstreamer1.0-libav'
PKG_BIN_DEPS_GENTOO='media-libs/gst-plugins-good media-plugins/gst-plugins-libav'

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

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

# Clean up temporary directories

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Use persistent storage for game progress

DATA_DIRS="${DATA_DIRS} userdata/PERSISTENT_SAVES userdata/SAVES"
DATA_FILES="${DATA_FILES} userdata/Savvy.dat"
APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"'
userdata:users/${USER}/AppData/LocalLow/Juggler Games/My Memory of Us'

# Use persistent storage for settings

REGISTRY_KEY='HKEY_CURRENT_USER\Software\Juggler Games\My Memory of Us'
REGISTRY_DUMP='registry-dumps/settings.reg'

CONFIG_DIRS="${CONFIG_DIRS} ./$(dirname "$REGISTRY_DUMP")"
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
