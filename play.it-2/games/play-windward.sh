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
# Windward
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210515.3

# Set game-specific variables

GAME_ID='windward'
GAME_NAME='Windward'

ARCHIVE_BASE_GOG_2='gog_windward_2.36.0.40.sh'
ARCHIVE_BASE_GOG_2_MD5='6afbdcfda32a6315139080822c30396a'
ARCHIVE_BASE_GOG_2_TYPE='mojosetup'
ARCHIVE_BASE_GOG_2_SIZE='130000'
ARCHIVE_BASE_GOG_2_VERSION='20170617.0-gog2.36.0.40'

ARCHIVE_BASE_GOG_1='gog_windward_2.35.0.39.sh'
ARCHIVE_BASE_GOG_1_MD5='12fffaf6f405f36d2f3a61b4aaab89ba'
ARCHIVE_BASE_GOG_1_TYPE='mojosetup'
ARCHIVE_BASE_GOG_1_SIZE='130000'
ARCHIVE_BASE_GOG_1_VERSION='20160707.0-gog2.35.0.39'

ARCHIVE_BASE_GOG_0='gog_windward_2.35.0.38.sh'
ARCHIVE_BASE_GOG_0_MD5='f5ce09719bf355e48d2eac59b84592d1'
ARCHIVE_BASE_GOG_0_TYPE='mojosetup'
ARCHIVE_BASE_GOG_0_SIZE='120000'
ARCHIVE_BASE_GOG_0_VERSION='20160707-gog2.35.0.38'

ARCHIVE_BASE_HUMBLE_1='WindwardLinux_HB_1505248588.zip'
ARCHIVE_BASE_HUMBLE_1_MD5='9ea99157d13ae53905757f2fb3ab5b54'
ARCHIVE_BASE_HUMBLE_1_SIZE='130000'
ARCHIVE_BASE_HUMBLE_1_VERSION='20160707.0-humble170912'

ARCHIVE_BASE_HUMBLE_0='WindwardLinux_HB.zip'
ARCHIVE_BASE_HUMBLE_0_MD5='f2d1a9a91055ecb6c5ce1bd7e3ddd803'
ARCHIVE_BASE_HUMBLE_0_SIZE='130000'
ARCHIVE_BASE_HUMBLE_0_VERSION='20160707-humble1'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='Windward'
ARCHIVE_GAME_BIN_FILES='Windward.x86 Windward_Data/Plugins Windward_Data/Mono'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='Windward'
ARCHIVE_GAME_DATA_FILES='Windward_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Windward.x86'
APP_MAIN_ICON='Windward_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc libstdc++ glu xcursor"

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

# Keep compatibility with old archives

ARCHIVE_GAME_BIN_PATH_HUMBLE_0='.'
ARCHIVE_GAME_DATA_PATH_HUMBLE_0='.'

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

# Get game icon

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

#print instructions

print_instructions

exit 0
