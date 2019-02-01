#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2017-2018, Solène Huault
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
# The Silver Case - Demo
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181103.3

# Set game-specific variables

GAME_ID='the-silver-case-demo'
GAME_NAME='The Silver Case - Demo'

ARCHIVE_GOG='setup_the_silver_case_demo_2.0.0.1.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_silver_case_demo'
ARCHIVE_GOG_MD5='3c133cb2031160370917f120055c63b4'
ARCHIVE_GOG_SIZE='960000'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.1'

ARCHIVE_PLAYISM='TheSilverCase_DEMO_Playism0930.zip'
ARCHIVE_PLAYISM_URL='http://playism-games.com/game/285/the-silver-case'
ARCHIVE_PLAYISM_MD5='a1bbd59ead01c4e1dc50c38b3a65c5ea'
ARCHIVE_PLAYISM_SIZE='950000'
ARCHIVE_PLAYISM_VERSION='1.0-playism0930'

ARCHIVE_DOC_DATA_PATH_GOG='tmp'
ARCHIVE_DOC_DATA_FILES_GOG='*.txt'

ARCHIVE_GAME_BIN_PATH_GOG='app'
ARCHIVE_GAME_BIN_PATH_PLAYISM='thesilvercase_demo_0930'
ARCHIVE_GAME_BIN_FILES='thesilvercase_trial.exe thesilvercase_trial_data/mono thesilvercase_trial_data/plugins'

ARCHIVE_GAME_DATA_PATH_GOG='app'
ARCHIVE_GAME_DATA_PATH_PLAYISM='thesilvercase_demo_0930'
ARCHIVE_GAME_DATA_FILES='thesilvercase_trial_data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='thesilvercase_trial.exe'
APP_MAIN_ICON='thesilvercase_trial.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine glx"

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
case "$ARCHIVE" in
	('ARCHIVE_PLAYISM')
		tolower "$PLAYIT_WORKDIR/gamedata"
	;;
esac
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

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
