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
# A Vampyre Story
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210501.3

# Set game-specific variables

GAME_ID='a-vampyre-story'
GAME_NAME='A Vampyre Story'

ARCHIVES_LIST='
ARCHIVE_BASE_0'

ARCHIVE_BASE_0='setup_a_vampyre_story_1.0_(43163).exe'
ARCHIVE_BASE_0_MD5='f2441fb51aac6eaca5e97f6e6a3ea0ab'
ARCHIVE_BASE_0_TYPE='innosetup_nolowercase'
ARCHIVE_BASE_0_PART1='setup_a_vampyre_story_1.0_(43163)-1.bin'
ARCHIVE_BASE_0_PART1_MD5='2c652e191d82c70fbbe5af4d259f3ba2'
ARCHIVE_BASE_0_PART1_TYPE='innosetup_nolowercase'
ARCHIVE_BASE_0_VERSION='1.0-gog43163'
ARCHIVE_BASE_0_SIZE='3200000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/a_vampyre_story'

ARCHIVE_DOC_DATA_PATH='game'
ARCHIVE_DOC_DATA_FILES='license.txt readme.txt'

ARCHIVE_GAME_BIN_PATH='game'
ARCHIVE_GAME_BIN_FILES='main.exe *.dll *.pyd __init__.pyc library.zip *.pyo w9xpopen.exe'

ARCHIVE_GAME_DATA_PATH='game'
ARCHIVE_GAME_DATA_FILES='assets etc tcl icon.ico installer.bmp'

CONFIG_DIRS='./etc'
DATA_DIRS='./assets/scripts'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='main.exe'
APP_MAIN_ICON='icon.ico'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine"

# Set up a WINE virtual desktop on first launch, using the current desktop resolution

APP_WINETRICKS="${APP_WINETRICKS} vd=\$(xrandr|awk '/\\*/ {print \$1}')"
PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks xrandr"

# Disable CSMT rendering, as it messes up with movies playback
# cf. https://bugs.winehq.org/show_bug.cgi?id=37659

APP_WINETRICKS="${APP_WINETRICKS} csmt=off"
PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks"

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary directories

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
