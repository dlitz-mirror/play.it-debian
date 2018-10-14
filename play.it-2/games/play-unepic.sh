#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, BetaRays
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
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180906.1

# Set game-specific variables

GAME_ID='unepic'
GAME_NAME='unEpic'

ARCHIVE_HUMBLE='unepic-15005.run'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/unepic'
ARCHIVE_HUMBLE_MD5='940824c4de6e48522845f63423e87783'
ARCHIVE_HUMBLE_VERSION='1.50.05-humble141208'
ARCHIVE_HUMBLE_SIZE='360000'
ARCHIVE_HUMBLE_TYPE='mojosetup'

ARCHIVE_GOG='unepic_en_1_51_01_20608.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/unepic'
ARCHIVE_GOG_MD5='88d98eb09d235fe3ca00f35ec0a014a3'
ARCHIVE_GOG_VERSION='1.51.01-gog20608'
ARCHIVE_GOG_SIZE='380000'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_unepic_2.1.0.4.sh'
ARCHIVE_GOG_OLD0_MD5='341556e144d5d17ae23d2b0805c646a1'
ARCHIVE_GOG_OLD0_SIZE='380000'
ARCHIVE_GOG_OLD0_VERSION='1.50.05-gog2.1.0.4'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH_HUMBLE='data'
ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='./unepic32 ./lib32/libSDL2_mixer-2.0.so.0'

ARCHIVE_GAME_BIN64_PATH_HUMBLE='data'
ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='./unepic64 ./lib64/libSDL2_mixer-2.0.so.0'

ARCHIVE_GAME_DATA_PATH_HUMBLE='data'
ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='./data ./image ./sound ./voices ./unepic.png ./omaps ./dictios_pc'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='unepic32'
APP_MAIN_EXE_BIN64='unepic64'
APP_MAIN_ICON='unepic.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID sdl2 sdl2_mixer glx libstdc++"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	for path in\
		'./'\
		"$XDG_DATA_HOME/play.it/"\
		"$XDG_DATA_HOME/play.it/play.it-2/lib/"\
		'/usr/local/share/games/play.it/'\
		'/usr/local/share/play.it/'\
		'/usr/share/games/play.it/'\
		'/usr/share/play.it/'
	do
		if [ -z "$PLAYIT_LIB2" ] && [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
	if [ -z "$PLAYIT_LIB2" ]; then
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
