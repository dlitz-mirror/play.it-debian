#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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
# Bio Menace
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190422.1

# Set game-specific variables

GAME_ID='bio-menace'
GAME_NAME='Bio Menace'

ARCHIVE_GOG='gog_bio_menace_2.0.0.2.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/bio_menace'
ARCHIVE_GOG_MD5='75167ee3594dd44ec8535b29b90fe4eb'
ARCHIVE_GOG_SIZE='14000'
ARCHIVE_GOG_VERSION='1.1-gog2.0.0.2'

ARCHIVE_DOC0_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC0_MAIN_FILES='*.pdf *.txt'

ARCHIVE_DOC1_MAIN_PATH='data/noarch/data'
ARCHIVE_DOC1_MAIN_FILES='*.txt'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='*.bm? *.conf *.exe biopatch.zip'

CONFIG_FILES='./*.conf ./config.bm?'
DATA_FILES='./SAVEGAM*'

APP_1_ID="${GAME_ID}-1"
APP_1_NAME="$GAME_NAME - Episode One: Dr. Mangleʼs Lab"
APP_1_TYPE='dosbox'
APP_1_EXE='bmenace1.exe'
APP_1_ICON='data/noarch/support/icon.png'

APP_2_ID="${GAME_ID}-2"
APP_2_NAME="$GAME_NAME - Episode Two: The Hidden Lab"
APP_2_TYPE='dosbox'
APP_2_EXE='bmenace2.exe'
APP_2_ICON='data/noarch/support/icon.png'

APP_3_ID="${GAME_ID}-3"
APP_3_NAME="$GAME_NAME - Episode Three: Master Cain"
APP_3_TYPE='dosbox'
APP_3_EXE='bmenace3.exe'
APP_3_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'

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
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get icon

icons_get_from_workdir 'APP_1' 'APP_2' 'APP_3'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

launchers_write 'APP_1' 'APP_2' 'APP_3'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
