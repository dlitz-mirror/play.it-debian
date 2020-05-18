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
# Cæsar Ⅲ
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200321.1

# Set game-specific variables

GAME_ID='caesar-3'
GAME_NAME='Cæsar Ⅲ'

ARCHIVE_GOG='setup_caesar3_2.0.0.9.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/caesar_3'
ARCHIVE_GOG_MD5='2ee16fab54493e1c2a69122fd2e56635'
ARCHIVE_GOG_SIZE='550000'
ARCHIVE_GOG_VERSION='1.1-gog2.0.0.9'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='readme.txt *.pdf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe *.inf *.ini'

ARCHIVE_GAME_MOVIES_PATH='app'
ARCHIVE_GAME_MOVIES_FILES='smk'

ARCHIVE_GAME_SOUNDS_PATH='app'
ARCHIVE_GAME_SOUNDS_FILES='wavs'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='555 *.555 *.emp *.eng *.map *.sg2 c3_model.txt mission1.pak'

CONFIG_FILES='./caesar3.ini'
DATA_FILES='./c3_model.txt ./status.txt ./*.sav'

APP_WINETRICKS="vd=\$(xrandr|awk '/\\*/ {print \$1}')"

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='c3.exe'
APP_MAIN_ICON='c3.exe'

PACKAGES_LIST='PKG_MOVIES PKG_SOUNDS PKG_DATA PKG_BIN'

PKG_MOVIES_ID="${GAME_ID}-movies"
PKG_MOVIES_DESCRIPTION='movies'

PKG_SOUNDS_ID="${GAME_ID}-sounds"
PKG_SOUNDS_DESCRIPTION='sounds'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DEPS="$PKG_MOVIES_ID $PKG_SOUNDS_ID"

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks xrandr"

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Write launchers

launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
