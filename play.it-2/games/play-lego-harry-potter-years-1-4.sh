#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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
# Lego Harry Potter Years 1-4
# build native packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20190602.3

# Set game-specific variables

GAME_ID='lego-harry-potter-years-1-4'
GAME_NAME='Lego Harry Potter Years 1-4'

ARCHIVE_GOG='setup_lego_harry_potter_1-4_1.0_(17966).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/lego_harry_potter_years_14'
ARCHIVE_GOG_MD5='21ddbc82a225687a69044e9baee7109b'
ARCHIVE_GOG_VERSION='1.0.0389-gog17966'
ARCHIVE_GOG_SIZE='6300000'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_PART1='setup_lego_harry_potter_1-4_1.0_(17966)-1.bin'
ARCHIVE_GOG_PART1_MD5='ab78edad26acef08eb3a656dfbdf476e'
ARCHIVE_GOG_PART1_TYPE='innosetup'
ARCHIVE_GOG_PART2='setup_lego_harry_potter_1-4_1.0_(17966)-2.bin'
ARCHIVE_GOG_PART2_MD5='0ebb7b7a5772245258e53092c25a4708'
ARCHIVE_GOG_PART2_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='app/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='legoharrypotter.exe language_setup.exe'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='language_setup.ini language_setup.png game.dat game1.dat game2.dat game3.dat game4.dat game5.dat game6.dat'

CONFIG_FILES='./language_setup.ini'

APP_WINETRICKS="vd=\$(xrandr|awk '/\\*/ {print \$1}') directx9"
APP_MAIN_TYPE='wine'
APP_MAIN_PRERUN='pulseaudio --start'
APP_MAIN_EXE='legoharrypotter.exe'
APP_MAIN_ICON='legoharrypotter.exe'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_TYPE='wine'
APP_CONFIG_EXE='language_setup.exe'
APP_CONFIG_ICON='language_setup.png'
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_CAT='Settings'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks glx pulseaudio"

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

# Extract icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_CONFIG'

# Build package
PKG='PKG_DATA'
icons_linking_postinst 'APP_CONFIG'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
