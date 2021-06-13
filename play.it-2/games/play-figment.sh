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
# Figment
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210606.4

# Set game-specific variables

GAME_ID='figment'
GAME_NAME='Figment'

ARCHIVE_BASE_0='figment_1_1_8_24039.sh'
ARCHIVE_BASE_0_MD5='c1da7eb0081fa3fc6140510cc725ee8e'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='1100000'
ARCHIVE_BASE_0_VERSION='1.1.8-gog24039'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/figment'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='Figment.x86 Figment_Data/*/x86 '

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='Figment.x86_64 Figment_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Figment_Data version-data.json'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Figment.x86'
APP_MAIN_EXE_BIN64='Figment.x86_64'
APP_MAIN_ICON='Figment_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc libstdc++ gtk2 libz.so.1 libgdk_pixbuf-2.0.so.0 libgobject-2.0.so.0 libglib-2.0.so.0"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Prevent $HOME clutter

# shellcheck disable=SC1004
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Prevent $HOME clutter
FAKE_HOME="${PATH_PREFIX}/fake-home"
mkdir --parents "${FAKE_HOME}/.local"
ln --force --no-target-directory --symbolic \
	"${XDG_CACHE_HOME:=$HOME/.cache}" \
	"${FAKE_HOME}/.cache"
ln --force --no-target-directory --symbolic \
	"${XDG_CONFIG_HOME:=$HOME/.config}" \
	"${FAKE_HOME}/.config"
ln --force --no-target-directory --symbolic \
	"${XDG_DATA_HOME:=$HOME/.local/share}" \
	"${FAKE_HOME}/.local/share"
HOME="$FAKE_HOME"
export XDG_CACHE_HOME XDG_CONFIG_HOME XDG_DATA_HOME HOME

DIVERTED_PATH_REAL="${PATH_PREFIX}/userdata"
DIVERTED_PATH_LINK="${FAKE_HOME}/My Games/Figment"
mkdir --parents "$DIVERTED_PATH_REAL" "$(dirname "$DIVERTED_PATH_LINK")"
ln --force --no-target-directory --symbolic \
	"$DIVERTED_PATH_REAL" \
	"$DIVERTED_PATH_LINK"'
DATA_DIRS="${DATA_DIRS} userdata/Saves"
CONFIG_FILES="${CONFIG_FILES} userdata/*.cfg"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
