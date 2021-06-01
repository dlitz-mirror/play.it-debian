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
# Stellaris - Horizon Signal
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210529.4

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris'

EXPANSION_ID='horizon-signal'
EXPANSION_NAME='Horizon Signal'

ARCHIVE_BASE_24='stellaris_horizon_signal_3_0_3_47193.sh'
ARCHIVE_BASE_24_MD5='40ddcd078680c3ab2bb5e98d7658bfa9'
ARCHIVE_BASE_24_TYPE='mojosetup_unzip'
ARCHIVE_BASE_24_SIZE='1200'
ARCHIVE_BASE_24_VERSION='3.0.3-gog47193'
ARCHIVE_BASE_24_URL='https://www.gog.com/game/stellaris_horizon_signal'

ARCHIVE_BASE_23='stellaris_horizon_signal_3_0_2_46477.sh'
ARCHIVE_BASE_23_MD5='2564fe58a6af8f53e08e66ee587c916d'
ARCHIVE_BASE_23_TYPE='mojosetup_unzip'
ARCHIVE_BASE_23_SIZE='1200'
ARCHIVE_BASE_23_VERSION='3.0.2-gog46477'

ARCHIVE_BASE_22='stellaris_horizon_signal_3_0_1_2_46213.sh'
ARCHIVE_BASE_22_MD5='c40c644c8de6b6835f75e4508a5603bb'
ARCHIVE_BASE_22_TYPE='mojosetup_unzip'
ARCHIVE_BASE_22_SIZE='1200'
ARCHIVE_BASE_22_VERSION='3.0.1.2-gog46213'

ARCHIVE_BASE_21='stellaris_horizon_signal_2_8_1_2_42827.sh'
ARCHIVE_BASE_21_MD5='0e9f53918e8b489add020cf91b4492e8'
ARCHIVE_BASE_21_SIZE='1400'
ARCHIVE_BASE_21_VERSION='2.8.1.2-gog42827'
ARCHIVE_BASE_21_TYPE='mojosetup_unzip'

ARCHIVE_BASE_20='stellaris_horizon_signal_2_8_0_5_42441.sh'
ARCHIVE_BASE_20_MD5='ebd447e121363dbd9ef28b2e060ba9ff'
ARCHIVE_BASE_20_SIZE='1400'
ARCHIVE_BASE_20_VERSION='2.8.0.5-gog42441'
ARCHIVE_BASE_20_TYPE='mojosetup_unzip'

ARCHIVE_BASE_19='stellaris_horizon_signal_2_8_0_3_42321.sh'
ARCHIVE_BASE_19_MD5='96a89b87808b32097f9f9446819cafc9'
ARCHIVE_BASE_19_SIZE='1400'
ARCHIVE_BASE_19_VERSION='2.8.0.3-gog42321'
ARCHIVE_BASE_19_TYPE='mojosetup_unzip'

ARCHIVE_BASE_18='stellaris_horizon_signal_2_7_2_38578.sh'
ARCHIVE_BASE_18_MD5='8afefafaddba2dc3e83e4b9a8321a6d3'
ARCHIVE_BASE_18_SIZE='1400'
ARCHIVE_BASE_18_VERSION='2.7.2-gog38578'
ARCHIVE_BASE_18_TYPE='mojosetup_unzip'

ARCHIVE_BASE_17='stellaris_horizon_signal_2_7_1_38218.sh'
ARCHIVE_BASE_17_MD5='248a8f7346b5f56143b61d519917065c'
ARCHIVE_BASE_17_SIZE='1400'
ARCHIVE_BASE_17_VERSION='2.7.1-gog38218'
ARCHIVE_BASE_17_TYPE='mojosetup_unzip'

ARCHIVE_BASE_16='stellaris_horizon_signal_2_6_3_2_37617.sh'
ARCHIVE_BASE_16_MD5='26b1e116e2090da52b6b86b73bcd21ea'
ARCHIVE_BASE_16_SIZE='1400'
ARCHIVE_BASE_16_VERSION='2.6.3.2-gog37617'
ARCHIVE_BASE_16_TYPE='mojosetup_unzip'

ARCHIVE_BASE_15='stellaris_horizon_signal_2_6_2_37285.sh'
ARCHIVE_BASE_15_MD5='2fd1629168d844efb449af0e8606ad0e'
ARCHIVE_BASE_15_SIZE='1400'
ARCHIVE_BASE_15_VERSION='2.6.2-gog37285'
ARCHIVE_BASE_15_TYPE='mojosetup_unzip'

ARCHIVE_BASE_14='stellaris_horizon_signal_2_6_1_1_36932.sh'
ARCHIVE_BASE_14_MD5='787decd211c93b92a0467112a0bdd6b3'
ARCHIVE_BASE_14_SIZE='1400'
ARCHIVE_BASE_14_VERSION='2.6.1.1-gog36932'
ARCHIVE_BASE_14_TYPE='mojosetup_unzip'

ARCHIVE_BASE_13='stellaris_horizon_signal_2_6_0_4_36778.sh'
ARCHIVE_BASE_13_MD5='ca8705bc38567b2d6cd923f36a4c73a2'
ARCHIVE_BASE_13_SIZE='1400'
ARCHIVE_BASE_13_VERSION='2.6.0.4-gog36778'
ARCHIVE_BASE_13_TYPE='mojosetup_unzip'

ARCHIVE_BASE_12='stellaris_horizon_signal_2_5_1_33517.sh'
ARCHIVE_BASE_12_MD5='a36b3473ad1669cc39f86c287e66e6ad'
ARCHIVE_BASE_12_SIZE='1400'
ARCHIVE_BASE_12_VERSION='2.5.1-gog33517'
ARCHIVE_BASE_12_TYPE='mojosetup_unzip'

