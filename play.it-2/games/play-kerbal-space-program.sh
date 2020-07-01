#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, BetaRays
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
# Kerbal Space Program
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200325.2

# Set game-specific variables

GAME_ID='kerbal-space-program'
GAME_NAME='Kerbal Space Program'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0
'

ARCHIVE_GOG_1='kerbal_space_program_1_9_1_02788_36309.sh'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/kerbal_space_program'
ARCHIVE_GOG_1_MD5='6157d3ebad90960893e4aa177b8518de'
ARCHIVE_GOG_1_VERSION='1.9.1.02788-gog36309'
ARCHIVE_GOG_1_SIZE='3700000'
ARCHIVE_GOG_1_TYPE='mojosetup'

ARCHIVE_GOG_0='kerbal_space_program_1_8_1_02694_33460.sh'
ARCHIVE_GOG_0_MD5='195abb84de4a916192190858d0796c50'
ARCHIVE_GOG_0_VERSION='1.8.1.02694-gog33460'
ARCHIVE_GOG_0_SIZE='3400000'
ARCHIVE_GOG_0_TYPE='mojosetup'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='./*.txt'
ARCHIVE_DOC1_DATA_PATH='data/noarch/game'
ARCHIVE_DOC1_DATA_FILES='./*.txt'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='./KSP.x86_64 ./KSP_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='./KSP_Data GameData Internals Missions Parts Resources Ships saves sounds *.cfg'

DATA_DIRS='./saves ./sounds GameData/Squad/*/*.mu GameData/Squad/*/*/*.mu GameData/Squad/*/*/*/*.mu GameData/Squad/*/*/*/*/*.mu' # It seems the game opens ".mu" files as RW
DATA_FILES='*.log'
CONFIG_FILES='*.cfg'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN='KSP.x86_64'
APP_MAIN_ICON='KSP_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glx xcursor glibc libstdc++ libxrandr libudev1 alsa" # pulse can work too but most people will have alsa installed if they use pulse anyway

# Load common functions

target_version='2.11'

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
#shellcheck source=play.it-2/lib/libplayit2.sh
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
