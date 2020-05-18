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
# Pillars of Eternity: The White March Part Ⅰ
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200202.1

# Set game-specific variables

GAME_ID='pillars-of-eternity-1'
GAME_NAME='Pillars of Eternity: The White March Part Ⅰ'

ARCHIVE_GOG='pillars_of_eternity_white_march_part_1_dlc_en_3_07_0_1318_17464.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/pillars_of_eternity_the_white_march_part_1'
ARCHIVE_GOG_MD5='cc72f59ee20238ff05c47646b4618f01'
ARCHIVE_GOG_SIZE='5600000'
ARCHIVE_GOG_VERSION='3.7.0.1318-gog17464'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='pillars_of_eternity_white_march_part_1_dlc_en_3_07_16598.sh'
ARCHIVE_GOG_OLD2_MD5='054b6af430da1ed2635b9c6b4ed56866'
ARCHIVE_GOG_OLD2_SIZE='5500000'
ARCHIVE_GOG_OLD2_VERSION='3.7.0.1284-gog16598'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='gog_pillars_of_eternity_white_march_part_1_dlc_2.10.0.12.sh'
ARCHIVE_GOG_OLD1_MD5='8fafcb549fffd2de24f381a85e859622'
ARCHIVE_GOG_OLD1_SIZE='5500000'
ARCHIVE_GOG_OLD1_VERSION='3.06.1254-gog2.10.0.12'

ARCHIVE_GOG_OLD0='gog_pillars_of_eternity_white_march_part_1_dlc_2.9.0.11.sh'
ARCHIVE_GOG_OLD0_MD5='98424615626c82ed723860d421f187b6'
ARCHIVE_GOG_OLD0_SIZE='5500000'
ARCHIVE_GOG_OLD0_VERSION='3.05.1186-gog2.9.0.11'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='*'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-the-white-march-part-1"
PKG_MAIN_DEPS="$GAME_ID"
# Easier upgrade from packages generated with pre-20200202.1 script
PKG_MAIN_PROVIDE='pillars-of-eternity-px1'

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
