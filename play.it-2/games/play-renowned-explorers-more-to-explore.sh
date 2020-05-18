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
# Renowned Explorers: More To Explore
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190501.2

# Set game-specific variables

GAME_ID='renowned-explorers-international-society'
GAME_NAME='Renowned Explorers: More To Explore'

ARCHIVE_GOG='renowned_explorers_international_society_more_to_explore_dlc_522_26056.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/renowned_explorers_more_to_explore'
ARCHIVE_GOG_MD5='46b6534ff70a9efa4fc21b2ba139b52f'
ARCHIVE_GOG_SIZE='69000'
ARCHIVE_GOG_VERSION='522-gog26056'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD6='renowned_explorers_international_society_more_to_explore_dlc_520_25983.sh'
ARCHIVE_GOG_OLD6_MD5='3d3e97fc73e63ac992c9afa9f620282e'
ARCHIVE_GOG_OLD6_SIZE='69000'
ARCHIVE_GOG_OLD6_VERSION='520-gog25983'
ARCHIVE_GOG_OLD6_TYPE='mojosetup'

ARCHIVE_GOG_OLD5='renowned_explorers_international_society_more_to_explore_dlc_516_25864.sh'
ARCHIVE_GOG_OLD5_MD5='db21406827c77caecb92c96bb2f4e473'
ARCHIVE_GOG_OLD5_SIZE='69000'
ARCHIVE_GOG_OLD5_VERSION='516-gog25864'
ARCHIVE_GOG_OLD5_TYPE='mojosetup'

ARCHIVE_GOG_OLD4='renowned_explorers_international_society_more_to_explore_dlc_512_25169.sh'
ARCHIVE_GOG_OLD4_MD5='94112f4cfc91fa67855a310618bdeacf'
ARCHIVE_GOG_OLD4_SIZE='69000'
ARCHIVE_GOG_OLD4_VERSION='512-gog25169'
ARCHIVE_GOG_OLD4_TYPE='mojosetup'

ARCHIVE_GOG_OLD3='renowned_explorers_international_society_more_to_explore_dlc_508_23701.sh'
ARCHIVE_GOG_OLD3_MD5='5f43443fc81111bc27461e39145c6db6'
ARCHIVE_GOG_OLD3_SIZE='69000'
ARCHIVE_GOG_OLD3_VERSION='508-gog23701'
ARCHIVE_GOG_OLD3_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='renowned_explorers_international_society_more_to_explore_dlc_503_23529.sh'
ARCHIVE_GOG_OLD2_MD5='058fa329bbeeb0f8b3a3e7e60dc472bf'
ARCHIVE_GOG_OLD2_SIZE='69000'
ARCHIVE_GOG_OLD2_VERSION='503-gog23529'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='renowned_explorers_more_to_explore_dlc_en_489_20916.sh'
ARCHIVE_GOG_OLD1_MD5='cc51077bdcb04086349f81da8b1d19ff'
ARCHIVE_GOG_OLD1_SIZE='69000'
ARCHIVE_GOG_OLD1_VERSION='489-gog20916'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='renowned_explorers_more_to_explore_dlc_en_466_15616.sh'
ARCHIVE_GOG_OLD0_MD5='c99ca440cb312b90052939db49aeef03'
ARCHIVE_GOG_OLD0_SIZE='69000'
ARCHIVE_GOG_OLD0_VERSION='466-gog15616'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

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

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
