#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Deponia 3: Goodbye Deponia
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180224.1

# Set game-specific variables

GAME_ID='deponia-3'
GAME_NAME='Deponia 3: Goodbye Deponia'

ARCHIVES_LIST='ARCHIVE_GOG ARCHIVE_HUMBLE'

ARCHIVE_GOG='gog_deponia_3_goodbye_deponia_2.1.0.4.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/goodbye_deponia'
ARCHIVE_GOG_MD5='9af5c29790e629635d27bc9368299516'
ARCHIVE_GOG_SIZE='3900000'
ARCHIVE_GOG_VERSION='3.3.3335-gog2.1.0.4'

ARCHIVE_HUMBLE='Deponia3_DEB_Full_3.2.3.3320_Multi_Daedalic_ESD.tar.gz'
ARCHIVE_HUMBLE_MD5='1fe92f0faf379541440895de68a1a14e'
ARCHIVE_HUMBLE_SIZE='3700000'
ARCHIVE_HUMBLE_VERSION='3.2.0.3320-humble'

ARCHIVE_ICONS_PACK='deponia-3_icons.tar.gz'
ARCHIVE_ICONS_PACK_MD5='d57dfcd4b23ff2c7f4163b9db20329f2'

ARCHIVE_DOC_PATH_GOG='data/noarch/game'
ARCHIVE_DOC_PATH_HUMBLE='Goodbye Deponia'
ARCHIVE_DOC_FILES='./documents ./version.txt'

ARCHIVE_DOC2_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC2_FILES_GOG='./*'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='Goodbye Deponia'
ARCHIVE_GAME_BIN_FILES='./config.ini ./Deponia3 ./libs64'

ARCHIVE_GAME_VIDEOS_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_VIDEOS_PATH_HUMBLE='Goodbye Deponia'
ARCHIVE_GAME_VIDEOS_FILES='./videos'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='Goodbye Deponia'
ARCHIVE_GAME_DATA_FILES='./characters ./data.vis ./lua ./scenes'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='./16x16 ./32x32 ./48x48 ./256x256'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Deponia3'
APP_MAIN_LIBS='libs64'
APP_MAIN_ICON_GOG='data/noarch/support/icon.png'
APP_MAIN_ICON_GOG_RES='256'

PACKAGES_LIST='PKG_VIDEOS PKG_DATA PKG_BIN'

PKG_VIDEOS_ID="${GAME_ID}-videos"
PKG_VIDEOS_DESCRIPTION='videos'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS_DEB="$PKG_VIDEOS_ID, $PKG_DATA_ID, libc6, libstdc++6, libgl1-mesa-glx | libgl1, libopenal1"
PKG_BIN_DEPS_ARCH="$PKG_VIDEOS_ID $PKG_DATA_ID libgl openal"

# Load common functions

target_version='2.5'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	if [ -e "$XDG_DATA_HOME/play.it/libplayit2.sh" ]; then
		PLAYIT_LIB2="$XDG_DATA_HOME/play.it/libplayit2.sh"
	elif [ -e './libplayit2.sh' ]; then
		PLAYIT_LIB2='./libplayit2.sh'
	else
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Try to load icons archive

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_ICONS' 'ARCHIVE_ICONS_PACK'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
if [ "$ARCHIVE_ICONS" ]; then
	(
		# shellcheck disable=SC2030
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
fi

PKG='PKG_BIN'
organize_data 'GAME_BIN' "$PATH_GAME"

PKG='PKG_VIDEOS'
organize_data 'GAME_VIDEOS' "$PATH_GAME"

PKG='PKG_DATA'
organize_data 'DOC'       "$PATH_DOC"
organize_data 'DOC2'      "$PATH_DOC"
organize_data 'GAME_DATA' "$PATH_GAME"

PKG='PKG_DATA'
# shellcheck disable=SC2031
if [ "$ARCHIVE_ICONS" ]; then
	organize_data 'ICONS' "$PATH_ICON_BASE"
elif [ "$ARCHIVE" = 'ARCHIVE_GOG' ]; then
	get_icon_from_temp_dir 'APP_MAIN'
fi

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
