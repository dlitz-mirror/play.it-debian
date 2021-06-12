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
# Pier Solar and the Great Architects
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210612.4

# Set game-specific variables

GAME_ID='pier-solar'
GAME_NAME='Pier Solar and the Great Architects'

ARCHIVE_BASE_GOG_0='gog_pier_solar_and_the_great_architects_2.1.0.4.sh'
ARCHIVE_BASE_GOG_0_MD5='2de03fb6d69944e3f204d5ae45147a3e'
ARCHIVE_BASE_GOG_0_TYPE='mojosetup'
ARCHIVE_BASE_GOG_0_VERSION='1.3.2-gog2.1.0.4'
ARCHIVE_BASE_GOG_0_SIZE='2400000'
ARCHIVE_BASE_GOG_0_URL='https://www.gog.com/game/pier_solar_and_the_great_architects'

ARCHIVE_BASE_HUMBLE_0='PierSolar_linux.zip'
ARCHIVE_BASE_HUMBLE_0_MD5='e5ceda3a75cab3fe9b1ad1cbaf2d4a1d'
ARCHIVE_BASE_HUMBLE_0_VERSION='1.3.2-humble1'
ARCHIVE_BASE_HUMBLE_0_SIZE='2400000'

###
# TODO
# Check that the documentation files are provided by the Humble archive
###
ARCHIVE_GAME_DOC_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DOC_PATH_HUMBLE='PierSolar_linux'
ARCHIVE_GAME_DOC_FILES='README.txt'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='PierSolar_linux'
ARCHIVE_GAME_BIN32_FILES='pshd.linux32'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='PierSolar_linux'
ARCHIVE_GAME_BIN64_FILES='pshd.linux64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='PierSolar_linux'
ARCHIVE_GAME_DATA_FILES='data icon.png'

APP_MAIN_TYPE='native'
APP_MAIN_ICON='icon.png'
APP_MAIN_EXE_BIN32='pshd.linux32'
APP_MAIN_EXE_BIN64='pshd.linux64'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc glx"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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

# Extract icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
