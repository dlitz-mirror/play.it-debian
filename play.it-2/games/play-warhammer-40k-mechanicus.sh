#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Warhammer 40,000: Mechanicus
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210628.2

# Set game-specific variables

GAME_ID='warhammer-40k-mechanicus'
GAME_NAME='Warhammer 40,000: Mechanicus'

ARCHIVE_BASE_0='warhammer_40_000_mechanicus_1_4_6_1_47625.sh'
ARCHIVE_BASE_0_MD5='672029ff6ad1ff34946201ca4d423737'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'
ARCHIVE_BASE_0_SIZE='11000000'
ARCHIVE_BASE_0_VERSION='1.4.6.1-gog47625'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/warhammer_40000_mechanicus'

UNITY3D_NAME='Mechanicus'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES="${UNITY3D_NAME}.x86_64 ${UNITY3D_NAME}_Data/Mono ${UNITY3D_NAME}_Data/Plugins"

ARCHIVE_GAME_DATA_SHAREDASSETS_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_SHAREDASSETS_FILES="${UNITY3D_NAME}_Data/sharedassets*"

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES="${UNITY3D_NAME}_Data"

APP_MAIN_TYPE='native'
APP_MAIN_EXE="${UNITY3D_NAME}.x86_64"
APP_MAIN_ICON="${UNITY3D_NAME}_Data/Resources/UnityPlayer.png"

PACKAGES_LIST='PKG_BIN PKG_DATA_SHAREDASSETS PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_DATA_SHAREDASSETS_ID="${PKG_DATA_ID}-sharedassets"
PKG_DATA_SHAREDASSETS_DESCRIPTION="$PKG_DATA_DESCRIPTION - shared assets"
PKG_DATA_DEPS="$PKG_DATA_DEPS $PKG_DATA_SHAREDASSETS_ID"

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ gtk2 libz.so.1 libgdk_pixbuf-2.0.so.0 libgobject-2.0.so.0 libglib-2.0.so.0"

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

# Work around Unity3D poor support for non-US locales

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Work around Unity3D poor support for non-US locales
export LANG=C'

# Work around terminfo Mono bug
# cf. https://github.com/mono/mono/issues/6752

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Work around terminfo Mono bug
# cf. https://github.com/mono/mono/issues/6752
export TERM="${TERM%-256color}"'

# Load common functions

target_version='2.13'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
		'/usr/share/play.it'
	do
		if [ -e "${path}/libplayit2.sh" ]; then
			PLAYIT_LIB2="${path}/libplayit2.sh"
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

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
