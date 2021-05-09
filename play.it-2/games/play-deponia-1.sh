#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Deponia
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210509.1

# Set game-specific variables

GAME_ID='deponia-1'
GAME_NAME='Deponia'

ARCHIVES_LIST='
ARCHIVE_GOG_0
ARCHIVE_HUMBLE_0'

ARCHIVE_GOG_0='gog_deponia_2.1.0.3.sh'
ARCHIVE_GOG_0_MD5='a3a21ba1c1ee68c9be2c755bd79e1b30'
ARCHIVE_GOG_0_SIZE='1800000'
ARCHIVE_GOG_0_VERSION='3.3.1357-gog2.1.0.3'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/deponia'

ARCHIVE_HUMBLE_0='Deponia_3.3.1358_Full_DEB_Multi_Daedalic_ESD.tar.gz'
ARCHIVE_HUMBLE_0_MD5='8ff4e21bbb4abcdc4059845acf7c7f04'
ARCHIVE_HUMBLE_0_VERSION='3.3.1358-humble160511'
ARCHIVE_HUMBLE_0_SIZE='1700000'

ARCHIVE_DOC_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC_DATA_PATH_HUMBLE='Deponia'
ARCHIVE_DOC_DATA_FILES='documents version.txt readme.txt'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='Deponia'
ARCHIVE_GAME_BIN_FILES='config.ini Deponia libs64/libavcodec.so.56 libs64/libavdevice.so.56 libs64/libavfilter.so.5 libs64/libavformat.so.56 libs64/libavutil.so.54 libs64/libswresample.so.1 libs64/libswscale.so.3 libs64/libz.so.1'

ARCHIVE_GAME_VIDEOS_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_VIDEOS_PATH_HUMBLE='Deponia'
ARCHIVE_GAME_VIDEOS_FILES='videos'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='Deponia'
ARCHIVE_GAME_DATA_FILES='characters data.vis lua scenes'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Deponia'
APP_MAIN_LIBS='libs64'
# No icon is provided by the Humble Bundle archive
APP_MAIN_ICON_GOG='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_VIDEOS PKG_DATA PKG_BIN'

PKG_VIDEOS_ID="${GAME_ID}-videos"
PKG_VIDEOS_DESCRIPTION='videos'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_VIDEOS_ID $PKG_DATA_ID glibc libstdc++ glx openal"

# Ensure easy upgrades from packages generated with pre-20201124.7 scripts

PKG_BIN_PROVIDE='deponia'
PKG_DATA_PROVIDE='deponia-data'
PKG_VIDEOS_PROVIDE='deponia-videos'

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

# Get game icon

case "$ARCHIVE" in
	('ARCHIVE_GOG_'*)
		PKG='PKG_DATA'
		icons_get_from_workdir 'APP_MAIN'
	;;
esac

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
