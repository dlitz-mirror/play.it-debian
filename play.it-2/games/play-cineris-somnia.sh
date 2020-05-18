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
# Cineris Somnia
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190622.2

# Set game-specific variables

GAME_ID='cineris-somnia'
GAME_NAME='Cineris Somnia'

ARCHIVE_PLAYISM='CINERIS_SOMNIA_PLAYISM_20181109.zip'
ARCHIVE_PLAYISM_URL='https://playism.com/product/cineris-somnia'
ARCHIVE_PLAYISM_MD5='c25ea529ffb12b0e055d05117c5bc24d'
ARCHIVE_PLAYISM_SIZE='3200000'
ARCHIVE_PLAYISM_VERSION='1.01-playism20181109'
ARCHIVE_PLAYISM_TYPE='zip'

ARCHIVE_DOC_DATA_PATH='20181109_101'
ARCHIVE_DOC_DATA_FILES='*.txt'

ARCHIVE_GAME_BIN_PATH='20181109_101'
ARCHIVE_GAME_BIN_FILES='Cineris?Somnia.exe Cineris?Somnia_Data/Mono Cineris?Somnia_Data/Managed'

ARCHIVE_GAME_DATA_PATH='20181109_101'
ARCHIVE_GAME_DATA_FILES='Cineris?Somnia_Data/Resources Cineris?Somnia_Data/level* Cineris?Somnia_Data/*.assets Cineris?Somnia_Data/sharedassets* Cineris?Somnia_Data/mainData'

DATA_DIRS='./userdata'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='Cineris Somnia.exe'
APP_MAIN_ICON='Cineris Somnia.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine alsa glx"

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

# Store saved games outside of WINE prefix

# shellcheck disable=SC2016
saves_path='$WINEPREFIX/drive_c/users/$(whoami)/AppData/LocalLow/Nayuta Studio/Cineris Somnia/'
# shellcheck disable=SC2016
pattern='s#init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"#&'
pattern="$pattern\\nif [ ! -e \"$saves_path\" ]; then"
pattern="$pattern\\n\\tmkdir --parents \"${saves_path%/*}\""
pattern="$pattern\\n\\tln --symbolic \"\$PATH_DATA/userdata\" \"$saves_path\""
pattern="$pattern\\nfi#"
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place "$pattern" "${PKG_BIN_PATH}${PATH_BIN}"/*
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
