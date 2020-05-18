#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, Janeene "dawnmist" Beeforth
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
# Stellaris Dome Set for Surviving Mars.
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200315.1

# Set game-specific variables

# copy GAME_ID from play-surviving-mars.sh
GAME_ID='surviving-mars'
GAME_NAME='Surviving Mars: Stellaris Dome Set'

ARCHIVE_GOG='surviving_mars_stellaris_dome_set_sagan_rc3_update_24111.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/surviving_mars_stellaris_dome_set'
ARCHIVE_GOG_MD5='7759d7fa7f9d99a693a828a6c5db601f'
ARCHIVE_GOG_SIZE='4000'
ARCHIVE_GOG_VERSION='24111'
ARCHIVE_GOG_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD1='surviving_mars_stellaris_dome_set_sagan_rc1_update_23676.sh'
ARCHIVE_GOG_OLD1_MD5='2b0f7100813779cdd847be15b6599fea'
ARCHIVE_GOG_OLD1_SIZE='4000'
ARCHIVE_GOG_OLD1_VERSION='23676'
ARCHIVE_GOG_OLD1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD0='surviving_mars_stellaris_dome_set_pre_order_dlc_en_180619_curiosity_hotfix_3_21661.sh'
ARCHIVE_GOG_OLD0_MD5='01ffc529b9a0cc72e5d94830385bf7b9'
ARCHIVE_GOG_OLD0_SIZE='4000'
ARCHIVE_GOG_OLD0_VERSION='3-gog21661'
ARCHIVE_GOG_OLD0_TYPE='mojosetup_unzip'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='DLC'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-stellaris-dome-set"
PKG_MAIN_DEPS="$GAME_ID"

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
