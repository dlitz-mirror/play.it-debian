#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c)      2021, Anna Lea
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
# Baldurʼs Gate - Enhanced Edition - Siege of Dragonspear
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=202010615.1

# Set game-specific variables

GAME_ID='baldurs-gate-1-enhanced-edition'
GAME_NAME='Baldurʼs Gate - Enhanced Edition - Siege of Dragonspear'

ARCHIVE_BASE_3='baldur_s_gate_siege_of_dragonspear_2_6_6_0_47291.sh'
ARCHIVE_BASE_3_MD5='36d275f6822b3cd2946ca606c0ebdb67'
ARCHIVE_BASE_3_TYPE='mojosetup_unzip'
ARCHIVE_BASE_3_SIZE='1900000'
ARCHIVE_BASE_3_VERSION='2.6.6.0-gog47291'
ARCHIVE_BASE_3_URL='https://www.gog.com/game/baldurs_gate_siege_of_dragonspear'

ARCHIVE_BASE_2='baldur_s_gate_siege_of_dragonspear_2_6_5_0_46477.sh'
ARCHIVE_BASE_2_MD5='27970876d9252fcb3174df8201db3ca3'
ARCHIVE_BASE_2_TYPE='mojosetup_unzip'
ARCHIVE_BASE_2_SIZE='1900000'
ARCHIVE_BASE_2_VERSION='2.6.5.0-gog46477'

ARCHIVE_BASE_1='baldur_s_gate_siege_of_dragonspear_en_2_5_23121.sh'
ARCHIVE_BASE_1_MD5='f0581c46e9d31a7ef53be88cf85eccc8'
ARCHIVE_BASE_1_TYPE='mojosetup_unzip'
ARCHIVE_BASE_1_SIZE='1900000'
ARCHIVE_BASE_1_VERSION='2.5.17.0-gog23121'

ARCHIVE_BASE_0='baldur_s_gate_siege_of_dragonspear_en_2_3_0_4_20148.sh'
ARCHIVE_BASE_0_MD5='152225ec02c87e70bfb59970ac33b755'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'
ARCHIVE_BASE_0_SIZE='1900000'
ARCHIVE_BASE_0_VERSION='2.3.0.4-gog20148'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='sod-dlc.zip'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-siege-of-dragonspear"
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

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "${PLAYIT_WORKDIR}"

# Print instructions

print_instructions

exit 0
