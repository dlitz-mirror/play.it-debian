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
# Beautiful Desolation
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210518.1

# Set game-specific variables

GAME_ID='beautiful-desolation'
GAME_NAME='Beautiful Desolation'

ARCHIVE_BASE_1='beautiful_desolation_1_0_5_5_44769.sh'
ARCHIVE_BASE_1_MD5='0656c2fb0ef2ad2bc0087d16f5d02e46'
ARCHIVE_BASE_1_TYPE='mojosetup_unzip'
ARCHIVE_BASE_1_VERSION='1.0.5.5-gog44769'
ARCHIVE_BASE_1_SIZE='16000000'
ARCHIVE_BASE_1_URL='https://www.gog.com/game/beautiful_desolation'

ARCHIVE_BASE_0='beautiful_desolation_1_0_3_9_38147.sh'
ARCHIVE_BASE_0_MD5='18fe66cffc59f033a4d057233b1ebb1f'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'
ARCHIVE_BASE_0_VERSION='1.0.3.9-gog38147'
ARCHIVE_BASE_0_SIZE='14000000'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='desolation.x86_64 desolation_Data/Mono/x86_64 desolation_Data/Plugins/x86_64'

ARCHIVE_GAME_DATA_VIDEO_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_VIDEO_FILES='desolation_Data/StreamingAssets/videoEncoded desolation_Data/StreamingAssets/videoEncoded_webm desolation_Data/StreamingAssets/bundles/videoencoded_mp4-media_*'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='desolation_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='desolation.x86_64'
APP_MAIN_ICON='desolation_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA_VIDEO PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_DATA_VIDEO_ID="${PKG_DATA_ID}-video"
PKG_DATA_VIDEO_DESCRIPTION="${PKG_DATA_DESCRIPTION} - video"
PKG_DATA_DEPS="${PKG_DATA_DEPS} ${PKG_DATA_VIDEO_ID}"

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc libstdc++ gtk2 libgdk_pixbuf-2.0.so.0 libgobject-2.0.so.0 libglib-2.0.so.0"

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

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

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
