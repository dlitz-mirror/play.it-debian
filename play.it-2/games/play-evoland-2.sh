#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
# Copyright (c) 2018-2019, Solène Huault
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
# Evoland 2, A Slight Case of Spacetime Continuum Disorder
# build native Linux packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20190113.4

# Set game-specific variables

GAME_ID='evoland-2'
GAME_NAME='Evoland 2, A Slight Case of Spacetime Continuum Disorder'

ARCHIVE_HUMBLE='Evoland2.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/evoland-2'
ARCHIVE_HUMBLE_MD5='0e34269cb7db3a6c065311eea90e651a'
ARCHIVE_HUMBLE_SIZE='790000'
ARCHIVE_HUMBLE_VERSION='1.0.9137-humble170116'
ARCHIVE_HUMBLE_TYPE='zip'

ARCHIVE_GAME_BIN_PATH='Evoland2'
ARCHIVE_GAME_BIN_FILES='Adobe?AIR Evoland2.exe gamePadConfig.txt pad.exe'

ARCHIVE_GAME_DATA_PATH='Evoland2'
ARCHIVE_GAME_DATA_FILES='game.dat icons META-INF mimetype res.pak'

DATA_DIRS='./save'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='Evoland2.exe'
APP_MAIN_ICON='Evoland2.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	: ${XDG_DATA_HOME:="$HOME/.local/share"}
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
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
