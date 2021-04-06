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
# Spiritfarer
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210330.1

# Set game-specific variables

GAME_ID='spiritfarer'
GAME_NAME='Spiritfarer'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0'

ARCHIVE_GOG_1='spiritfarer_32698_linux_42758.sh'
ARCHIVE_GOG_1_MD5='2f1c327bd020676eabd78f99124a786f'
ARCHIVE_GOG_1_TYPE='mojosetup'
ARCHIVE_GOG_1_SIZE='6900000'
ARCHIVE_GOG_1_VERSION='32698-gog42758'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/spiritfarer'

ARCHIVE_GOG_0='spiritfarer_32513_linux_41748.sh'
ARCHIVE_GOG_0_MD5='8e6e49ce7e7571091f91d82706d2df8e'
ARCHIVE_GOG_0_TYPE='mojosetup'
ARCHIVE_GOG_0_SIZE='6900000'
ARCHIVE_GOG_0_VERSION='32513-gog41748'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='Spiritfarer.exe Spiritfarer_Data/Mono* Spiritfarer_Data/Plugins Spiritfarer_Data/Managed LinuxPlayer_s.debug UnityPlayer_s.debug UnityPlayer.so'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Spiritfarer_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# Work around Unity3D poor support for non-US locales
export LANG=C'
APP_MAIN_EXE='Spiritfarer.exe'
APP_MAIN_ICON='Spiritfarer_Data/Resources/UnityPlayer.png'
# Use a per-session dedicated file for logs
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++"

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
