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
# Stellaris - Apocalypse
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210529.1

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris'

EXPANSION_ID='apocalypse'
EXPANSION_NAME='Apocalypse'

ARCHIVE_BASE_4='stellaris_apocalypse_2_8_1_2_42827.sh'
ARCHIVE_BASE_4_URL='https://www.gog.com/game/stellaris_apocalypse'
ARCHIVE_BASE_4_MD5='3b4bfaaaa89b80694173fcc8b7fe09dd'
ARCHIVE_BASE_4_SIZE='39000'
ARCHIVE_BASE_4_VERSION='2.8.1.2-gog42827'
ARCHIVE_BASE_4_TYPE='mojosetup_unzip'

ARCHIVE_BASE_3='stellaris_apocalypse_2_8_0_5_42441.sh'
ARCHIVE_BASE_3_MD5='57cdc15d3a426291609164aed447e70a'
ARCHIVE_BASE_3_SIZE='39000'
ARCHIVE_BASE_3_VERSION='2.8.0.5-gog42441'
ARCHIVE_BASE_3_TYPE='mojosetup_unzip'

ARCHIVE_BASE_2='stellaris_apocalypse_2_8_0_3_42321.sh'
ARCHIVE_BASE_2_MD5='6ab9d43f5cf3d48e84907703b5d3a72f'
ARCHIVE_BASE_2_SIZE='39000'
ARCHIVE_BASE_2_VERSION='2.8.0.3-gog42321'
ARCHIVE_BASE_2_TYPE='mojosetup_unzip'

ARCHIVE_BASE_1='stellaris_apocalypse_2_7_2_38578.sh'
ARCHIVE_BASE_1_MD5='0a86936e22a9f6be045e9e28de6745c3'
ARCHIVE_BASE_1_SIZE='39000'
ARCHIVE_BASE_1_VERSION='2.7.2-gog38578'
ARCHIVE_BASE_1_TYPE='mojosetup_unzip'

ARCHIVE_BASE_0='stellaris_apocalypse_2_7_1_38218.sh'
ARCHIVE_BASE_0_MD5='93e2c7d56779348f2c842f91004d35c4'
ARCHIVE_BASE_0_SIZE='39000'
ARCHIVE_BASE_0_VERSION='2.7.1-gog38218'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc/dlc017_apocalypse'

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
