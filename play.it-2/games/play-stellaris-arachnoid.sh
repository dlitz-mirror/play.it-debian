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
# Stellaris - Arachnoid Portrait Pack
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210529.4

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris'

EXPANSION_ID='arachnoid'
EXPANSION_NAME='Arachnoid Portrait Pack'

ARCHIVE_BASE_22='stellaris_arachnoid_portrait_pack_3_0_3_47193.sh'
ARCHIVE_BASE_22_MD5='d9619c256ed79a50cce26398b9ac8c11'
ARCHIVE_BASE_22_TYPE='mojosetup_unzip'
ARCHIVE_BASE_22_SIZE='1200'
ARCHIVE_BASE_22_VERSION='3.0.3-gog47193'
ARCHIVE_BASE_22_URL='https://www.gog.com/game/stellaris_galaxy_edition_upgrade_pack'

ARCHIVE_BASE_21='stellaris_arachnoid_portrait_pack_3_0_2_46477.sh'
ARCHIVE_BASE_21_MD5='320cf1bc719f1c714d7043d0dc120c51'
ARCHIVE_BASE_21_TYPE='mojosetup_unzip'
ARCHIVE_BASE_21_SIZE='1200'
ARCHIVE_BASE_21_VERSION='3.0.2-gog46477'

ARCHIVE_BASE_20='stellaris_arachnoid_portrait_pack_3_0_1_2_46213.sh'
ARCHIVE_BASE_20_MD5='c12157521f4ffa067c96ea38f42e63b4'
ARCHIVE_BASE_20_TYPE='mojosetup_unzip'
ARCHIVE_BASE_20_SIZE='1200'
ARCHIVE_BASE_20_VERSION='3.0.1.2-gog46213'

ARCHIVE_BASE_19='stellaris_arachnoid_portrait_pack_2_8_1_2_42827.sh'
ARCHIVE_BASE_19_MD5='6232966782f11eac72d8106dbde538c9'
ARCHIVE_BASE_19_SIZE='1400'
ARCHIVE_BASE_19_VERSION='2.8.1.2-gog42827'
ARCHIVE_BASE_19_TYPE='mojosetup_unzip'

ARCHIVE_BASE_18='stellaris_arachnoid_portrait_pack_2_8_0_5_42441.sh'
ARCHIVE_BASE_18_MD5='3b50c1fa61e475e83a1a882ed5815e61'
ARCHIVE_BASE_18_SIZE='1400'
ARCHIVE_BASE_18_VERSION='2.8.0.5-gog42441'
ARCHIVE_BASE_18_TYPE='mojosetup_unzip'

ARCHIVE_BASE_17='stellaris_arachnoid_portrait_pack_2_8_0_3_42321.sh'
ARCHIVE_BASE_17_MD5='bc3e4830f3c0a8b01c29e43b468fd04c'
ARCHIVE_BASE_17_SIZE='1400'
ARCHIVE_BASE_17_VERSION='2.8.0.3-gog42321'
ARCHIVE_BASE_17_TYPE='mojosetup_unzip'

ARCHIVE_BASE_16='stellaris_arachnoid_portrait_pack_2_7_2_38578.sh'
ARCHIVE_BASE_16_MD5='d22f4806ef98492c7f10540393e7b0c7'
ARCHIVE_BASE_16_SIZE='1400'
ARCHIVE_BASE_16_VERSION='2.7.2-gog38578'
ARCHIVE_BASE_16_TYPE='mojosetup_unzip'

ARCHIVE_BASE_15='stellaris_arachnoid_portrait_pack_2_7_1_38218.sh'
ARCHIVE_BASE_15_MD5='60d6611b99098184a367e774c3abf04e'
ARCHIVE_BASE_15_SIZE='1400'
ARCHIVE_BASE_15_VERSION='2.7.1-gog38218'
ARCHIVE_BASE_15_TYPE='mojosetup_unzip'

ARCHIVE_BASE_14='stellaris_arachnoid_portrait_pack_2_6_3_2_37617.sh'
ARCHIVE_BASE_14_MD5='d0bf105f5f56f7bdad0a593976076e50'
ARCHIVE_BASE_14_SIZE='1400'
ARCHIVE_BASE_14_VERSION='2.6.3.2-gog37617'
ARCHIVE_BASE_14_TYPE='mojosetup_unzip'

ARCHIVE_BASE_13='stellaris_arachnoid_portrait_pack_2_6_2_37285.sh'
ARCHIVE_BASE_13_MD5='aa0e489a2924893e84b7ce2f8b822ee9'
ARCHIVE_BASE_13_SIZE='1400'
ARCHIVE_BASE_13_VERSION='2.6.2-gog37285'
ARCHIVE_BASE_13_TYPE='mojosetup_unzip'

ARCHIVE_BASE_12='stellaris_arachnoid_portrait_pack_2_6_1_1_36932.sh'
ARCHIVE_BASE_12_MD5='ed0ca8faef3a405bb59f94b602aedcf4'
ARCHIVE_BASE_12_SIZE='1400'
ARCHIVE_BASE_12_VERSION='2.6.1.1-gog36932'
ARCHIVE_BASE_12_TYPE='mojosetup_unzip'

