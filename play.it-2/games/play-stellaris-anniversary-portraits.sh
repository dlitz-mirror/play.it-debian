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
# Stellaris - Anniversary Portraits + Creatures of the Void Portrait Pack
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200515.2

# Set game-specific variables

GAME_ID='stellaris'
GAME_ID_ANNIVERSARY="${GAME_ID}-anniversary-portraits"
GAME_ID_VOID="${GAME_ID}-creatures-of-the-void-portrait-pack"
GAME_NAME='Stellaris'
GAME_NAME_ANNIVERSARY="$GAME_NAME - Anniversary Portraits"
GAME_NAME_VOID="$GAME_NAME - Creatures of the Void Portrait Pack"

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
ARCHIVE_GOG_0
ARCHIVE_GOG_UNMERGED_2
ARCHIVE_GOG_UNMERGED_1
ARCHIVE_GOG_UNMERGED_0'

ARCHIVE_GOG_14='stellaris_anniversary_portraits_2_7_1_38218.sh'
ARCHIVE_GOG_14_URL='https://www.gog.com/game/stellaris_anniversary_portraits'
ARCHIVE_GOG_14_MD5='cbbf4772108cd00710c7a4bcac22a1f2'
ARCHIVE_GOG_14_SIZE='1400'
ARCHIVE_GOG_14_VERSION='2.7.1-gog38218'
ARCHIVE_GOG_14_TYPE='mojosetup_unzip'

ARCHIVE_GOG_13='stellaris_anniversary_portraits_2_6_3_2_37617.sh'
ARCHIVE_GOG_13_MD5='a757a0b1c5470ed2ed9cb06cd00458e5'
ARCHIVE_GOG_13_SIZE='1400'
ARCHIVE_GOG_13_VERSION='2.6.3.2-gog37617'
ARCHIVE_GOG_13_TYPE='mojosetup_unzip'

ARCHIVE_GOG_12='stellaris_anniversary_portraits_2_6_2_37285.sh'
ARCHIVE_GOG_12_MD5='09d681173e2785c8e590c687d3f5a240'
ARCHIVE_GOG_12_SIZE='1400'
ARCHIVE_GOG_12_VERSION='2.6.2-gog37285'
ARCHIVE_GOG_12_TYPE='mojosetup_unzip'

ARCHIVE_GOG_11='stellaris_anniversary_portraits_2_6_1_1_36932.sh'
ARCHIVE_GOG_11_MD5='d7a4485713673794030a65924fa45d79'
ARCHIVE_GOG_11_SIZE='1400'
ARCHIVE_GOG_11_VERSION='2.6.1.1-gog36932'
ARCHIVE_GOG_11_TYPE='mojosetup_unzip'

ARCHIVE_GOG_10='stellaris_anniversary_portraits_2_6_0_4_36778.sh'
ARCHIVE_GOG_10_MD5='98758b31ee405cd615d2036b79d7cc0f'
ARCHIVE_GOG_10_SIZE='1400'
ARCHIVE_GOG_10_VERSION='2.6.0.4-gog36778'
ARCHIVE_GOG_10_TYPE='mojosetup_unzip'

ARCHIVE_GOG_9='stellaris_anniversary_portraits_2_5_1_33517.sh'
ARCHIVE_GOG_9_MD5='3231b08ff883239e98bea2a9adb841e2'
ARCHIVE_GOG_9_SIZE='1400'
ARCHIVE_GOG_9_VERSION='2.5.1-gog33517'
ARCHIVE_GOG_9_TYPE='mojosetup_unzip'

ARCHIVE_GOG_8='stellaris_anniversary_portraits_2_5_0_5_33395.sh'
ARCHIVE_GOG_8_MD5='813ca5d320ba55c5300b9cb10454a4e5'
ARCHIVE_GOG_8_SIZE='1400'
ARCHIVE_GOG_8_VERSION='2.5.0.5-gog33395'
ARCHIVE_GOG_8_TYPE='mojosetup_unzip'

ARCHIVE_GOG_7='stellaris_anniversary_portraits_2_4_1_1_33112.sh'
ARCHIVE_GOG_7_MD5='d91b95860510e7ce2fad6a8a5b562172'
ARCHIVE_GOG_7_SIZE='1400'
ARCHIVE_GOG_7_VERSION='2.4.1.1-gog33112'
ARCHIVE_GOG_7_TYPE='mojosetup_unzip'

ARCHIVE_GOG_6='stellaris_anniversary_portraits_2_4_1_33088.sh'
ARCHIVE_GOG_6_MD5='dda16c2268882cbe3c779728f36c7929'
ARCHIVE_GOG_6_SIZE='1400'
ARCHIVE_GOG_6_VERSION='2.4.1-gog33088'
ARCHIVE_GOG_6_TYPE='mojosetup_unzip'

ARCHIVE_GOG_5='stellaris_anniversary_portraits_2_4_0_7_33057.sh'
ARCHIVE_GOG_5_MD5='72ff42a55738d005681f8ca06a9562e9'
ARCHIVE_GOG_5_SIZE='1400'
ARCHIVE_GOG_5_VERSION='2.4.0.7-gog33057'
ARCHIVE_GOG_5_TYPE='mojosetup_unzip'

