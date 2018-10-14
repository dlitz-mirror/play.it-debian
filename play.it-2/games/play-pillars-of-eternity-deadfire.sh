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
# Pillars of Eternity: Deadfire Pack
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180919.2

# Set game-specific variables

GAME_ID='pillars-of-eternity'
GAME_NAME='Pillars of Eternity: Deadfire Pack'

ARCHIVE_GOG='pillars_of_eternity_deadfire_pack_dlc_en_3_07_0_1318_20099.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/pillars_of_eternity_deadfire_pack'
ARCHIVE_GOG_MD5='da315aba26784e55aa51139cebb7f9d2'
ARCHIVE_GOG_TYPE='mojosetup'
ARCHIVE_GOG_SIZE='1300'
ARCHIVE_GOG_VERSION='3.07.0.1318-gog20099'

ARCHIVE_GOG_OLD1='pillars_of_eternity_deadfire_pack_dlc_en_3_07_0_1318_17462.sh'
ARCHIVE_GOG_OLD1_MD5='021362da5912dc8a3e47473e97726f7f'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'
ARCHIVE_GOG_OLD1_SIZE='1300'
ARCHIVE_GOG_OLD1_VERSION='3.07.0.1318-gog17462'

ARCHIVE_GOG_OLD0='pillars_of_eternity_deadfire_pack_dlc_en_3_07_16380.sh'
ARCHIVE_GOG_OLD0_MD5='2fc0dc21648953be1c571e28b1e3d002'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'
ARCHIVE_GOG_OLD0_SIZE='1300'
ARCHIVE_GOG_OLD0_VERSION='3.07-gog16380'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='PillarsOfEternity_Data/assetbundles/px4.unity3d'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-deadfire-pack"
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