ARCHIVE_BASE_11='stellaris_horizon_signal_2_5_0_5_33395.sh'
ARCHIVE_BASE_11_MD5='61746bd87a0cbd22d4d98281f585bfc2'
ARCHIVE_BASE_11_SIZE='1400'
ARCHIVE_BASE_11_VERSION='2.5.0.5-gog33395'
ARCHIVE_BASE_11_TYPE='mojosetup_unzip'

ARCHIVE_BASE_10='stellaris_horizon_signal_2_4_1_1_33112.sh'
ARCHIVE_BASE_10_MD5='0a519147bfb6af4aa509fbd6def7eda6'
ARCHIVE_BASE_10_SIZE='1400'
ARCHIVE_BASE_10_VERSION='2.4.1.1-gog33112'
ARCHIVE_BASE_10_TYPE='mojosetup_unzip'

ARCHIVE_BASE_9='stellaris_horizon_signal_2_4_1_33088.sh'
ARCHIVE_BASE_9_MD5='23d9ceedee2b919596f12a59cf1f47d1'
ARCHIVE_BASE_9_SIZE='1400'
ARCHIVE_BASE_9_VERSION='2.4.1-gog33088'
ARCHIVE_BASE_9_TYPE='mojosetup_unzip'

ARCHIVE_BASE_8='stellaris_horizon_signal_2_4_0_7_33057.sh'
ARCHIVE_BASE_8_MD5='6fdb17badf8a0e39ab3f8c2597552c12'
ARCHIVE_BASE_8_SIZE='1400'
ARCHIVE_BASE_8_VERSION='2.4.0.7-gog33057'
ARCHIVE_BASE_8_TYPE='mojosetup_unzip'

ARCHIVE_BASE_7='stellaris_horizon_signal_2_3_3_1_30901.sh'
ARCHIVE_BASE_7_MD5='c7273e17a0f412ab17cf7e21a6e5fb16'
ARCHIVE_BASE_7_SIZE='1300'
ARCHIVE_BASE_7_VERSION='2.3.3.1-gog30901'
ARCHIVE_BASE_7_TYPE='mojosetup_unzip'

ARCHIVE_BASE_6='stellaris_horizon_signal_2_3_3_30733.sh'
ARCHIVE_BASE_6_MD5='cae26d668625d828f04132781767b36c'
ARCHIVE_BASE_6_SIZE='1300'
ARCHIVE_BASE_6_VERSION='2.3.3-gog30733'
ARCHIVE_BASE_6_TYPE='mojosetup_unzip'

ARCHIVE_BASE_5='stellaris_horizon_signal_2_3_2_1_30253.sh'
ARCHIVE_BASE_5_MD5='9d6f047648c46694df2141873019d014'
ARCHIVE_BASE_5_SIZE='1300'
ARCHIVE_BASE_5_VERSION='2.3.2.1-gog30253'
ARCHIVE_BASE_5_TYPE='mojosetup_unzip'

ARCHIVE_BASE_4='stellaris_horizon_signal_2_3_1_2_30059.sh'
ARCHIVE_BASE_4_MD5='a8e8356ad5fc69af7f78d7a4d1b314b1'
ARCHIVE_BASE_4_SIZE='1300'
ARCHIVE_BASE_4_VERSION='2.3.1.2-gog30059'
ARCHIVE_BASE_4_TYPE='mojosetup_unzip'

ARCHIVE_BASE_3='stellaris_horizon_signal_2_3_0_4x_30009.sh'
ARCHIVE_BASE_3_MD5='78fd1892b20677f60cf01def3c86a4ad'
ARCHIVE_BASE_3_SIZE='1300'
ARCHIVE_BASE_3_VERSION='2.3.0.4x-gog30009'
ARCHIVE_BASE_3_TYPE='mojosetup_unzip'

ARCHIVE_BASE_2='stellaris_horizon_signal_2_2_7_2_28548.sh'
ARCHIVE_BASE_2_MD5='a3227ae44bebe64a9182af71df1b3000'
ARCHIVE_BASE_2_SIZE='1300'
ARCHIVE_BASE_2_VERSION='2.2.7.2-gog28548'
ARCHIVE_BASE_2_TYPE='mojosetup_unzip'

ARCHIVE_BASE_1='stellaris_horizon_signal_2_2_6_4_28215.sh'
ARCHIVE_BASE_1_MD5='fd58ce9eca3f619dc3dbd969e0f92895'
ARCHIVE_BASE_1_SIZE='1300'
ARCHIVE_BASE_1_VERSION='2.2.6.4-gog28215'
ARCHIVE_BASE_1_TYPE='mojosetup_unzip'

ARCHIVE_BASE_0='stellaris_horizon_signal_2_2_4_26846.sh'
ARCHIVE_BASE_0_MD5='484a8f3e514eb1593229fe3ba551c942'
ARCHIVE_BASE_0_SIZE='1300'
ARCHIVE_BASE_0_VERSION='2.2.4-gog26846'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc/dlc013_horizon_signal'
# Keep compatibility with old archives
ARCHIVE_GAME_MAIN_PATH_GOG_1='data/noarch/game/dlc/dlc013_horizon_signal'
ARCHIVE_GAME_MAIN_PATH_GOG_0='data/noarch/game/dlc/dlc013_horizon_signal'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-${EXPANSION_ID}"
PKG_MAIN_DESCRIPTION="$EXPANSION_NAME"
PKG_MAIN_DEPS="$GAME_ID"

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
