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
# The Dark Eye: Memoria
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200622.2

# Set game-specific variables

GAME_ID='the-dark-eye-memoria'
GAME_NAME='The Dark Eye: Memoria'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0
'

ARCHIVE_GOG_1='setup_memoria_1.2.3.0341_(18923).exe'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/memoria'
ARCHIVE_GOG_1_MD5='b939d4aa2aabf2bac1d527609e76ed0f'
ARCHIVE_GOG_1_SIZE='9100000'
ARCHIVE_GOG_1_VERSION='1.2.3.0341-gog18923'
ARCHIVE_GOG_1_PART1='setup_memoria_1.2.3.0341_(18923)-1.bin'
ARCHIVE_GOG_1_PART1_MD5='3067662d212dfb297106a24ffd474cbd'
ARCHIVE_GOG_1_PART1_TYPE='innosetup'
ARCHIVE_GOG_1_PART2='setup_memoria_1.2.3.0341_(18923)-2.bin'
ARCHIVE_GOG_1_PART2_MD5='24ff575f72e8b05b529aaaef99372090'
ARCHIVE_GOG_1_PART2_TYPE='innosetup'
ARCHIVE_GOG_1_PART3='setup_memoria_1.2.3.0341_(18923)-3.bin'
ARCHIVE_GOG_1_PART3_MD5='88a98736110a7a59633a5bec12411f22'
ARCHIVE_GOG_1_PART3_TYPE='innosetup'

ARCHIVE_GOG_0='setup_memoria_2.0.0.3.exe'
ARCHIVE_GOG_0_MD5='847c7b5e27a287d6e0e17e63bfb14fff'
ARCHIVE_GOG_0_SIZE='9100000'
ARCHIVE_GOG_0_VERSION='1.36.0053-gog2.0.0.3'
ARCHIVE_GOG_0_PART1='setup_memoria_2.0.0.3-1.bin'
ARCHIVE_GOG_0_PART1_MD5='e656464607e4d8599d599ed5b6b29fca'
ARCHIVE_GOG_0_PART1_TYPE='innosetup'
ARCHIVE_GOG_0_PART2='setup_memoria_2.0.0.3-2.bin'
ARCHIVE_GOG_0_PART2_MD5='593d57e8022c65660394c5bc5a333fe8'
ARCHIVE_GOG_0_PART2_TYPE='innosetup'
ARCHIVE_GOG_0_PART3='setup_memoria_2.0.0.3-3.bin'
ARCHIVE_GOG_0_PART3_MD5='0f8ef0abab77f3885aa4f8f9e58611eb'
ARCHIVE_GOG_0_PART3_TYPE='innosetup'
ARCHIVE_GOG_0_PART4='setup_memoria_2.0.0.3-4.bin'
ARCHIVE_GOG_0_PART4_MD5='0935149a66284bdc13659beafed2575f'
ARCHIVE_GOG_0_PART4_TYPE='innosetup'
ARCHIVE_GOG_0_PART5='setup_memoria_2.0.0.3-5.bin'
ARCHIVE_GOG_0_PART5_MD5='5b85fb7fcb51599ee89b5d7371b87ee2'
ARCHIVE_GOG_0_PART5_TYPE='innosetup'
ARCHIVE_GOG_0_PART6='setup_memoria_2.0.0.3-6.bin'
ARCHIVE_GOG_0_PART6_MD5='c8712354bbd093b706f551e75b549061'
ARCHIVE_GOG_0_PART6_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='app/documents/licenses'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME1_BIN_PATH='app'
ARCHIVE_GAME1_BIN_FILES='*.dll *.ini *.exe'

ARCHIVE_GAME2_BIN_PATH='app/__support/app'
ARCHIVE_GAME2_BIN_FILES='*.ini'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='characters lua scenes videos *.jpg data.vis languages.xml'

CONFIG_FILES='./config.ini'

APP_MAIN_TYPE='wine'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Store user data outside of WINE prefix
user_data_path="$WINEPREFIX/drive_c/users/$USER/Local Settings/Application Data/Daedalic Entertainment/Memoria/Savegames"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "$(dirname "$user_data_path")"
	mkdir --parents "$PATH_DATA/userdata"
	ln --symbolic "$PATH_DATA/userdata" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'
APP_MAIN_EXE='memoria.exe'
APP_MAIN_ICON='memoria.exe'

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

# Get game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

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