ARCHIVE_BASE_11='stellaris_arachnoid_portrait_pack_2_6_0_4_36778.sh'
ARCHIVE_BASE_11_MD5='448d8207995105b6a767af3af8a15c1d'
ARCHIVE_BASE_11_SIZE='1400'
ARCHIVE_BASE_11_VERSION='2.6.0.4-gog36778'
ARCHIVE_BASE_11_TYPE='mojosetup_unzip'

ARCHIVE_BASE_10='stellaris_arachnoid_portrait_pack_2_5_1_33517.sh'
ARCHIVE_BASE_10_MD5='5dd94f6b41f91ddde9106b406ee6d65b'
ARCHIVE_BASE_10_SIZE='1400'
ARCHIVE_BASE_10_VERSION='2.5.1-gog33517'
ARCHIVE_BASE_10_TYPE='mojosetup_unzip'

ARCHIVE_BASE_9='stellaris_arachnoid_portrait_pack_2_5_0_5_33395.sh'
ARCHIVE_BASE_9_MD5='41bebae230c0ff7bce679676332db1ef'
ARCHIVE_BASE_9_SIZE='1400'
ARCHIVE_BASE_9_VERSION='2.5.0.5-gog33395'
ARCHIVE_BASE_9_TYPE='mojosetup_unzip'

ARCHIVE_BASE_8='stellaris_arachnoid_portrait_pack_2_4_1_1_33112.sh'
ARCHIVE_BASE_8_MD5='f9e8b40b26976241efda3fc483c076bf'
ARCHIVE_BASE_8_SIZE='1400'
ARCHIVE_BASE_8_VERSION='2.4.1.1-gog33112'
ARCHIVE_BASE_8_TYPE='mojosetup_unzip'

ARCHIVE_BASE_7='stellaris_arachnoid_portrait_pack_2_4_1_33088.sh'
ARCHIVE_BASE_7_MD5='cf2ee052c99dd391dc1e5271abe1b4bd'
ARCHIVE_BASE_7_SIZE='1400'
ARCHIVE_BASE_7_VERSION='2.4.1-gog33088'
ARCHIVE_BASE_7_TYPE='mojosetup_unzip'

ARCHIVE_BASE_6='stellaris_arachnoid_portrait_pack_2_4_0_7_33057.sh'
ARCHIVE_BASE_6_MD5='38c2b997d0545b7a7f2e3ddc3db33585'
ARCHIVE_BASE_6_SIZE='1400'
ARCHIVE_BASE_6_VERSION='2.4.0.7-gog33057'
ARCHIVE_BASE_6_TYPE='mojosetup_unzip'

ARCHIVE_BASE_5='stellaris_arachnoid_portrait_pack_2_3_3_1_30901.sh'
ARCHIVE_BASE_5_MD5='6b4eb96220030a77ef2b77753bee241a'
ARCHIVE_BASE_5_SIZE='1300'
ARCHIVE_BASE_5_VERSION='2.3.3.1-gog30901'
ARCHIVE_BASE_5_TYPE='mojosetup_unzip'

ARCHIVE_BASE_4='stellaris_arachnoid_portrait_pack_2_3_3_30733.sh'
ARCHIVE_BASE_4_MD5='5c057dbae5991e41771bff2e8a8761eb'
ARCHIVE_BASE_4_SIZE='1300'
ARCHIVE_BASE_4_VERSION='2.3.3-gog30733'
ARCHIVE_BASE_4_TYPE='mojosetup_unzip'

ARCHIVE_BASE_3='stellaris_arachnoid_portrait_pack_2_3_2_1_30253.sh'
ARCHIVE_BASE_3_MD5='6b52fde34bd0030d0d41c93a72eb17c9'
ARCHIVE_BASE_3_SIZE='1300'
ARCHIVE_BASE_3_VERSION='2.3.2.1-gog30253'
ARCHIVE_BASE_3_TYPE='mojosetup_unzip'

ARCHIVE_BASE_2='stellaris_arachnoid_portrait_pack_2_3_1_2_30059.sh'
ARCHIVE_BASE_2_MD5='e7b1df8eb33beea81976da4247a4cbf3'
ARCHIVE_BASE_2_SIZE='1300'
ARCHIVE_BASE_2_VERSION='2.3.1.2-gog30059'
ARCHIVE_BASE_2_TYPE='mojosetup_unzip'

ARCHIVE_BASE_1='stellaris_arachnoid_portrait_pack_2_3_0_4x_30009.sh'
ARCHIVE_BASE_1_MD5='4a9d8011645ce6829bd624fe131b11c3'
ARCHIVE_BASE_1_SIZE='1300'
ARCHIVE_BASE_1_VERSION='2.3.0.4x-gog30009'
ARCHIVE_BASE_1_TYPE='mojosetup_unzip'

ARCHIVE_BASE_0='stellaris_arachnoid_portrait_pack_2_2_7_2_28548.sh'
ARCHIVE_BASE_0_MD5='fbb9b012a17232085dd355ca90a3bf24'
ARCHIVE_BASE_0_SIZE='1300'
ARCHIVE_BASE_0_VERSION='2.2.7.2-gog28548'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc/dlc002_arachnoid'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-${EXPANSION_ID}"
PKG_MAIN_DESCRIPTION="$EXPANSION_NAME"
PKG_MAIN_DEPS="$GAME_ID"

# Ensure smooth upgrade from pre-20201031.1 packages
PKG_MAIN_PROVIDE='stellaris-arachnoid-portrait-pack'

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