ARCHIVE_GOG_4='stellaris_anniversary_portraits_2_3_3_1_30901.sh'
ARCHIVE_GOG_4_MD5='24b4bfe3a5f2e70858cf14d0af2e268a'
ARCHIVE_GOG_4_SIZE='1300'
ARCHIVE_GOG_4_VERSION='2.3.3.1-gog30901'
ARCHIVE_GOG_4_TYPE='mojosetup_unzip'

ARCHIVE_GOG_3='stellaris_anniversary_portraits_2_3_3_30733.sh'
ARCHIVE_GOG_3_MD5='93baefe99fd0c9fde17a90bbc11fb6a9'
ARCHIVE_GOG_3_SIZE='1300'
ARCHIVE_GOG_3_VERSION='2.3.3-gog30733'
ARCHIVE_GOG_3_TYPE='mojosetup_unzip'

ARCHIVE_GOG_2='stellaris_anniversary_portraits_2_3_2_1_30253.sh'
ARCHIVE_GOG_2_MD5='fcde86358e3ccd6972b04477bfbd918f'
ARCHIVE_GOG_2_SIZE='1300'
ARCHIVE_GOG_2_VERSION='2.3.2.1-gog30253'
ARCHIVE_GOG_2_TYPE='mojosetup_unzip'

ARCHIVE_GOG_1='stellaris_anniversary_portraits_2_3_1_2_30059.sh'
ARCHIVE_GOG_1_MD5='d0d558eb89f91cde08f166d9d91aa932'
ARCHIVE_GOG_1_SIZE='1300'
ARCHIVE_GOG_1_VERSION='2.3.1.2-gog30059'
ARCHIVE_GOG_1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_0='stellaris_anniversary_portraits_2_3_0_4x_30009.sh'
ARCHIVE_GOG_0_MD5='6eb4b3d12c658b956a54e7946c856563'
ARCHIVE_GOG_0_SIZE='1300'
ARCHIVE_GOG_0_VERSION='2.3.0.4x-gog30009'
ARCHIVE_GOG_0_TYPE='mojosetup_unzip'

ARCHIVE_GOG_UNMERGED_2='stellaris_anniversary_portraits_2_2_7_2_28548.sh'
ARCHIVE_GOG_UNMERGED_2_MD5='2246af9530b1a2a8d6a7c3afabe54eec'
ARCHIVE_GOG_UNMERGED_2_SIZE='1300'
ARCHIVE_GOG_UNMERGED_2_VERSION='2.2.7.2-gog28548'
ARCHIVE_GOG_UNMERGED_2_TYPE='mojosetup_unzip'

ARCHIVE_GOG_UNMERGED_1='stellaris_anniversary_portraits_2_2_6_4_28215.sh'
ARCHIVE_GOG_UNMERGED_1_MD5='ab450823054b77bd63a4906a343d10ac'
ARCHIVE_GOG_UNMERGED_1_SIZE='1300'
ARCHIVE_GOG_UNMERGED_1_VERSION='2.2.6.4-gog28215'
ARCHIVE_GOG_UNMERGED_1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_UNMERGED_0='stellaris_anniversary_portraits_2_2_4_26846.sh'
ARCHIVE_GOG_UNMERGED_0_MD5='ffa0a5baa7fb281290377113197d3456'
ARCHIVE_GOG_UNMERGED_0_SIZE='1300'
ARCHIVE_GOG_UNMERGED_0_VERSION='2.2.4-gog26846'
ARCHIVE_GOG_UNMERGED_0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_ANNIVERSARY_PATH='data/noarch/game'
ARCHIVE_GAME_ANNIVERSARY_FILES='dlc/dlc015_anniversary'
# Keep compatibility with old archives
ARCHIVE_GAME_ANNIVERSARY_PATH_GOG_UNMERGED_1='data/noarch/game/dlc/dlc015_anniversary'
ARCHIVE_GAME_ANNIVERSARY_PATH_GOG_UNMERGED_0='data/noarch/game/dlc/dlc015_anniversary'

# Keep compatibility with old archives
ARCHIVE_GAME_VOID_PATH_GOG_UNMERGED='data/noarch/game'
ARCHIVE_GAME_VOID_PATH_GOG_UNMERGED_1='data/noarch/game/dlc/dlc010_creatures_of_the_void'
ARCHIVE_GAME_VOID_PATH_GOG_UNMERGED_0='data/noarch/game/dlc/dlc010_creatures_of_the_void'
ARCHIVE_GAME_VOID_FILES_GOG_UNMERGED='dlc/dlc010_creatures_of_the_void'

PACKAGES_LIST='PKG_ANNIVERSARY'
# Keep compatibility with old archives
PACKAGES_LIST_GOG_UNMERGED='PKG_ANNIVERSARY PKG_VOID'

PKG_ANNIVERSARY_ID="$GAME_ID_ANNIVERSARY"
PKG_ANNIVERSARY_DEPS="$GAME_ID"
# Keep compatibility with old archives
PKG_ANNIVERSARY_PROVIDE="$GAME_ID_VOID"
PKG_ANNIVERSARY_PROVIDE_GOG_UNMERGED="$GAME_ID_ANNIVERSARY"

# Keep compatibility with old archives
PKG_VOID_ID="$GAME_ID_VOID"
PKG_VOID_DEPS="$GAME_ID"

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

# Use correct packages list based on source archive

use_archive_specific_value 'PACKAGES_LIST'
use_archive_specific_value 'PKG_ANNIVERSARY_PROVIDE'
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
	use_package_specific_value 'GAME_NAME'
	print_instructions "$PKG"
done

exit 0
