#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# Heroes of Might and Magic 2
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180815.1

# Set game-specific variables

GAME_ID='heroes-of-might-and-magic-2'
GAME_NAME='Heroes of Might and Magic II: The Price of Loyalty'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR'

ARCHIVE_GOG_EN='setup_homm2_gold_2.1.0.29.exe'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/heroes_of_might_and_magic_2_gold_edition'
ARCHIVE_GOG_EN_MD5='b6785579d75e47936517a79374b17ebc'
ARCHIVE_GOG_EN_SIZE='480000'
ARCHIVE_GOG_EN_VERSION='2.1-gog2.1.0.29'

ARCHIVE_GOG_FR='setup_homm2_gold_french_2.1.0.29.exe'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/heroes_of_might_and_magic_2_gold_edition'
ARCHIVE_GOG_FR_MD5='c49d8f5d0f6d56e54cf6f9c7a526750f'
ARCHIVE_GOG_FR_SIZE='410000'
ARCHIVE_GOG_FR_VERSION='2.1-gog2.1.0.29'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='./eula ./help ./*.pdf ./*.txt'

ARCHIVE_GAME0_BIN_PATH='app'
ARCHIVE_GAME0_BIN_FILES='./*.exe ./*.cfg'

ARCHIVE_GAME1_BIN_PATH='sys'
ARCHIVE_GAME1_BIN_FILES='./wing32.dll'

ARCHIVE_GAME_MUSIC_PATH='app'
ARCHIVE_GAME_MUSIC_FILES='./music'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='./homm2.gog ./homm2.inst ./data ./games ./journals ./maps ./sound'

GAME_IMAGE='./homm2.inst'
GAME_IMAGE_TYPE='cdrom'

CONFIG_FILES='./*.cfg ./data/standard.hs'
DATA_DIRS='./games ./maps'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='heroes2.exe'
APP_MAIN_ICON='app/goggame-1207658785.ico'

APP_EDITOR_ID="${GAME_ID}-editor"
APP_EDITOR_NAME="$GAME_NAME - editor"
APP_EDITOR_TYPE='dosbox'
APP_EDITOR_EXE='editor2.exe'
APP_EDITOR_ICON='app/goggame-1207658785.ico'

PACKAGES_LIST='PKG_BIN PKG_MUSIC PKG_DATA'

PKG_MUSIC_ID="$GAME_ID-music"
PKG_MUSIC_DESCRIPTION='music'

PKG_DATA_ID="$GAME_ID-data"
PKG_DATA_ID_GOG_EN="${PKG_DATA_ID}-en"
PKG_DATA_ID_GOG_FR="${PKG_DATA_ID}-fr"
PKG_DATA_PROVIDE="$PKG_DATA_ID"
PKG_DATA_DESCRIPTION_GOG_EN='data - English version'
PKG_DATA_DESCRIPTION_GOG_FR='data - French version'

PKG_BIN_ID="$GAME_ID"
PKG_BIN_ID_GOG_EN="${PKG_BIN_ID}-en"
PKG_BIN_ID_GOG_FR="${PKG_BIN_ID}-fr"
PKG_BIN_PROVIDE="$PKG_BIN_ID"
PKG_BIN_DEPS_GOG_EN="$PKG_MUSIC_ID $PKG_DATA_ID_GOG_EN dosbox"
PKG_BIN_DEPS_GOG_FR="$PKG_MUSIC_ID $PKG_DATA_ID_GOG_FR dosbox"
PKG_BIN_DESCRIPTION_GOG_FR='French version'
PKG_BIN_DESCRIPTION_GOG_EN='English version'

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	for path in\
		'./'\
		"$XDG_DATA_HOME/play.it/"\
		"$XDG_DATA_HOME/play.it/play.it-2/lib/"\
		'/usr/local/share/games/play.it/'\
		'/usr/local/share/play.it/'\
		'/usr/share/games/play.it/'\
		'/usr/share/play.it/'
	do
		if [ -z "$PLAYIT_LIB2" ] && [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
	if [ -z "$PLAYIT_LIB2" ]; then
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icons

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN' 'APP_EDITOR'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN' 'APP_EDITOR'

# Build packages

use_archive_specific_value 'PKG_BIN_DEPS'
write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
