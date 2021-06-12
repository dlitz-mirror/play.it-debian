#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2020-2021, HS-157
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
# Dreamfall Chapters
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210612.3

# Set game-specific variables

GAME_ID='dreamfall-chapters'
GAME_NAME='Dreamfall Chapters'

ARCHIVE_BASE_GOG_0='gog_dreamfall_chapters_2.19.0.23.sh'
ARCHIVE_BASE_GOG_0_MD5='3f05c530a0e07b7227e3fb7b6601e19a'
ARCHIVE_BASE_GOG_0_TYPE='mojosetup'
ARCHIVE_BASE_GOG_0_VERSION='5.3.0-gog2.19.0.23'
ARCHIVE_BASE_GOG_0_SIZE='21000000'

###
# TODO
# Update version string based on the actual game version
###
ARCHIVE_BASE_HUMBLE_0='Dreamfall_Chapters_Linux_2017_08_25.zip'
ARCHIVE_BASE_HUMBLE_0_MD5='22bee7bee25920e5cf7febc4b3c12e21'
ARCHIVE_BASE_HUMBLE_0_VERSION='20170825-humble'
ARCHIVE_BASE_HUMBLE_0_SIZE='21000000'
ARCHIVE_BASE_HUMBLE_0_URL='https://www.humblebundle.com/store/dreamfall-chapters'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='.'
ARCHIVE_GAME_BIN_FILES='Dreamfall?Chapters Dreamfall?Chapters_Data/Mono Dreamfall?Chapters_Data/Plugins'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='.'
ARCHIVE_GAME_DATA_FILES='Dreamfall?Chapters_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Dreamfall Chapters'
APP_MAIN_ICON='Dreamfall Chapters_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc libstdc++ glx xcursor libxrandr libX11.so.6"

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

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
