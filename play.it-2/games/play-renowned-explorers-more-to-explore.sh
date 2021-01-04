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
# Renowned Explorers: More To Explore
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210515.2

# Set game-specific variables

GAME_ID='renowned-explorers-international-society'
GAME_NAME='Renowned Explorers: More To Explore'

ARCHIVE_BASE_7='renowned_explorers_international_society_more_to_explore_dlc_522_26056.sh'
ARCHIVE_BASE_7_MD5='46b6534ff70a9efa4fc21b2ba139b52f'
ARCHIVE_BASE_7_TYPE='mojosetup'
ARCHIVE_BASE_7_SIZE='69000'
ARCHIVE_BASE_7_VERSION='522-gog26056'
ARCHIVE_BASE_7_URL='https://www.gog.com/game/renowned_explorers_more_to_explore'

ARCHIVE_BASE_6='renowned_explorers_international_society_more_to_explore_dlc_520_25983.sh'
ARCHIVE_BASE_6_MD5='3d3e97fc73e63ac992c9afa9f620282e'
ARCHIVE_BASE_6_TYPE='mojosetup'
ARCHIVE_BASE_6_SIZE='69000'
ARCHIVE_BASE_6_VERSION='520-gog25983'

ARCHIVE_BASE_5='renowned_explorers_international_society_more_to_explore_dlc_516_25864.sh'
ARCHIVE_BASE_5_MD5='db21406827c77caecb92c96bb2f4e473'
ARCHIVE_BASE_5_TYPE='mojosetup'
ARCHIVE_BASE_5_SIZE='69000'
ARCHIVE_BASE_5_VERSION='516-gog25864'

ARCHIVE_BASE_4='renowned_explorers_international_society_more_to_explore_dlc_512_25169.sh'
ARCHIVE_BASE_4_MD5='94112f4cfc91fa67855a310618bdeacf'
ARCHIVE_BASE_4_TYPE='mojosetup'
ARCHIVE_BASE_4_SIZE='69000'
ARCHIVE_BASE_4_VERSION='512-gog25169'

ARCHIVE_BASE_3='renowned_explorers_international_society_more_to_explore_dlc_508_23701.sh'
ARCHIVE_BASE_3_MD5='5f43443fc81111bc27461e39145c6db6'
ARCHIVE_BASE_3_TYPE='mojosetup'
ARCHIVE_BASE_3_SIZE='69000'
ARCHIVE_BASE_3_VERSION='508-gog23701'

ARCHIVE_BASE_2='renowned_explorers_international_society_more_to_explore_dlc_503_23529.sh'
ARCHIVE_BASE_2_MD5='058fa329bbeeb0f8b3a3e7e60dc472bf'
ARCHIVE_BASE_2_TYPE='mojosetup'
ARCHIVE_BASE_2_SIZE='69000'
ARCHIVE_BASE_2_VERSION='503-gog23529'

ARCHIVE_BASE_1='renowned_explorers_more_to_explore_dlc_en_489_20916.sh'
ARCHIVE_BASE_1_MD5='cc51077bdcb04086349f81da8b1d19ff'
ARCHIVE_BASE_1_TYPE='mojosetup'
ARCHIVE_BASE_1_SIZE='69000'
ARCHIVE_BASE_1_VERSION='489-gog20916'

ARCHIVE_BASE_0='renowned_explorers_more_to_explore_dlc_en_466_15616.sh'
ARCHIVE_BASE_0_MD5='c99ca440cb312b90052939db49aeef03'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='69000'
ARCHIVE_BASE_0_VERSION='466-gog15616'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='data'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-more-to-explore"
PKG_MAIN_DEPS="$GAME_ID"

# Easier upgrade from packages generated with pre-20180930.1 scripts

PKG_MAIN_PROVIDE='renowned-explorers-more-to-explore'

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

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
