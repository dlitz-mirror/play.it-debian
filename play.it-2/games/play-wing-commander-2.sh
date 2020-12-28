#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2018-2021, BetaRays
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
# Wing Commander 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210111.1

# Set game-specific variables

GAME_ID='wing-commander-2'
GAME_NAME='Wing Commander Ⅱ'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='setup_wing_commander2_2.1.0.18.exe'
ARCHIVE_GOG_0_MD5='f94a7eb75e4ed454108d13189d003e9f'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_VERSION='1.0-gog2.1.0.18'
ARCHIVE_GOG_0_SIZE='49000'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/wing_commander_1_2'

ARCHIVE_DOC_MAIN_PATH='app'
ARCHIVE_DOC_MAIN_FILES='*.pdf'

ARCHIVE_GAME_MAIN_PATH='app'
ARCHIVE_GAME_MAIN_FILES='wc2.exe so1.exe so2.exe gamedat *.cfg'

CONFIG_FILES='./*.cfg'
DATA_DIRS='./gamedat'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='wc2.exe'
APP_MAIN_ICON='app/goggame-1207662653.ico'

APP_SO1_ID="${GAME_ID}_so1"
APP_SO1_TYPE='dosbox'
APP_SO1_EXE='so1.exe'
APP_SO1_ICON='app/goggame-1207662653.ico'
APP_SO1_NAME="$GAME_NAME - Special Operations 1"

APP_SO2_ID="${GAME_ID}_so2"
APP_SO2_TYPE='dosbox'
APP_SO2_EXE='so2.exe'
APP_SO2_ICON='app/goggame-1207662653.ico'
APP_SO2_NAME="$GAME_NAME - Special Operations 2"

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'

# Work around performance issues

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
config -set cpu cycles=fixed 8000
loadfix -32'
APP_SO1_PRERUN="$APP_MAIN_PRERUN"
APP_SO2_PRERUN="$APP_MAIN_PRERUN"

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
prepare_package_layout

# Extract icons

icons_get_from_workdir 'APP_MAIN' 'APP_SO1' 'APP_SO2'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

launchers_write 'APP_MAIN' 'APP_SO1' 'APP_SO2'

# Work around sound issues that can stuck the game during the first intro speech

pattern='s/^dosbox -c/export DOSBOX_SBLASTER_IRQ=5\n&/'
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place "$pattern" "${PKG_MAIN_PATH}${PATH_BIN}"/*
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
