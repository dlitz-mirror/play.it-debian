#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
# Copyright (c) 2017-2019, Jacek Szafarkiewicz
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
# Commandos 3: Destination Berlin
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190927.3

# Set game-specific variables

GAME_ID='commandos-3'
GAME_NAME='Commandos 3: Destination Berlin'

ARCHIVE_GOG='setup_commandos_3_-_destination_berlin_1.42_hotfix2_(25143).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/commandos_2_3'
ARCHIVE_GOG_MD5='2fa1ad6e7c7e918bdaa1adee5bb3a0ec'
ARCHIVE_GOG_VERSION='1.42-gog25143'
ARCHIVE_GOG_SIZE='2100000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.pdf eula.txt readme.rtf support.txt'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='*.pck directplay.cmd data output'

CONFIG_DIRS='./output'

APP_WINETRICKS="vd=\$(xrandr|awk '/\\*/ {print \$1}') d3dx9_42"

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='commandos3.exe'
APP_MAIN_ICON='commandos3.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks glx xrandr"

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

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

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
