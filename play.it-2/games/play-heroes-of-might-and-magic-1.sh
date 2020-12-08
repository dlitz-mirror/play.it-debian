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
# Heroes of Might and Magic: A Strategic Quest
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200715.6

# Set game-specific variables

GAME_ID='heroes-of-might-and-magic-1'
GAME_NAME='Heroes of Might and Magic: A Strategic Quest'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_1
ARCHIVE_GOG_FR_1
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0'

ARCHIVE_GOG_EN_1='setup_heroes_of_might_and_magic_1.2_(1.1)_(33754).exe'
ARCHIVE_GOG_EN_1_MD5='f3100c6547ef1bb82af6dd6fec66bcbf'
ARCHIVE_GOG_EN_1_URL='https://www.gog.com/game/heroes_of_might_and_magic'
ARCHIVE_GOG_EN_1_SIZE='630000'
ARCHIVE_GOG_EN_1_VERSION='1.2-gog33754'

ARCHIVE_GOG_FR_1='setup_heroes_of_might_and_magic_1.2_(1.1)_(french)_(33754).exe'
ARCHIVE_GOG_FR_1_MD5='ed647dbfc98cd59dba885dc4fd005a62'
ARCHIVE_GOG_FR_1_URL='https://www.gog.com/game/heroes_of_might_and_magic'
ARCHIVE_GOG_FR_1_SIZE='630000'
ARCHIVE_GOG_FR_1_VERSION='1.2-gog33754'

ARCHIVE_GOG_EN_0='setup_heroes_of_might_and_magic_2.3.0.45.exe'
ARCHIVE_GOG_EN_0_MD5='2cae1821085090e30e128cd0a76b0d21'
ARCHIVE_GOG_EN_0_SIZE='530000'
ARCHIVE_GOG_EN_0_VERSION='1.0-gog2.3.0.45'

ARCHIVE_GOG_FR_0='setup_heroes_of_might_and_magic_french_2.3.0.45.exe'
ARCHIVE_GOG_FR_0_MD5='9ec736a2a1b97dc36257f583f42864ac'
ARCHIVE_GOG_FR_0_SIZE='530000'
ARCHIVE_GOG_FR_0_VERSION='1.0-gog2.3.0.45'

ARCHIVE_DOC_COMMON_PATH='.'
ARCHIVE_DOC_COMMON_FILES='help *.pdf *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_COMMON_PATH_GOG_EN_0='app'
ARCHIVE_DOC_COMMON_PATH_GOG_FR_0='app'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='*.exe *.cfg wail32.dll wing.32 data/campaign.hs data/heroes.agg data/standard.hs games maps/*.map'
# Keep compatibility with old archives
ARCHIVE_GAME_MAIN_PATH_GOG_EN_0='app'
ARCHIVE_GAME_MAIN_PATH_GOG_FR_0='app'

# Keep compatibility with old archives
ARCHIVE_GAME0_MAIN_PATH='sys'
ARCHIVE_GAME0_MAIN_FILES='wing32.dll'

ARCHIVE_GAME_COMMON_PATH='.'
ARCHIVE_GAME_COMMON_FILES='data maps/*.cmp homm1.gog'
# Keep compatibility with old archives
ARCHIVE_GAME_COMMON_PATH_GOG_EN_0='app'
ARCHIVE_GAME_COMMON_PATH_GOG_FR_0='app'

GAME_IMAGE='./homm1.gog'
GAME_IMAGE_TYPE='iso'

CONFIG_FILES='*.cfg'
DATA_DIRS='./games ./maps'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='heroes.exe'
APP_MAIN_ICON='app/goggame-1207658748.ico'

APP_EDITOR_ID="${GAME_ID}-editor"
APP_EDITOR_NAME="$GAME_NAME - editor"
APP_EDITOR_TYPE='dosbox'
APP_EDITOR_EXE='editor.exe'
APP_EDITOR_ICON='app/goggame-1207658748.ico'

PACKAGES_LIST='PKG_MAIN PKG_COMMON'

PKG_COMMON_ID="${GAME_ID}-commmon"

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

PKG='PKG_MAIN'
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
