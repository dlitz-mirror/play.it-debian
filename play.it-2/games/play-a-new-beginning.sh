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
# A New Beginning
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210515.2

# Set game-specific variables

GAME_ID='a-new-beginning'
GAME_NAME='A New Beginning'

ARCHIVE_BASE_0='setup_a_new_beginning_final_cut_2.2.0.7.exe'
ARCHIVE_BASE_0_MD5='7f0acf99bfbaabb46dfcba12340098df'
ARCHIVE_BASE_0_TYPE='rar'
ARCHIVE_BASE_0_PART1='setup_a_new_beginning_final_cut_2.2.0.7.bin'
ARCHIVE_BASE_0_PART1_MD5='1babc74ae7f29ff6ce16ea9fd3e4d3ff'
ARCHIVE_BASE_0_PART1_TYPE='rar'
ARCHIVE_BASE_0_SIZE='4100000'
ARCHIVE_BASE_0_VERSION='1.0-gog2.2.0.7'
ARCHIVE_BASE_0_GOGID='1207659150'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/a_new_beginning'

ARCHIVE_DOC_DATA_PATH='game'
ARCHIVE_DOC_DATA_FILES='*.pdf'

ARCHIVE_GAME0_BIN_PATH='game'
ARCHIVE_GAME0_BIN_FILES='anb.exe VisionaireConfigurationTool.exe avcodec-54.dll avformat-54.dll avutil-52.dll libsndfile-1.dll openal32.dll SDL2.dll swresample-0.dll swscale-2.dll zlib1.dll'

ARCHIVE_GAME1_BIN_PATH='support/app'
ARCHIVE_GAME1_BIN_FILES='config.ini'

ARCHIVE_GAME_DATA_PATH='game'
ARCHIVE_GAME_DATA_FILES='banner.jpg characters data.vis documents folder.jpg Languages.xml scenes videos'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='anb.exe'
APP_MAIN_ICON='anb.exe'

APP_WINETRICKS='dotnet40'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine winetricks"

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

extract_data_from "$SOURCE_ARCHIVE_PART1"
prepare_package_layout

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Use persistent storage for saved games and settings

CONFIG_FILES="${CONFIG_FILES} ./userdir/config.ini"
DATA_DIRS="${DATA_DIRS} ./userdir/Savegames"
APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"'
userdir:users/${USER}/Local Settings/Application Data/Daedalic Entertainment/A New Beginning - Final Cut'

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
