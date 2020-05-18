#!/bin/sh -e
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
# The Sexy Brutale
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180224.1

# Set game-specific variables

GAME_ID='the-sexy-brutale'
GAME_NAME='The Sexy Brutale'

ARCHIVES_LIST='ARCHIVE_GOG'

ARCHIVE_GOG='setup_the_sexy_brutale_gog-1_(11101).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_sexy_brutale'
ARCHIVE_GOG_MD5='6d94492d797e199c1e67b05dabbc52e5'
ARCHIVE_GOG_SIZE='3400000'
ARCHIVE_GOG_VERSION='1.0-gog11101'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_PART1='setup_the_sexy_brutale_gog-1_(11101)-1.bin'
ARCHIVE_GOG_PART1_MD5='3158c4b5d6e9eafb9c4d1a79812601e0'
ARCHIVE_GOG_PART1_TYPE='innosetup'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='./steam_api.dll ./the?sexy?brutale.exe'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='./player_win_x86.pdb ./player_win_x86_s.pdb ./the?sexy?brutale_data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='the sexy brutale.exe'
APP_MAIN_ICON='the sexy brutale.exe'
APP_MAIN_ICON_RES='32 48 64 96 128 192 256'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Load common functions

target_version='2.5'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	if [ -e "$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh" ]; then
		PLAYIT_LIB2="$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh"
	elif [ -e './libplayit2.sh' ]; then
		PLAYIT_LIB2='./libplayit2.sh'
	else
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Check that all parts of the installer are present

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_PART1' 'ARCHIVE_GOG_PART1'
[ "$ARCHIVE_PART1" ] || set_archive_error_not_found 'ARCHIVE_GOG_PART1'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

for PKG in $PACKAGES_LIST; do
	organize_data "GAME_${PKG#PKG_}" "$PATH_GAME"
done

PKG='PKG_BIN'
extract_and_sort_icons_from 'APP_MAIN'
move_icons_to 'PKG_DATA'

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
