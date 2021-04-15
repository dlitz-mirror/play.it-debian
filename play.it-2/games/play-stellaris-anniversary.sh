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
# Stellaris - Anniversary Portraits + Creatures of the Void Portrait Pack
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210529.4

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris'

EXPANSION_ID='anniversary'
EXPANSION_NAME='Anniversary Portraits'

EXPANSION_VOID_ID='creatures-of-the-void'
EXPANSION_VOID_NAME='Creatures of the Void'

ARCHIVE_BASE_21='stellaris_anniversary_portraits_3_0_3_47193.sh'
ARCHIVE_BASE_21_MD5='53b0dd554774acd8aa821b5be741b4d8'
ARCHIVE_BASE_21_TYPE='mojosetup_unzip'
ARCHIVE_BASE_21_SIZE='1200'
ARCHIVE_BASE_21_VERSION='3.0.3-gog47193'
ARCHIVE_BASE_21_URL='https://www.gog.com/game/stellaris_anniversary_portraits'

ARCHIVE_BASE_20='stellaris_anniversary_portraits_3_0_2_46477.sh'
ARCHIVE_BASE_20_MD5='f30aae53e87a87c11aa7aaf3d158ea8b'
ARCHIVE_BASE_20_TYPE='mojosetup_unzip'
ARCHIVE_BASE_20_SIZE='1200'
ARCHIVE_BASE_20_VERSION='3.0.2-gog46477'

ARCHIVE_BASE_19='stellaris_anniversary_portraits_3_0_1_2_46213.sh'
ARCHIVE_BASE_19_MD5='fac29a0816d863d68eb0522cd2f1e7f1'
ARCHIVE_BASE_19_TYPE='mojosetup_unzip'
ARCHIVE_BASE_19_SIZE='1200'
ARCHIVE_BASE_19_VERSION='3.0.1.2-gog46213'

ARCHIVE_BASE_18='stellaris_anniversary_portraits_2_8_1_2_42827.sh'
ARCHIVE_BASE_18_MD5='d4304d0cb6559d0147739148fc123285'
ARCHIVE_BASE_18_SIZE='1400'
ARCHIVE_BASE_18_VERSION='2.8.1.2-gog42827'
ARCHIVE_BASE_18_TYPE='mojosetup_unzip'

ARCHIVE_BASE_17='stellaris_anniversary_portraits_2_8_0_5_42441.sh'
ARCHIVE_BASE_17_MD5='e3068f7d91814711a327f66a47e48bce'
ARCHIVE_BASE_17_SIZE='1400'
ARCHIVE_BASE_17_VERSION='2.8.0.5-gog42441'
ARCHIVE_BASE_17_TYPE='mojosetup_unzip'

ARCHIVE_BASE_16='stellaris_anniversary_portraits_2_8_0_3_42321.sh'
ARCHIVE_BASE_16_MD5='ca3ddc40e9d8dd064366eea179452c4f'
ARCHIVE_BASE_16_SIZE='1400'
ARCHIVE_BASE_16_VERSION='2.8.0.3-gog42321'
ARCHIVE_BASE_16_TYPE='mojosetup_unzip'

ARCHIVE_BASE_15='stellaris_anniversary_portraits_2_7_2_38578.sh'
ARCHIVE_BASE_15_MD5='90c744f460570fbab96176a39cb4b857'
ARCHIVE_BASE_15_SIZE='1400'
ARCHIVE_BASE_15_VERSION='2.7.2-gog38578'
ARCHIVE_BASE_15_TYPE='mojosetup_unzip'

ARCHIVE_BASE_14='stellaris_anniversary_portraits_2_7_1_38218.sh'
ARCHIVE_BASE_14_MD5='cbbf4772108cd00710c7a4bcac22a1f2'
ARCHIVE_BASE_14_SIZE='1400'
ARCHIVE_BASE_14_VERSION='2.7.1-gog38218'
ARCHIVE_BASE_14_TYPE='mojosetup_unzip'

ARCHIVE_BASE_13='stellaris_anniversary_portraits_2_6_3_2_37617.sh'
ARCHIVE_BASE_13_MD5='a757a0b1c5470ed2ed9cb06cd00458e5'
ARCHIVE_BASE_13_SIZE='1400'
ARCHIVE_BASE_13_VERSION='2.6.3.2-gog37617'
ARCHIVE_BASE_13_TYPE='mojosetup_unzip'

