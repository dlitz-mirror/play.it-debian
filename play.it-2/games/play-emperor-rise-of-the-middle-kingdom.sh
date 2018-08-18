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
# Emperor: Rise of the Middle Kingdom
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180813.1

# Set game-specific variables

GAME_ID='emperor-rise-of-the-middle-kingdom'
GAME_NAME='Emperor: Rise of the Middle Kingdom'

ARCHIVE_GOG='setup_emperor_rise_of_the_middle_kingdom_2.0.0.2.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/emperor_rise_of_the_middle_kingdom'
ARCHIVE_GOG_MD5='5e50e84c028a85eafe5dd5f2aa277fea'
ARCHIVE_GOG_SIZE='820000'
ARCHIVE_GOG_VERSION='1.0.1.0-gog2.0.0.2'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='./*.txt ./*.pdf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='./*.exe ./*.cfg ./*.inf ./emperor.ini ./binkw32.dll ./ijl10.dll ./mss32.dll ./sierrapt.dll'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='./*.eng ./audio ./binks ./campaigns ./cities ./data ./dragon.ico ./model ./mp3dec.asi ./mssds3dh.m3d ./mssrsx.m3d ./res ./save'

CONFIG_FILES='./*.cfg ./*.ini'
DATA_DIRS='./campaigns ./save'

APP_WINETRICKS="vd=\$(xrandr|grep '\*'|awk '{print \$1}')"

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='emperor.exe'
APP_MAIN_ICON='dragon.ico'

APP_EDIT_ID="${GAME_ID}_editor"
APP_EDIT_NAME="$GAME_NAME - Editor"
APP_EDIT_TYPE='wine'
APP_EDIT_EXE='emperoredit.exe'
APP_EDIT_ICON='dragon.ico'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks xrandr"

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract game icons

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN' 'APP_EDIT'

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN' 'APP_EDIT'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
