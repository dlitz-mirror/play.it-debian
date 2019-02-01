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
# Baldur’s Gate - Enhanced Edition - Siege of Dragonspear
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180929.2

# Set game-specific variables

GAME_ID='baldurs-gate-1-enhanced-edition'
GAME_NAME='Baldur’s Gate - Enhanced Edition - Siege of Dragonspear'

ARCHIVE_GOG='baldur_s_gate_siege_of_dragonspear_en_2_5_23121.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/baldurs_gate_siege_of_dragonspear'
ARCHIVE_GOG_MD5='f0581c46e9d31a7ef53be88cf85eccc8'
ARCHIVE_GOG_VERSION='2.5.17.0-gog23121'
ARCHIVE_GOG_TYPE='mojosetup_unzip'
ARCHIVE_GOG_SIZE='1900000'

ARCHIVE_GOG_OLD0='baldur_s_gate_siege_of_dragonspear_en_2_3_0_4_20148.sh'
ARCHIVE_GOG_OLD0_MD5='152225ec02c87e70bfb59970ac33b755'
ARCHIVE_GOG_OLD0_VERSION='2.3.0.4-gog20148'
ARCHIVE_GOG_OLD0_TYPE='mojosetup_unzip'
ARCHIVE_GOG_OLD0_SIZE='1900000'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='sod-dlc.zip'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-siege-of-dragonspear"
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
