#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# Infinium Strike
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181003.3

# Set game-specific variables

GAME_ID='infinium-strike'
GAME_NAME='Infinium Strike'

ARCHIVE_GOG='gog_infinium_strike_2.1.0.3.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/infinium_strike'
ARCHIVE_GOG_MD5='c19f2032aae3011dc38cc85e7153fb44'
ARCHIVE_GOG_SIZE='2500000'
ARCHIVE_GOG_VERSION='1.0.5-gog2.1.0.3'

ARCHIVE_GOG_OLD0='gog_infinium_strike_2.1.0.2.sh'
ARCHIVE_GOG_OLD0_MD5='57725aad8ba419d80788412f8f33f030'
ARCHIVE_GOG_OLD0_SIZE='2500000'
ARCHIVE_GOG_OLD0_VERSION='1.0.5-gog2.1.0.2'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game'
ARCHIVE_DOC1_DATA_FILES='InfiniumStrikeReadMe.txt'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='InfiniumStrike.x86 InfiniumStrike_Data/Mono InfiniumStrike_Data/Plugins'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='InfiniumStrike_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='if ! command -v pulseaudio >/dev/null 2>&1; then
	mkdir --parents libs
	ln --force --symbolic /dev/null libs/libpulse-simple.so.0
	export LD_LIBRARY_PATH="libs:$LD_LIBRARY_PATH"
else
	if [ -e "libs/libpulse-simple.so.0" ]; then
		rm libs/libpulse-simple.so.0
		rmdir --ignore-fail-on-non-empty libs
	fi
	pulseaudio --start
fi'
APP_MAIN_EXE='InfiniumStrike.x86'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='InfiniumStrike_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx xcursor libxrandr libudev1"

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
rm --recursive "$PLAYIT_WORKDIR/gamedata/$ARCHIVE_GAME_BIN_PATH/InfiniumStrike_Data/Mono/x86_64"
rm --recursive "$PLAYIT_WORKDIR/gamedata/$ARCHIVE_GAME_BIN_PATH/InfiniumStrike_Data/Plugins/x86_64"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

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
