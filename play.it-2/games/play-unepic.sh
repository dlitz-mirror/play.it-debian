#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2018-2021, BetaRays
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
# unEpic
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210610.3

# Set game-specific variables

GAME_ID='unepic'
GAME_NAME='unEpic'

ARCHIVE_BASE_HUMBLE_0='unepic-15005.run'
ARCHIVE_BASE_HUMBLE_0_MD5='940824c4de6e48522845f63423e87783'
ARCHIVE_BASE_HUMBLE_0_TYPE='mojosetup'
ARCHIVE_BASE_HUMBLE_0_VERSION='1.50.05-humble141208'
ARCHIVE_BASE_HUMBLE_0_SIZE='360000'
ARCHIVE_BASE_HUMBLE_0_URL='https://www.humblebundle.com/store/unepic'

ARCHIVE_BASE_GOG_1='unepic_en_1_51_01_20608.sh'
ARCHIVE_BASE_GOG_1_MD5='88d98eb09d235fe3ca00f35ec0a014a3'
ARCHIVE_BASE_GOG_1_TYPE='mojosetup'
ARCHIVE_BASE_GOG_1_VERSION='1.51.01-gog20608'
ARCHIVE_BASE_GOG_1_SIZE='380000'
ARCHIVE_BASE_GOG_1_URL='https://www.gog.com/game/unepic'

ARCHIVE_BASE_GOG_0='gog_unepic_2.1.0.4.sh'
ARCHIVE_BASE_GOG_0_MD5='341556e144d5d17ae23d2b0805c646a1'
ARCHIVE_BASE_GOG_0_TYPE='mojosetup'
ARCHIVE_BASE_GOG_0_SIZE='380000'
ARCHIVE_BASE_GOG_0_VERSION='1.50.05-gog2.1.0.4'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH_HUMBLE='data'
ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='unepic32'

ARCHIVE_GAME_BIN64_PATH_HUMBLE='data'
ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='unepic64'

ARCHIVE_GAME_DATA_PATH_HUMBLE='data'
ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='data image sound voices unepic.png omaps dictios_pc'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='unepic32'
APP_MAIN_EXE_BIN64='unepic64'
APP_MAIN_ICON_HUMBLE='unepic.png'
APP_MAIN_ICON_GOG='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc libstdc++ glx libSDL2-2.0.so.0 libz.so.1"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Include shipped libSDL2_mixer-2.0.so.0 library

###
# TODO
# Check if we can drop this library in favour of a system-provided one
###

ARCHIVE_GAME_BIN32_FILES="${ARCHIVE_GAME_BIN32_FILES} lib32/libSDL2_mixer-2.0.so.0"
ARCHIVE_GAME_BIN64_FILES="${ARCHIVE_GAME_BIN64_FILES} lib64/libSDL2_mixer-2.0.so.0"
APP_MAIN_LIBS_BIN32='lib32'
APP_MAIN_LIBS_BIN64='lib64'

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

# Include game icon

PKG='PKG_DATA'
use_archive_specific_value 'APP_MAIN_ICON'
case "$ARCHIVE" in
	('ARCHIVE_BASE_HUMBLE_'*)
		icons_get_from_package 'APP_MAIN'
	;;
	('ARCHIVE_BASE_GOG_'*)
		icons_get_from_workdir 'APP_MAIN'
	;;
esac

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
