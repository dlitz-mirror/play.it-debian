#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Privateer
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200906.5

# Set game-specific variables

GAME_ID='privateer-1'
GAME_NAME='Privateer'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0'

ARCHIVE_GOG_1='setup_wing_commander_privateer_1.0_(28045).exe'
ARCHIVE_GOG_1_MD5='482b990445b335ecf7f47ee18efccc14'
ARCHIVE_GOG_1_TYPE='innosetup'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/wing_commander_privateer'
ARCHIVE_GOG_1_VERSION='1.0-gog28045'
ARCHIVE_GOG_1_SIZE='180000'

ARCHIVE_GOG_0='setup_wing_commander_privateer_2.0.0.9.exe'
ARCHIVE_GOG_0_MD5='53c77040cba69a642ec1302b5cf231b5'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_VERSION='1.0-gog2.0.0.9'
ARCHIVE_GOG_0_SIZE='190000'

ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='*.pdf'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='*.cfg *.dat *.exe *.nda *.ovl *.pak *.vda game.gog'

# Keep compatibility with old archives
ARCHIVE_DOC_MAIN_PATH_GOG_0='app'
ARCHIVE_GAME_MAIN_PATH_GOG_0='app'

# CD-ROM image
GAME_IMAGE='GAME.GOG'
GAME_IMAGE_TYPE='iso'

CONFIG_FILES='./*.CFG'
DATA_FILES='./*.IFF'

# Main game
APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='PRIV.EXE'
APP_MAIN_ICON='app/goggame-1207658938.ico'

# Righteous Fire expansion
APP_RF_ID="${GAME_ID}-righteous-fire"
APP_RF_NAME="${GAME_NAME} - Righteous Fire"
APP_RF_TYPE='dosbox'
APP_RF_EXE='PRIV.EXE'
APP_RF_EXE_OPTIONS='r'
APP_RF_ICON='app/goggame-1207658938.ico'

# Keep compatibility with old archives
APP_MAIN_ICON_GOG_0='app/gfw_high.ico'
APP_RF_ICON_GOG_0='app/gfw_high.ico'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'

# Load common functions

target_version='2.12'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
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
toupper "${PKG_MAIN_PATH}${PATH_GAME}"

# Extract icons

icons_get_from_workdir 'APP_MAIN' 'APP_RF'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

launchers_write 'APP_MAIN' 'APP_RF'

# Work around sound issues in the intro video

###
# TODO
# We need a better way to handle pre-run commands for DOSBox games
###

pattern='s/^# Run the game$/&\n\n'
pattern="$pattern"'# Work around sound issues in the intro video\n'
pattern="$pattern"'export DOSBOX_SBLASTER_IRQ=5\n/'
sed --in-place "$pattern" "${PKG_MAIN_PATH}${PATH_BIN}"/*

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