ARCHIVE_BASE_12='stellaris_anniversary_portraits_2_6_2_37285.sh'
ARCHIVE_BASE_12_MD5='09d681173e2785c8e590c687d3f5a240'
ARCHIVE_BASE_12_SIZE='1400'
ARCHIVE_BASE_12_VERSION='2.6.2-gog37285'
ARCHIVE_BASE_12_TYPE='mojosetup_unzip'

ARCHIVE_BASE_11='stellaris_anniversary_portraits_2_6_1_1_36932.sh'
ARCHIVE_BASE_11_MD5='d7a4485713673794030a65924fa45d79'
ARCHIVE_BASE_11_SIZE='1400'
ARCHIVE_BASE_11_VERSION='2.6.1.1-gog36932'
ARCHIVE_BASE_11_TYPE='mojosetup_unzip'

ARCHIVE_BASE_10='stellaris_anniversary_portraits_2_6_0_4_36778.sh'
ARCHIVE_BASE_10_MD5='98758b31ee405cd615d2036b79d7cc0f'
ARCHIVE_BASE_10_SIZE='1400'
ARCHIVE_BASE_10_VERSION='2.6.0.4-gog36778'
ARCHIVE_BASE_10_TYPE='mojosetup_unzip'

ARCHIVE_BASE_9='stellaris_anniversary_portraits_2_5_1_33517.sh'
ARCHIVE_BASE_9_MD5='3231b08ff883239e98bea2a9adb841e2'
ARCHIVE_BASE_9_SIZE='1400'
ARCHIVE_BASE_9_VERSION='2.5.1-gog33517'
ARCHIVE_BASE_9_TYPE='mojosetup_unzip'

ARCHIVE_BASE_8='stellaris_anniversary_portraits_2_5_0_5_33395.sh'
ARCHIVE_BASE_8_MD5='813ca5d320ba55c5300b9cb10454a4e5'
ARCHIVE_BASE_8_SIZE='1400'
ARCHIVE_BASE_8_VERSION='2.5.0.5-gog33395'
ARCHIVE_BASE_8_TYPE='mojosetup_unzip'

ARCHIVE_BASE_7='stellaris_anniversary_portraits_2_4_1_1_33112.sh'
ARCHIVE_BASE_7_MD5='d91b95860510e7ce2fad6a8a5b562172'
ARCHIVE_BASE_7_SIZE='1400'
ARCHIVE_BASE_7_VERSION='2.4.1.1-gog33112'
ARCHIVE_BASE_7_TYPE='mojosetup_unzip'

ARCHIVE_BASE_6='stellaris_anniversary_portraits_2_4_1_33088.sh'
ARCHIVE_BASE_6_MD5='dda16c2268882cbe3c779728f36c7929'
ARCHIVE_BASE_6_SIZE='1400'
ARCHIVE_BASE_6_VERSION='2.4.1-gog33088'
ARCHIVE_BASE_6_TYPE='mojosetup_unzip'

ARCHIVE_BASE_5='stellaris_anniversary_portraits_2_4_0_7_33057.sh'
ARCHIVE_BASE_5_MD5='72ff42a55738d005681f8ca06a9562e9'
ARCHIVE_BASE_5_SIZE='1400'
ARCHIVE_BASE_5_VERSION='2.4.0.7-gog33057'
ARCHIVE_BASE_5_TYPE='mojosetup_unzip'

ARCHIVE_BASE_4='stellaris_anniversary_portraits_2_3_3_1_30901.sh'
ARCHIVE_BASE_4_MD5='24b4bfe3a5f2e70858cf14d0af2e268a'
ARCHIVE_BASE_4_SIZE='1300'
ARCHIVE_BASE_4_VERSION='2.3.3.1-gog30901'
ARCHIVE_BASE_4_TYPE='mojosetup_unzip'

ARCHIVE_BASE_3='stellaris_anniversary_portraits_2_3_3_30733.sh'
ARCHIVE_BASE_3_MD5='93baefe99fd0c9fde17a90bbc11fb6a9'
ARCHIVE_BASE_3_SIZE='1300'
ARCHIVE_BASE_3_VERSION='2.3.3-gog30733'
ARCHIVE_BASE_3_TYPE='mojosetup_unzip'

ARCHIVE_BASE_2='stellaris_anniversary_portraits_2_3_2_1_30253.sh'
ARCHIVE_BASE_2_MD5='fcde86358e3ccd6972b04477bfbd918f'
ARCHIVE_BASE_2_SIZE='1300'
ARCHIVE_BASE_2_VERSION='2.3.2.1-gog30253'
ARCHIVE_BASE_2_TYPE='mojosetup_unzip'

