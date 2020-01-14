#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
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
# send your bug reports to vv221@dotslashplay.it
###

script_version=20191024.2

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris - Horizon Signal'

ARCHIVE_GOG='stellaris_horizon_signal_2_5_0_5_33395.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/stellaris_horizon_signal'
ARCHIVE_GOG_MD5='61746bd87a0cbd22d4d98281f585bfc2'
ARCHIVE_GOG_SIZE='1400'
ARCHIVE_GOG_VERSION='2.5.0.5-gog33395'
ARCHIVE_GOG_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD10='stellaris_horizon_signal_2_4_1_1_33112.sh'
ARCHIVE_GOG_OLD10_MD5='0a519147bfb6af4aa509fbd6def7eda6'
ARCHIVE_GOG_OLD10_SIZE='1400'
ARCHIVE_GOG_OLD10_VERSION='2.4.1.1-gog33112'
ARCHIVE_GOG_OLD10_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD9='stellaris_horizon_signal_2_4_1_33088.sh'
ARCHIVE_GOG_OLD9_MD5='23d9ceedee2b919596f12a59cf1f47d1'
ARCHIVE_GOG_OLD9_SIZE='1400'
ARCHIVE_GOG_OLD9_VERSION='2.4.1-gog33088'
ARCHIVE_GOG_OLD9_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD8='stellaris_horizon_signal_2_4_0_7_33057.sh'
ARCHIVE_GOG_OLD8_MD5='6fdb17badf8a0e39ab3f8c2597552c12'
ARCHIVE_GOG_OLD8_SIZE='1400'
ARCHIVE_GOG_OLD8_VERSION='2.4.0.7-gog33057'
ARCHIVE_GOG_OLD8_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD7='stellaris_horizon_signal_2_3_3_1_30901.sh'
ARCHIVE_GOG_OLD7_MD5='c7273e17a0f412ab17cf7e21a6e5fb16'
ARCHIVE_GOG_OLD7_SIZE='1300'
ARCHIVE_GOG_OLD7_VERSION='2.3.3.1-gog30901'
ARCHIVE_GOG_OLD7_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD6='stellaris_horizon_signal_2_3_3_30733.sh'
ARCHIVE_GOG_OLD6_MD5='cae26d668625d828f04132781767b36c'
ARCHIVE_GOG_OLD6_SIZE='1300'
ARCHIVE_GOG_OLD6_VERSION='2.3.3-gog30733'
ARCHIVE_GOG_OLD6_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD5='stellaris_horizon_signal_2_3_2_1_30253.sh'
ARCHIVE_GOG_OLD5_MD5='9d6f047648c46694df2141873019d014'
ARCHIVE_GOG_OLD5_SIZE='1300'
ARCHIVE_GOG_OLD5_VERSION='2.3.2.1-gog30253'
ARCHIVE_GOG_OLD5_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD4='stellaris_horizon_signal_2_3_1_2_30059.sh'
ARCHIVE_GOG_OLD4_MD5='a8e8356ad5fc69af7f78d7a4d1b314b1'
ARCHIVE_GOG_OLD4_SIZE='1300'
ARCHIVE_GOG_OLD4_VERSION='2.3.1.2-gog30059'
ARCHIVE_GOG_OLD4_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD3='stellaris_horizon_signal_2_3_0_4x_30009.sh'
ARCHIVE_GOG_OLD3_MD5='78fd1892b20677f60cf01def3c86a4ad'
ARCHIVE_GOG_OLD3_SIZE='1300'
ARCHIVE_GOG_OLD3_VERSION='2.3.0.4x-gog30009'
ARCHIVE_GOG_OLD3_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD2='stellaris_horizon_signal_2_2_7_2_28548.sh'
ARCHIVE_GOG_OLD2_MD5='a3227ae44bebe64a9182af71df1b3000'
ARCHIVE_GOG_OLD2_SIZE='1300'
ARCHIVE_GOG_OLD2_VERSION='2.2.7.2-gog28548'
ARCHIVE_GOG_OLD2_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD1='stellaris_horizon_signal_2_2_6_4_28215.sh'
ARCHIVE_GOG_OLD1_MD5='fd58ce9eca3f619dc3dbd969e0f92895'
ARCHIVE_GOG_OLD1_SIZE='1300'
ARCHIVE_GOG_OLD1_VERSION='2.2.6.4-gog28215'
ARCHIVE_GOG_OLD1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD0='stellaris_horizon_signal_2_2_4_26846.sh'
ARCHIVE_GOG_OLD0_MD5='484a8f3e514eb1593229fe3ba551c942'
ARCHIVE_GOG_OLD0_SIZE='1300'
ARCHIVE_GOG_OLD0_VERSION='2.2.4-gog26846'
ARCHIVE_GOG_OLD0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc/dlc013_horizon_signal'
# Keep compatibility with old archives
ARCHIVE_GAME_MAIN_PATH_GOG_OLD1='data/noarch/game/dlc/dlc013_horizon_signal'
ARCHIVE_GAME_MAIN_PATH_GOG_OLD0='data/noarch/game/dlc/dlc013_horizon_signal'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-horizon-signal"
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
