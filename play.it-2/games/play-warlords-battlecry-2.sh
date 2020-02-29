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
# Warlords Battlecry 2
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190301.1

# Set game-specific variables

GAME_ID='warlords-battlecry-2'
GAME_NAME='Warlords Battlecry II'

ARCHIVE_GOG='setup_warlords_battlecry2_2.0.0.4.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/warlords_battlecry_2'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_MD5='baa54ca0285182d18d532abfcbb8769f'
ARCHIVE_GOG_VERSION='1.04-gog2.0.0.4'
ARCHIVE_GOG_SIZE='940000'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='*.pdf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.asi *.m3d */*.cfg */*.ini battlecry?ii.exe binkw32.dll cpuinf32.dll mss32.dll wetstd32.dll terrain.cfg'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='*.xcr war4gfx.xcg war4int.xci wbc.dat campaignscenario customai customunitai data documentation english events fonts herodata music namingsets scenario soundfx tutorial video'

CONFIG_FILES='./*.cfg */*.cfg */*.ini */*.txt'
DATA_DIRS='./userdata'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='battlecry ii.exe'
APP_MAIN_ICON='battlecry ii.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

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

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launcher_write 'APP_MAIN'

# Store saved games and settings outside of WINE prefix

# shellcheck disable=SC2016
saves_path='$WINEPREFIX/drive_c/users/$(whoami)/My Documents/Warlords Battlecry II'
# shellcheck disable=SC2016
pattern='s#init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"#&'
pattern="$pattern\\nif [ ! -e \"$saves_path\" ]; then"
pattern="$pattern\\n\\tmkdir --parents \"${saves_path%/*}\""
pattern="$pattern\\n\\tln --symbolic \"\$PATH_DATA/userdata\" \"$saves_path\""
pattern="$pattern\\nfi#"
sed --in-place "$pattern" "${PKG_BIN_PATH}${PATH_BIN}"/*

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