ARCHIVE_BASE_1='stellaris_anniversary_portraits_2_3_1_2_30059.sh'
ARCHIVE_BASE_1_MD5='d0d558eb89f91cde08f166d9d91aa932'
ARCHIVE_BASE_1_SIZE='1300'
ARCHIVE_BASE_1_VERSION='2.3.1.2-gog30059'
ARCHIVE_BASE_1_TYPE='mojosetup_unzip'

ARCHIVE_BASE_0='stellaris_anniversary_portraits_2_3_0_4x_30009.sh'
ARCHIVE_BASE_0_MD5='6eb4b3d12c658b956a54e7946c856563'
ARCHIVE_BASE_0_SIZE='1300'
ARCHIVE_BASE_0_VERSION='2.3.0.4x-gog30009'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'

ARCHIVE_BASE_UNMERGED_2='stellaris_anniversary_portraits_2_2_7_2_28548.sh'
ARCHIVE_BASE_UNMERGED_2_MD5='2246af9530b1a2a8d6a7c3afabe54eec'
ARCHIVE_BASE_UNMERGED_2_SIZE='1300'
ARCHIVE_BASE_UNMERGED_2_VERSION='2.2.7.2-gog28548'
ARCHIVE_BASE_UNMERGED_2_TYPE='mojosetup_unzip'

ARCHIVE_BASE_UNMERGED_1='stellaris_anniversary_portraits_2_2_6_4_28215.sh'
ARCHIVE_BASE_UNMERGED_1_MD5='ab450823054b77bd63a4906a343d10ac'
ARCHIVE_BASE_UNMERGED_1_SIZE='1300'
ARCHIVE_BASE_UNMERGED_1_VERSION='2.2.6.4-gog28215'
ARCHIVE_BASE_UNMERGED_1_TYPE='mojosetup_unzip'

ARCHIVE_BASE_UNMERGED_0='stellaris_anniversary_portraits_2_2_4_26846.sh'
ARCHIVE_BASE_UNMERGED_0_MD5='ffa0a5baa7fb281290377113197d3456'
ARCHIVE_BASE_UNMERGED_0_SIZE='1300'
ARCHIVE_BASE_UNMERGED_0_VERSION='2.2.4-gog26846'
ARCHIVE_BASE_UNMERGED_0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc/dlc015_anniversary'
# Keep compatibility with old archives
ARCHIVE_GAME_MAIN_PATH_GOG_UNMERGED_1='data/noarch/game/dlc/dlc015_anniversary'
ARCHIVE_GAME_MAIN_PATH_GOG_UNMERGED_0='data/noarch/game/dlc/dlc015_anniversary'

# Keep compatibility with old archives
ARCHIVE_GAME_VOID_PATH_GOG_UNMERGED='data/noarch/game'
ARCHIVE_GAME_VOID_PATH_GOG_UNMERGED_1='data/noarch/game/dlc/dlc010_creatures_of_the_void'
ARCHIVE_GAME_VOID_PATH_GOG_UNMERGED_0='data/noarch/game/dlc/dlc010_creatures_of_the_void'
ARCHIVE_GAME_VOID_FILES_GOG_UNMERGED='dlc/dlc010_creatures_of_the_void'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-${EXPANSION_ID}"
PKG_MAIN_DESCRIPTION="$EXPANSION_NAME"
PKG_MAIN_DEPS="$GAME_ID"

# Ensure smooth upgrade from pre-20201031.1 packages
PKG_MAIN_PROVIDE='stellaris-anniversary-portraits'

# Keep compatibility with old archives
PACKAGES_LIST_GOG_UNMERGED='PKG_MAIN PKG_VOID'
PKG_VOID_ID="${GAME_ID}-${EXPANSION_VOID_ID}"
PKG_VOID_DESCRIPTION="$EXPANSION_VOID_NAME"
PKG_VOID_DEPS="$GAME_ID"

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

# Use correct packages list based on source archive

use_archive_specific_value 'PACKAGES_LIST'
# shellcheck disable=SC2086
set_temp_directories $PACKAGES_LIST

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Build package

for PKG in $PACKAGES_LIST; do
	use_package_specific_value 'GAME_NAME'
	write_metadata "$PKG"
done
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

for PKG in $PACKAGES_LIST; do
	case "$PKG" in
		('PKG_MAIN')
			GAME_NAME="$GAME_ID - $EXPANSION_ID"
		;;
		('PKG_VOID')
			GAME_NAME="$GAME_ID - $EXPANSION_VOID_ID"
		;;
	esac
	print_instructions "$PKG"
done

exit 0
