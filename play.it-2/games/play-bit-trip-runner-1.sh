#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Solène "Mopi" Huault
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
# Bit.Trip Runner
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200206.2

# Set game-specific variables

GAME_ID='bit-trip-runner-1'
GAME_NAME='Bit.Trip Runner'

ARCHIVE_GOG='gog_bit_trip_runner_2.0.0.1.sh'
ARCHIVE_GOG_MD5='b6f0fe70e1a2d9408967b8fd6bd881e1'
ARCHIVE_GOG_VERSION='1.0.5-gog2.0.0.1'
ARCHIVE_GOG_SIZE='120000'

ARCHIVE_DOC_DATA_PATH='data/noarch/game/bit.trip.runner-1.0-32'
ARCHIVE_DOC_DATA_FILES='README* *.txt'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game/bit.trip.runner-1.0-32'
ARCHIVE_GAME_BIN32_FILES='bit.trip.runner/Effects bit.trip.runner/Layouts bit.trip.runner/Sounds bit.trip.runner/Models bit.trip.runner/bit.trip.runner'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game/bit.trip.runner-1.0-64'
ARCHIVE_GAME_BIN64_FILES='bit.trip.runner/Effects bit.trip.runner/Layouts bit.trip.runner/Sounds bit.trip.runner/Models bit.trip.runner/bit.trip.runner'

ARCHIVE_GAME_DATA_PATH='data/noarch/game/bit.trip.runner-1.0-32'
ARCHIVE_GAME_DATA_FILES='bit.trip.runner/Shaders bit.trip.runner/RUNNER.png bit.trip.runner/Fonts bit.trip.runner/Textures2d'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Run the game binary from its directory
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'
APP_MAIN_EXE='bit.trip.runner/bit.trip.runner'
APP_MAIN_ICON='bit.trip.runner/RUNNER.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# Easier upgrade from packages generated with pre-20200206.1 scripts
PKG_DATA_PROVIDE='runner-data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx sdl1.2 openal vorbis"
# Easier upgrade from packages generated with pre-20200206.1 scripts
PKG_BIN32_PROVIDE='runner'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
# Easier upgrade from packages generated with pre-20200206.1 scripts
PKG_BIN64_PROVIDE='runner'

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

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
