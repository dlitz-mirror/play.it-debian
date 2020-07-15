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
# Heroes of Might and Magic 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200715.2

# Set game-specific variables

GAME_ID='heroes-of-might-and-magic-2'
GAME_NAME='Heroes of Might and Magic Ⅱ: The Price of Loyalty'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0'

ARCHIVE_GOG_EN_0='setup_homm2_gold_2.1.0.29.exe'
ARCHIVE_GOG_EN_0_MD5='b6785579d75e47936517a79374b17ebc'
ARCHIVE_GOG_EN_0_URL='https://www.gog.com/game/heroes_of_might_and_magic_2_gold_edition'
ARCHIVE_GOG_EN_0_SIZE='480000'
ARCHIVE_GOG_EN_0_VERSION='2.1-gog2.1.0.29'

ARCHIVE_GOG_FR_0='setup_homm2_gold_french_2.1.0.29.exe'
ARCHIVE_GOG_FR_0_MD5='c49d8f5d0f6d56e54cf6f9c7a526750f'
ARCHIVE_GOG_FR_0_URL='https://www.gog.com/game/heroes_of_might_and_magic_2_gold_edition'
ARCHIVE_GOG_FR_0_SIZE='410000'
ARCHIVE_GOG_FR_0_VERSION='2.1-gog2.1.0.29'

ARCHIVE_DOC_MAIN_PATH='app'
ARCHIVE_DOC_MAIN_FILES='readme.txt'

ARCHIVE_DOC_COMMON_PATH='app'
ARCHIVE_DOC_COMMON_FILES='eula help *.pdf h2camp.txt polcamp.txt'

ARCHIVE_GAME0_MAIN_PATH='app'
ARCHIVE_GAME0_MAIN_FILES='*.exe *.cfg homm2.gog homm2.inst games maps data/*.agg'

ARCHIVE_GAME1_MAIN_PATH='sys'
ARCHIVE_GAME1_MAIN_FILES='wing32.dll'

ARCHIVE_GAME_COMMON_PATH='app'
ARCHIVE_GAME_COMMON_FILES='journals music sound data/*.dat data/*.hs data/*.smk'

GAME_IMAGE='./homm2.inst'
GAME_IMAGE_TYPE='cdrom'

CONFIG_FILES='*.cfg data/standard.hs'
DATA_DIRS='./games ./maps'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='heroes2.exe'
APP_MAIN_ICON='app/goggame-1207658785.ico'

APP_EDITOR_ID="${GAME_ID}-editor"
APP_EDITOR_NAME="$GAME_NAME - editor"
APP_EDITOR_TYPE='dosbox'
APP_EDITOR_EXE='editor2.exe'
APP_EDITOR_ICON='app/goggame-1207658785.ico'

PACKAGES_LIST='PKG_MAIN PKG_COMMON'

PKG_COMMON_ID="$GAME_ID-common"
PKG_COMMON_DESCRIPTION='common data'

# Main package — common properties
PKG_MAIN_ID="$GAME_ID"
PKG_MAIN_PROVIDE="$PKG_MAIN_ID"
PKG_MAIN_DEPS="$PKG_COMMON_ID dosbox"
# Main package — English version
PKG_MAIN_ID_GOG_EN="${PKG_MAIN_ID}-en"
PKG_MAIN_DESCRIPTION_GOG_EN='English version'
# Main package — French version
PKG_MAIN_ID_GOG_FR="${PKG_MAIN_ID}-fr"
PKG_MAIN_DESCRIPTION_GOG_FR='French version'

# Load common functions

target_version='2.11'

if [ -z "$PLAYIT_LIB2" ]; then
	: "${XDG_DATA_HOME:="$HOME/.local/share"}"
	for path in\
		"$PWD"\
		"$XDG_DATA_HOME/play.it"\
		'/usr/local/share/games/play.it'\
		'/usr/local/share/play.it'\
		'/usr/share/games/play.it'\
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
prepare_package_layout

# Extract icons

PKG='PKG_COMMON'
icons_get_from_workdir 'APP_MAIN' 'APP_EDITOR'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_MAIN'
launchers_write 'APP_MAIN' 'APP_EDITOR'

# Build packages

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
