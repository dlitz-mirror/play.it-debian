#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2016-2018, Solène Huault
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
# Anachronox
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181122.2

# Set game-specific variables

GAME_ID='anachronox'
GAME_NAME='Anachronox'

ARCHIVE_GOG='setup_anachronox_1.02_(22258).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/anachronox'
ARCHIVE_GOG_TYPE='innosetup1.7'
ARCHIVE_GOG_MD5='4e23d4f7637f6914a7cd6c13feb7ad7d'
ARCHIVE_GOG_VERSION='1.02-gog22258'
ARCHIVE_GOG_SIZE='1100000'

ARCHIVE_GOG_OLD0='setup_anachronox_2.0.0.28.exe'
ARCHIVE_GOG_OLD0_MD5='a9e148972e51a4980a2531d12a85dfc0'
ARCHIVE_GOG_OLD0_VERSION='1.02-gog2.0.0.28'
ARCHIVE_GOG_OLD0_SIZE='1100000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.rtf *.txt manual.pdf readme.htm'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_OLD0='app'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe *.inf *.ini *.ocx'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='*.jpg anoxdata anox.ico'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_OLD0='app'

DATA_DIRS='anoxdata/logs anoxdata/save'
DATA_FILES='./anox.log anoxdata/nokill.*'
CONFIG_FILES='./*.ini'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='anox.exe'
APP_MAIN_ICON='anox.ico'

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
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icon

PKG='PKG_DATA'
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
