#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Wing Commander 3
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210410.1

# Set game-specific variables

GAME_ID='wing-commander-3'
GAME_NAME='Wing Commander Ⅲ'

ARCHIVES_LIST='
ARCHIVE_BASE_1
ARCHIVE_BASE_0'

ARCHIVE_BASE_1='setup_wing_commander_iii_1.4_(28045).exe'
ARCHIVE_BASE_1_MD5='9418288d818315fbbede459bef76b82c'
ARCHIVE_BASE_1_TYPE='innosetup'
ARCHIVE_BASE_1_PART1='setup_wing_commander_iii_1.4_(28045)-1.bin'
ARCHIVE_BASE_1_PART1_MD5='1caaf5ba29075e67a00b8009bc53e463'
ARCHIVE_BASE_1_PART1_TYPE='innosetup'
ARCHIVE_BASE_1_VERSION='1.4-gog28045'
ARCHIVE_BASE_1_SIZE='1900000'
ARCHIVE_BASE_1_URL='https://www.gog.com/game/wing_commander_3_heart_of_the_tiger'

ARCHIVE_BASE_0='setup_wing_commander3_2.1.0.7.exe'
ARCHIVE_BASE_0_MD5='c9c9b539e6e1f0b0509b6f777878d91e'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_VERSION='1.4-gog2.1.0.7'
ARCHIVE_BASE_0_SIZE='1900000'

ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='*.pdf'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='data.dat objects.tre wc3'

# Keep compatibility with old archives
ARCHIVE_DOC_MAIN_PATH_GOG_0='app'
ARCHIVE_GAME_MAIN_PATH_GOG_0='app'

GAME_IMAGE='DATA.DAT'

CONFIG_DIRS='./WC3'
DATA_FILES='./*.WSG'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='WC3.EXE'
APP_MAIN_ICON='app/goggame-1207658966.ico'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'

# Run the game from the mounted CD-ROM image

APP_MAIN_PRERUN='d:'

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

icons_get_from_workdir 'APP_MAIN'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

# Work around the binary presence check,
# it is actually included in the CD-ROM image
fake_binary="${PKG_MAIN_PATH}${PATH_GAME}/${APP_MAIN_EXE}"
touch "$fake_binary"

launchers_write 'APP_MAIN'

rm "$fake_binary"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
