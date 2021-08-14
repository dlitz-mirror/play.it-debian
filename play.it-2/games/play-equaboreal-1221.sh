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
# Equaboreal 12.21
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201019.1

# Set game-specific variables

GAME_ID='equaboreal-1221'
GAME_NAME='Equaboreal 12.21'

ARCHIVES_LIST='
ARCHIVE_ITCH_0'

ARCHIVE_ITCH_0='Equaboreal_LINUX_1.02.zip'
ARCHIVE_ITCH_0_URL='https://girldebord.itch.io/1221'
ARCHIVE_ITCH_0_MD5='4ca58bf305ef445e3e0b8b5eb64fb319'
ARCHIVE_ITCH_0_SIZE='700000'
ARCHIVE_ITCH_0_VERSION='1.02-itch'
ARCHIVE_ITCH_0_TYPE='zip'

ARCHIVE_GAME_BIN_PATH='Equaboreal_LINUX_1.02'
ARCHIVE_GAME_BIN_FILES='Equaboreal_1.02.x86_64 Equaboreal_1.02_Data/Mono* Equaboreal_1.02_Data/Managed Equaboreal_1.02_Data/Plugins UnityPlayer.so'

ARCHIVE_GAME_DATA_PATH='Equaboreal_LINUX_1.02'
ARCHIVE_GAME_DATA_FILES='Equaboreal_1.02_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# Work around Unity3D poor support for non-US locales
export LANG=C'
APP_MAIN_EXE='Equaboreal_1.02.x86_64'
APP_MAIN_ICON='Equaboreal_1.02_Data/Resources/UnityPlayer.png'
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
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
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
