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
# Torchlight
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190221.1

# Set game-specific variables

GAME_ID='torchlight-1'
GAME_NAME='Torchlight'

ARCHIVE_GOG='setup_torchlight_1.15(a)_(23675).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/torchlight'
ARCHIVE_GOG_MD5='a29e51f55aae740f4046d227d33fa64b'
ARCHIVE_GOG_VERSION='1.15-gog23675'
ARCHIVE_GOG_SIZE='460000'
ARCHIVE_GOG_TYPE='innosetup'

ARCHIVE_GOG_OLD0='setup_torchlight_2.0.0.12.exe'
ARCHIVE_GOG_OLD0_MD5='4b721e1b3da90f170d66f42e60a3fece'
ARCHIVE_GOG_OLD0_VERSION='1.15-gog2.0.0.12'
ARCHIVE_GOG_OLD0_SIZE='460000'

ARCHIVE_DOC0_DATA_PATH='tmp'
ARCHIVE_DOC0_DATA_FILES='*.txt'

ARCHIVE_DOC1_DATA_PATH='.'
ARCHIVE_DOC1_DATA_FILES='*.pdf'
# Keep comaptibility with old archives
ARCHIVE_DOC1_DATA_PATH_GOG_OLD0='app'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='torchlight.exe *.cfg *.dll'
# Keep comaptibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='buildver.txt runicgames.ico torchlight.ico logo.bmp pak.zip icons music programs'
# Keep comaptibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_OLD0='app'

DATA_DIRS='./userdata'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='torchlight.exe'
APP_MAIN_ICON='torchlight.ico'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# Easier upgrade from packages generated with pre-20181021.2 scripts
PKG_DATA_PROVIDE='torchlight-data'

PKG_BIN_ID="$GAME_ID"
PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine xcursor glx"
# Easier upgrade from packages generated with pre-20181021.2 scripts
PKG_BIN_PROVIDE='torchlight'

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

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

PKG='PKG_BIN'
launcher_write 'APP_MAIN'

# Store saved games and settings outside of WINE prefix

# shellcheck disable=SC2016
saves_path='$WINEPREFIX/drive_c/users/$(whoami)/Application Data/runic games/torchlight'
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
