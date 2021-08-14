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
# Stellaris - MegaCorp
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210529.5

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris'

EXPANSION_ID='megacorp'
EXPANSION_NAME='MegaCorp'

ARCHIVE_BASE_4='stellaris_megacorp_3_0_3_47193.sh'
ARCHIVE_BASE_4_MD5='8992c77ac7de034c7d3deceb656fb3f6'
ARCHIVE_BASE_4_TYPE='mojosetup_unzip'
ARCHIVE_BASE_4_SIZE='140000'
ARCHIVE_BASE_4_VERSION='3.0.3-gog47193'
ARCHIVE_BASE_4_URL='https://www.gog.com/game/stellaris_megacorp'

ARCHIVE_BASE_3='stellaris_megacorp_3_0_2_46477.sh'
ARCHIVE_BASE_3_MD5='47f1ac79a7ee08cf490860d6a5e3a52a'
ARCHIVE_BASE_3_TYPE='mojosetup_unzip'
ARCHIVE_BASE_3_SIZE='140000'
ARCHIVE_BASE_3_VERSION='3.0.2-gog46477'

ARCHIVE_BASE_2='stellaris_megacorp_3_0_1_2_46213.sh'
ARCHIVE_BASE_2_MD5='dd0aa754af52d64546d2ad7423e03621'
ARCHIVE_BASE_2_TYPE='mojosetup_unzip'
ARCHIVE_BASE_2_SIZE='140000'
ARCHIVE_BASE_2_VERSION='3.0.1.2-gog46213'

ARCHIVE_BASE_1='stellaris_megacorp_2_8_1_2_42827.sh'
ARCHIVE_BASE_1_MD5='2cd753517129dae46b0e92ca2d50dcb9'
ARCHIVE_BASE_1_TYPE='mojosetup_unzip'
ARCHIVE_BASE_1_SIZE='140000'
ARCHIVE_BASE_1_VERSION='2.8.1.2-gog42827'

ARCHIVE_BASE_0='stellaris_megacorp_2_7_1_38218.sh'
ARCHIVE_BASE_0_MD5='d29d326e5923ead35e00c254293ab6fb'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'
ARCHIVE_BASE_0_SIZE='140000'
ARCHIVE_BASE_0_VERSION='2.7.1-gog38218'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc/dlc020_megacorp'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-${EXPANSION_ID}"
PKG_MAIN_DESCRIPTION="$EXPANSION_NAME"
PKG_MAIN_DEPS="$GAME_ID"

# Load common functions

target_version='2.13'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
		'/usr/share/play.it'
	do
		if [ -e "${path}/libplayit2.sh" ]; then
			PLAYIT_LIB2="${path}/libplayit2.sh"
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

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

GAME_NAME="$GAME_NAME - $EXPANSION_NAME"
print_instructions

exit 0
