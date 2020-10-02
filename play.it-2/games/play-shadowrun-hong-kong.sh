#!/bin/sh
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
# Shadowrun: Hong Kong
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201002.1

# Set game-specific variables

GAME_ID='shadowrun-hong-kong'
GAME_NAME='Shadowrun: Hong Kong'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='gog_shadowrun_hong_kong_extended_edition_2.8.0.11.sh'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/shadowrun_hong_kong_extended_edition'
ARCHIVE_GOG_0_MD5='643ba68e47c309d391a6482f838e46af'
ARCHIVE_GOG_0_SIZE='12000000'
ARCHIVE_GOG_0_VERSION='3.1.2-gog2.8.0.11'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='ShadowrunEditor SRHK SRHK_Data/Mono SRHK_Data/Plugins'

ARCHIVE_GAME_DATA_BERLIN_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_BERLIN_FILES='SRHK_Data/StreamingAssets/standalone/berlin'

ARCHIVE_GAME_DATA_HONGKONG_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_HONGKONG_FILES='SRHK_Data/StreamingAssets/standalone/hongkong'

ARCHIVE_GAME_DATA_SEATTLE_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_SEATTLE_FILES='SRHK_Data/StreamingAssets/standalone/seattle'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='dictionary SRHK_Data'

DATA_DIRS='./DumpBox ./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='SRHK'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='SRHK_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_DATA_BERLIN PKG_DATA_HONGKONG PKG_DATA_SEATTLE PKG_DATA PKG_BIN'

PKG_DATA_BERLIN_ID="${GAME_ID}-data-berlin"
PKG_DATA_BERLIN_DESCRIPTION='data - Berlin'

PKG_DATA_HONGKONG_ID="${GAME_ID}-data-hongkong"
PKG_DATA_HONGKONG_DESCRIPTION='data - Hong Kong'

PKG_DATA_SEATTLE_ID="${GAME_ID}-data-seattle"
PKG_DATA_SEATTLE_DESCRIPTION='data - Seattle'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_BERLIN $PKG_DATA_HONGKONG $PKG_DATA_SEATTLE $PKG_DATA_ID glu xcursor libxrandr alsa"

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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Add missing execution permissions to the editor binary

chmod +x "${PKG_BIN_PATH}${PATH_GAME}/ShadowrunEditor"

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
