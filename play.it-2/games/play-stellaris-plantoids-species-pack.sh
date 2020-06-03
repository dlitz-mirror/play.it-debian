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
# Stellaris - Plantoids Species Pack
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200515.1

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris - Plantoids Species Pack'

ARCHIVES_LIST='
ARCHIVE_GOG_11
ARCHIVE_GOG_10
ARCHIVE_GOG_9
ARCHIVE_GOG_8
ARCHIVE_GOG_7
ARCHIVE_GOG_6
ARCHIVE_GOG_5
ARCHIVE_GOG_4
ARCHIVE_GOG_3
ARCHIVE_GOG_2
ARCHIVE_GOG_1
ARCHIVE_GOG_0'

ARCHIVE_GOG_11='stellaris_plantoids_species_pack_2_6_3_2_37617.sh'
ARCHIVE_GOG_11_URL='https://www.gog.com/game/stellaris_plantoids_species_pack'
ARCHIVE_GOG_11_MD5='3d59dfca210276978d2444b0c17e51ac'
ARCHIVE_GOG_11_SIZE='1400'
ARCHIVE_GOG_11_VERSION='2.6.3.2-gog37617'
ARCHIVE_GOG_11_TYPE='mojosetup_unzip'

ARCHIVE_GOG_10='stellaris_plantoids_species_pack_2_6_2_37285.sh'
ARCHIVE_GOG_10_MD5='536278f1362432c45cc02e7bd7daf94f'
ARCHIVE_GOG_10_SIZE='1400'
ARCHIVE_GOG_10_VERSION='2.6.2-gog37285'
ARCHIVE_GOG_10_TYPE='mojosetup_unzip'

ARCHIVE_GOG_9='stellaris_plantoids_species_pack_2_6_1_1_36932.sh'
ARCHIVE_GOG_9_MD5='cc65ed49c5403a40fa969a175f9103fe'
ARCHIVE_GOG_9_SIZE='1400'
ARCHIVE_GOG_9_VERSION='2.6.1.1-gog36932'
ARCHIVE_GOG_9_TYPE='mojosetup_unzip'

ARCHIVE_GOG_8='stellaris_plantoids_species_pack_2_6_0_4_36778.sh'
ARCHIVE_GOG_8_MD5='964cd3bc5c24ee45eeeaf76a1f929276'
ARCHIVE_GOG_8_SIZE='1400'
ARCHIVE_GOG_8_VERSION='2.6.0.4-gog36778'
ARCHIVE_GOG_8_TYPE='mojosetup_unzip'

ARCHIVE_GOG_7='stellaris_plantoids_species_pack_2_5_1_33517.sh'
ARCHIVE_GOG_7_MD5='4253557911f830776d6765fa3d0ea7c7'
ARCHIVE_GOG_7_SIZE='1400'
ARCHIVE_GOG_7_VERSION='2.5.1-gog33517'
ARCHIVE_GOG_7_TYPE='mojosetup_unzip'

ARCHIVE_GOG_6='stellaris_plantoids_species_pack_2_5_0_5_33395.sh'
ARCHIVE_GOG_6_MD5='e0a472efa9de93df6daaef409546d37f'
ARCHIVE_GOG_6_SIZE='1400'
ARCHIVE_GOG_6_VERSION='2.5.0.5-gog33395'
ARCHIVE_GOG_6_TYPE='mojosetup_unzip'

ARCHIVE_GOG_5='stellaris_plantoids_species_pack_2_4_1_1_33112.sh'
ARCHIVE_GOG_5_MD5='77a7baf5e6c053df54a94cbad695880b'
ARCHIVE_GOG_5_SIZE='1400'
ARCHIVE_GOG_5_VERSION='2.4.1.1-gog33112'
ARCHIVE_GOG_5_TYPE='mojosetup_unzip'

ARCHIVE_GOG_4='stellaris_plantoids_species_pack_2_4_1_33088.sh'
ARCHIVE_GOG_4_MD5='7398caec78dce20509bd855f12142be7'
ARCHIVE_GOG_4_SIZE='1400'
ARCHIVE_GOG_4_VERSION='2.4.1-gog33088'
ARCHIVE_GOG_4_TYPE='mojosetup_unzip'

ARCHIVE_GOG_3='stellaris_plantoids_species_pack_2_4_0_7_33057.sh'
ARCHIVE_GOG_3_MD5='b28ef109f37874b8b3328797f8eafbad'
ARCHIVE_GOG_3_SIZE='1400'
ARCHIVE_GOG_3_VERSION='2.4.0.7-gog33057'
ARCHIVE_GOG_3_TYPE='mojosetup_unzip'

ARCHIVE_GOG_2='stellaris_plantoids_species_pack_2_3_3_1_30901.sh'
ARCHIVE_GOG_2_MD5='8312d804898d8508dc221c7e513b9798'
ARCHIVE_GOG_2_SIZE='1300'
ARCHIVE_GOG_2_VERSION='2.3.3.1-gog30901'
ARCHIVE_GOG_2_TYPE='mojosetup_unzip'

ARCHIVE_GOG_1='stellaris_plantoids_species_pack_2_3_3_30733.sh'
ARCHIVE_GOG_1_MD5='9ee0a135b8daaaf8c8133a17265fc70f'
ARCHIVE_GOG_1_SIZE='1300'
ARCHIVE_GOG_1_VERSION='2.3.3-gog30733'
ARCHIVE_GOG_1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_0='stellaris_plantoids_species_pack_2_3_2_1_30253.sh'
ARCHIVE_GOG_0_MD5='060a450f1836eb52c54739945824afed'
ARCHIVE_GOG_0_SIZE='1300'
ARCHIVE_GOG_0_VERSION='2.3.2.1-gog30253'
ARCHIVE_GOG_0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc/dlc004_plantoid'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-plantoids-species-pack"
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
