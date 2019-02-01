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
# War for the Overworld: Underlord Edition
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181121.1

# Set game-specific variables

GAME_ID='war-for-the-overworld'
GAME_NAME='War for the Overworld: Underlord Edition'

ARCHIVE_GOG='war_for_the_overworld_underlord_edition_upgrade_2_0_6f1_24637.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/war_for_the_overworld_underlord_edition_upgrade'
ARCHIVE_GOG_MD5='0be12c1160fdba4f180dc3776f1bb21e'
ARCHIVE_GOG_SIZE='1300'
ARCHIVE_GOG_VERSION='2.0.6f1-gog24637'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='war_for_the_overworld_underlord_edition_upgrade_2_0_5_24177.sh'
ARCHIVE_GOG_OLD2_MD5='97857939a158c470d04936bc580838c2'
ARCHIVE_GOG_OLD2_SIZE='1300'
ARCHIVE_GOG_OLD2_VERSION='2.0.5-gog24177'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='war_for_the_overworld_underlord_edition_upgrade_dlc_en_gog_1_20169.sh'
ARCHIVE_GOG_OLD1_MD5='15787edcd3e8031c60fc19c1aae39f3b'
ARCHIVE_GOG_OLD1_SIZE='1400'
ARCHIVE_GOG_OLD1_VERSION='1.0-gog20169'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_war_for_the_overworld_underlord_edition_upgrade_dlc_2.0.0.1.sh'
ARCHIVE_GOG_OLD0_MD5='635912eed200d45d8907ab1fb4cc53a4'
ARCHIVE_GOG_OLD0_SIZE='1400'
ARCHIVE_GOG_OLD0_VERSION='1.0-gog2.0.0.1'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='*'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-underlord-edition"
PKG_MAIN_DEPS="$GAME_ID"

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
