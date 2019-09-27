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
# Zeus: Master of Olympus
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190927.2

# Set game-specific variables

GAME_ID='zeus-master-of-olympus'
GAME_NAME='Zeus: Master of Olympus'

ARCHIVE_GOG='setup_zeus_and_poseidon_2.1.0.10.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/zeus_poseidon'
ARCHIVE_GOG_MD5='f26f9ed5ecaa4e58fca64acb88255107'
ARCHIVE_GOG_SIZE='800000'
ARCHIVE_GOG_VERSION='2.1-gog2.1.0.10'

ARCHIVE_DOC0_DATA_PATH='tmp'
ARCHIVE_DOC0_DATA_FILES='*.txt'

ARCHIVE_DOC1_DATA_PATH='app'
ARCHIVE_DOC1_DATA_FILES='*.txt *.pdf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.asi *.exe *.ini *.m3d binkw32.dll ijl10.dll mss32.dll'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='*.eng *.inf poseidon.ico zeus.ico adventures audio binks data model'

CONFIG_FILES='./*.ini'
DATA_DIRS='./save'

APP_WINETRICKS="vd=\$(xrandr|awk '/\\*/ {print \$1}') csmt=off"

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='zeus.exe'
APP_MAIN_ICON='poseidon.ico'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks xrandr"

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

PKG='PKG_DATA'
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
