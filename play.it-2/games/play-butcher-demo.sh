#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
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
# Butcher - Demo
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20191205.1

# Set game-specific variables

GAME_ID='butcher-demo'
GAME_NAME='Butcher Demo'

ARCHIVE_GOG='gog_butcher_demo_2.0.0.1.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/butcher_demo'
ARCHIVE_GOG_MD5='03ed5d89ef38ef10a3318b8da7e62525'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.1'
ARCHIVE_GOG_SIZE='110000'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_DOC_PATH='data/noarch/docs' 
ARCHIVE_DOC_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='butcher'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='butcher_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='butcher'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='butcher_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx xcursor libxrandr"
PKG_BIN_DEPS_ARCH='lib32-libx11'
PKG_BIN_DEPS_DEB='libx11-6'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11'

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

# Write launchers

PKG='PKG_BIN'
launcher_write 'APP_MAIN'

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
