#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Stellaris - Humanoids Species Pack
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201120.1

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris'

EXPANSION_ID='humanoids'
EXPANSION_NAME='Humanoids Species Pack'

ARCHIVES_LIST='
ARCHIVE_GOG_14
ARCHIVE_GOG_13
ARCHIVE_GOG_12
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

ARCHIVE_GOG_14='stellaris_humanoids_species_pack_2_8_0_3_42321.sh'
ARCHIVE_GOG_14_URL='https://www.gog.com/game/stellaris_humanoids_species_pack'
ARCHIVE_GOG_14_MD5='cb509344d223f04b9c0edaaa13c298a6'
ARCHIVE_GOG_14_SIZE='120000'
ARCHIVE_GOG_14_VERSION='2.8.0.3-gog42321'
ARCHIVE_GOG_14_TYPE='mojosetup_unzip'

ARCHIVE_GOG_13='stellaris_humanoids_species_pack_2_7_2_38578.sh'
ARCHIVE_GOG_13_MD5='066f60345e31ce921d3df602382ca02c'
ARCHIVE_GOG_13_SIZE='120000'
ARCHIVE_GOG_13_VERSION='2.7.2-gog38578'
ARCHIVE_GOG_13_TYPE='mojosetup_unzip'

ARCHIVE_GOG_12='stellaris_humanoids_species_pack_2_7_1_38218.sh'
ARCHIVE_GOG_12_MD5='d6724e4dc260fdcea76f8be5427af850'
ARCHIVE_GOG_12_SIZE='120000'
ARCHIVE_GOG_12_VERSION='2.7.1-gog38218'
ARCHIVE_GOG_12_TYPE='mojosetup_unzip'

ARCHIVE_GOG_11='stellaris_humanoids_species_pack_2_6_3_2_37617.sh'
ARCHIVE_GOG_11_URL='https://www.gog.com/game/stellaris_humanoids_species_pack'
ARCHIVE_GOG_11_MD5='08365a3fcc021681c8d8c16f2a96020b'
ARCHIVE_GOG_11_SIZE='120000'
ARCHIVE_GOG_11_VERSION='2.6.3.2-gog37617'
ARCHIVE_GOG_11_TYPE='mojosetup_unzip'

ARCHIVE_GOG_10='stellaris_humanoids_species_pack_2_6_2_37285.sh'
ARCHIVE_GOG_10_MD5='016609e948a2cdff1e8d278892573159'
ARCHIVE_GOG_10_SIZE='120000'
ARCHIVE_GOG_10_VERSION='2.6.2-gog37285'
ARCHIVE_GOG_10_TYPE='mojosetup_unzip'

ARCHIVE_GOG_9='stellaris_humanoids_species_pack_2_6_1_1_36932.sh'
ARCHIVE_GOG_9_MD5='1a1c595117fb7cbb37c6e84b989112d3'
ARCHIVE_GOG_9_SIZE='120000'
ARCHIVE_GOG_9_VERSION='2.6.1.1-gog36932'
ARCHIVE_GOG_9_TYPE='mojosetup_unzip'

ARCHIVE_GOG_8='stellaris_humanoids_species_pack_2_6_0_4_36778.sh'
ARCHIVE_GOG_8_MD5='1319f37c51e676f40708c1a9657376b2'
ARCHIVE_GOG_8_SIZE='120000'
ARCHIVE_GOG_8_VERSION='2.6.0.4-gog36778'
ARCHIVE_GOG_8_TYPE='mojosetup_unzip'

ARCHIVE_GOG_7='stellaris_humanoids_species_pack_2_5_1_33517.sh'
ARCHIVE_GOG_7_MD5='0832471cf232a1a5d5567258c98fa99b'
ARCHIVE_GOG_7_SIZE='120000'
ARCHIVE_GOG_7_VERSION='2.5.1-gog33517'
ARCHIVE_GOG_7_TYPE='mojosetup_unzip'

ARCHIVE_GOG_6='stellaris_humanoids_species_pack_2_5_0_5_33395.sh'
ARCHIVE_GOG_6_MD5='3bfe1467c1d040625de13f72eb744ce5'
ARCHIVE_GOG_6_SIZE='120000'
ARCHIVE_GOG_6_VERSION='2.5.0.5-gog33395'
ARCHIVE_GOG_6_TYPE='mojosetup_unzip'

ARCHIVE_GOG_5='stellaris_humanoids_species_pack_2_4_1_1_33112.sh'
ARCHIVE_GOG_5_MD5='c4ca371cdb0695d2050d70ce52e60914'
ARCHIVE_GOG_5_SIZE='120000'
ARCHIVE_GOG_5_VERSION='2.4.1.1-gog33112'
ARCHIVE_GOG_5_TYPE='mojosetup_unzip'

ARCHIVE_GOG_4='stellaris_humanoids_species_pack_2_4_1_33088.sh'
ARCHIVE_GOG_4_MD5='12c9649abd6f1695e2e3ddcedd2d7afc'
ARCHIVE_GOG_4_SIZE='120000'
ARCHIVE_GOG_4_VERSION='2.4.1-gog33088'
ARCHIVE_GOG_4_TYPE='mojosetup_unzip'

ARCHIVE_GOG_3='stellaris_humanoids_species_pack_2_4_0_7_33057.sh'
ARCHIVE_GOG_3_MD5='c2b55b152e8225959e3c1b44fdd79c44'
ARCHIVE_GOG_3_SIZE='120000'
ARCHIVE_GOG_3_VERSION='2.4.0.7-gog33057'
ARCHIVE_GOG_3_TYPE='mojosetup_unzip'

ARCHIVE_GOG_2='stellaris_humanoids_species_pack_2_3_3_1_30901.sh'
ARCHIVE_GOG_2_MD5='0c12e80e91ea13dd94780ca462593ac0'
ARCHIVE_GOG_2_SIZE='120000'
ARCHIVE_GOG_2_VERSION='2.3.3.1-gog30901'
ARCHIVE_GOG_2_TYPE='mojosetup_unzip'

ARCHIVE_GOG_1='stellaris_humanoids_species_pack_2_3_3_30733.sh'
ARCHIVE_GOG_1_MD5='4dbdb3b43bfea5a54bb17a03caae8af1'
ARCHIVE_GOG_1_SIZE='120000'
ARCHIVE_GOG_1_VERSION='2.3.3-gog30733'
ARCHIVE_GOG_1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_0='stellaris_humanoids_species_pack_2_3_2_1_30253.sh'
ARCHIVE_GOG_0_MD5='43492dcd83d7a43cd81593ae1a3110e4'
ARCHIVE_GOG_0_SIZE='120000'
ARCHIVE_GOG_0_VERSION='2.3.2.1-gog30253'
ARCHIVE_GOG_0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc/dlc018_humanoids'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-${EXPANSION_ID}"
PKG_MAIN_DESCRIPTION="$EXPANSION_NAME"
PKG_MAIN_DEPS="$GAME_ID"

# Ensure smooth upgrade from pre-20201031.1 packages
PKG_MAIN_PROVIDE='stellaris-humanoids-species-pack'

# Load common functions

target_version='2.12'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
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

GAME_NAME="$GAME_NAME - $EXPANSION_NAME"
print_instructions

exit 0
