#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, BetaRays
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
# Wing Commander
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200209.1

# Set game-specific variables

GAME_ID='wing-commander-1'
GAME_NAME='Wing Commander'

ARCHIVE_GOG='setup_wing_commander_1.0_(28045).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/wing_commander_1_2'
ARCHIVE_GOG_MD5='850542ba9a543378a4894156b41ce511'
ARCHIVE_GOG_VERSION='1.0-gog28045'
ARCHIVE_GOG_SIZE='45000'

ARCHIVE_GOG_OLD0='setup_wing_commander_2.1.0.18.exe'
ARCHIVE_GOG_OLD0_MD5='a4a3a355489e66bcecd34d1d9041ebb5'
ARCHIVE_GOG_OLD0_VERSION='1.0-gog2.1.0.18'
ARCHIVE_GOG_OLD0_SIZE='49000'
ARCHIVE_GOG_OLD0_TYPE='innosetup'

ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='*.pdf'
# Keep compatibility with old archives
ARCHIVE_DOC_MAIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME0_MAIN_PATH='.'
ARCHIVE_GAME0_MAIN_FILES='wc.exe sm2.exe gamedat *.cfg'
# Keep compatibility with old archives
ARCHIVE_GAME0_MAIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME1_MAIN_PATH='__support/save'
ARCHIVE_GAME1_MAIN_FILES='gamedat'

CONFIG_FILES='./*.cfg'
DATA_DIRS='./gamedat'

APP_MAIN_TYPE='dosbox'
APP_MAIN_PRERUN='config -set cpu cycles=fixed 4000
loadfix -1'
APP_MAIN_EXE='wc.exe'
APP_MAIN_ICON='app/goggame-1207662643.ico'

APP_SM2_ID="${GAME_ID}_sm2"
APP_SM2_TYPE='dosbox'
APP_SM2_PRERUN="$APP_MAIN_PRERUN"
APP_SM2_EXE='sm2.exe'
APP_SM2_ICON='app/goggame-1207662643.ico'
APP_SM2_NAME="$GAME_NAME - The Secret Missions 2 - Crusade"

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'
# Easier upgrade from packages generated with pre-20190224.1 scripts
PKG_MAIN_PROVIDE='wing-commander'

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

icons_get_from_workdir 'APP_MAIN' 'APP_SM2'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

launchers_write 'APP_MAIN' 'APP_SM2'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
