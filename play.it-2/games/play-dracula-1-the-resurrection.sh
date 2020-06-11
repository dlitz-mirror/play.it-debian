#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotlsashplay.it>
# Copyright (c) 2018-2020, Mopi
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
# Dracula: The Resurrection
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201129.10

# Set game-specific variables

GAME_ID='dracula-1-the-resurrection'
GAME_NAME='Dracula: The Resurrection'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='setup_dracula_the_resurrection_2.1.0.5.exe'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/dracula_trilogy'
ARCHIVE_GOG_0_MD5='4f3ac9ea7b645ec3bc0ec2c9de24be79'
ARCHIVE_GOG_0_SIZE='1400000'
ARCHIVE_GOG_0_VERSION='1.0-gog2.1.0.5'
ARCHIVE_GOG_0_TYPE='rar'
ARCHIVE_GOG_0_PART1='setup_dracula_the_resurrection_2.1.0.5.bin'
ARCHIVE_GOG_0_PART1_MD5='284f93ed3799267604cc1f25a2329699'
ARCHIVE_GOG_0_PART1_TYPE='rar'

ARCHIVE_DOC_DATA_PATH='game'
ARCHIVE_DOC_DATA_FILES='*.pdf'

ARCHIVE_GAME_BIN_PATH='game'
ARCHIVE_GAME_BIN_FILES='dracula.exe *.dll'

ARCHIVE_GAME_DATA_PATH='game'
ARCHIVE_GAME_DATA_FILES='*.tst *.vr *.pcx *.wav *.lst *.4xm a18tst compiler.dat cursor1.gif cursor2.gif llload.bmp nomouse.com nomouse.pif nomouse.sp retour.gif signal.gif test.sav dracula.ico'

DATA_FILES='./Saved_?.bin'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='dracula.exe'
APP_MAIN_ICON='dracula.ico'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Run the game in a virtual WINE desktop to avoid messed up display

APP_WINETRICKS="$APP_WINETRICKS vd=\$(xrandr|awk '/\\*/ {print \$1}')"

# Set Window version to Windows 98, otherwise menu can not be opened in-game

APP_WINETRICKS="$APP_WINETRICKS win98"

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

extract_data_from "$SOURCE_ARCHIVE_PART1"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Extract icon

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
