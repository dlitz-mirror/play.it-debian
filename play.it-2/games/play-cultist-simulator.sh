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
# Cultist Simulator
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201129.1

# Set game-specific variables

GAME_ID='cultist-simulator'
GAME_NAME='Cultist Simulator'

ARCHIVES_LIST='
ARCHIVE_GOG_7
ARCHIVE_GOG_6
ARCHIVE_GOG_5
ARCHIVE_GOG_4
ARCHIVE_GOG_3
ARCHIVE_GOG_2
ARCHIVE_GOG_1
ARCHIVE_GOG_0
ARCHIVE_GOG_MULTIARCH_21
ARCHIVE_GOG_MULTIARCH_20
ARCHIVE_GOG_MULTIARCH_19
ARCHIVE_GOG_MULTIARCH_18
ARCHIVE_GOG_MULTIARCH_17
ARCHIVE_GOG_MULTIARCH_16
ARCHIVE_GOG_MULTIARCH_15
ARCHIVE_GOG_MULTIARCH_14
ARCHIVE_GOG_MULTIARCH_13
ARCHIVE_GOG_MULTIARCH_12
ARCHIVE_GOG_MULTIARCH_11
ARCHIVE_GOG_MULTIARCH_10
ARCHIVE_GOG_MULTIARCH_9
ARCHIVE_GOG_MULTIARCH_8
ARCHIVE_GOG_MULTIARCH_7
ARCHIVE_GOG_MULTIARCH_6
ARCHIVE_GOG_MULTIARCH_5
ARCHIVE_GOG_MULTIARCH_4
ARCHIVE_GOG_MULTIARCH_3
ARCHIVE_GOG_MULTIARCH_2
ARCHIVE_GOG_MULTIARCH_1
ARCHIVE_GOG_MULTIARCH_0
'

ARCHIVE_GOG_7='cultist_simulator_2020_10_e_2_42258.sh'
ARCHIVE_GOG_7_URL='https://www.gog.com/game/cultist_simulator'
ARCHIVE_GOG_7_MD5='a2a2de8222b9993fc0ae5ef0eaed2b66'
ARCHIVE_GOG_7_SIZE='540000'
ARCHIVE_GOG_7_VERSION='2020.10.e.2-gog42258'
ARCHIVE_GOG_7_TYPE='mojosetup'

ARCHIVE_GOG_6='cultist_simulator_2020_10_e_1_42177.sh'
ARCHIVE_GOG_6_MD5='1a16264b6ce868c0f741b6614d84d684'
ARCHIVE_GOG_6_SIZE='540000'
ARCHIVE_GOG_6_VERSION='2020.10.e.1-gog42177'
ARCHIVE_GOG_6_TYPE='mojosetup'

ARCHIVE_GOG_5='cultist_simulator_2020_10_b_1_42011.sh'
ARCHIVE_GOG_5_MD5='672409328bd154b4430826c09b58dd74'
ARCHIVE_GOG_5_SIZE='530000'
ARCHIVE_GOG_5_VERSION='2020.10.b.1-gog42011'
ARCHIVE_GOG_5_TYPE='mojosetup'

ARCHIVE_GOG_4='cultist_simulator_2020_9_p_1_bis_41797.sh'
ARCHIVE_GOG_4_MD5='9683f0726cba2b116db4134aec863382'
ARCHIVE_GOG_4_SIZE='520000'
ARCHIVE_GOG_4_VERSION='2020.9.p.1-gog41797'
ARCHIVE_GOG_4_TYPE='mojosetup'

ARCHIVE_GOG_3='cultist_simulator_2020_9_n_5_41650.sh'
ARCHIVE_GOG_3_MD5='251b5e2d58faaea7132b57ad97495057'
ARCHIVE_GOG_3_SIZE='510000'
ARCHIVE_GOG_3_VERSION='2020.9.n.5-gog41650'
ARCHIVE_GOG_3_TYPE='mojosetup'

ARCHIVE_GOG_2='cultist_simulator_2020_6_b_1_38747.sh'
ARCHIVE_GOG_2_MD5='22980acaa3f825d0712621624277d4ed'
ARCHIVE_GOG_2_SIZE='500000'
ARCHIVE_GOG_2_VERSION='2020.6.b.1-gog38747'
ARCHIVE_GOG_2_TYPE='mojosetup'

ARCHIVE_GOG_1='cultist_simulator_2020_6_a_1_38655.sh'
ARCHIVE_GOG_1_MD5='099e8a6ed1ae7a9bd654ba63ab89c4a7'
ARCHIVE_GOG_1_SIZE='500000'
ARCHIVE_GOG_1_VERSION='2020.6.a.1-gog38655'
ARCHIVE_GOG_1_TYPE='mojosetup'

ARCHIVE_GOG_0='cultist_simulator_2020_3_b_1_37119.sh'
ARCHIVE_GOG_0_MD5='4390c258dcce415d61f96eac66a728ca'
ARCHIVE_GOG_0_SIZE='470000'
ARCHIVE_GOG_0_VERSION='2020.3.b.1-gog37119'
ARCHIVE_GOG_0_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_21='cultist_simulator_2019_11_a_1_34192.sh'
ARCHIVE_GOG_MULTIARCH_21_MD5='c743edbe8711476fd355a64c71d646eb'
ARCHIVE_GOG_MULTIARCH_21_SIZE='470000'
ARCHIVE_GOG_MULTIARCH_21_VERSION='2019.11.a.1-gog34192'
ARCHIVE_GOG_MULTIARCH_21_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_20='cultist_simulator_2019_10_a_1_32889.sh'
ARCHIVE_GOG_MULTIARCH_20_MD5='cf9af5975382b4f09090cc4b42443b53'
ARCHIVE_GOG_MULTIARCH_20_SIZE='470000'
ARCHIVE_GOG_MULTIARCH_20_VERSION='2019.10.a.1-gog32889'
ARCHIVE_GOG_MULTIARCH_20_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_19='cultist_simulator_2019_8_c_1_32055.sh'
ARCHIVE_GOG_MULTIARCH_19_MD5='6af35174e840a228b83f51fd1277982b'
ARCHIVE_GOG_MULTIARCH_19_SIZE='470000'
ARCHIVE_GOG_MULTIARCH_19_VERSION='2019.8.c.1-gog32055'
ARCHIVE_GOG_MULTIARCH_19_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_18='cultist_simulator_2019_8_a_1_31407.sh'
ARCHIVE_GOG_MULTIARCH_18_MD5='22dd9dc0257f65d4f02d5fb159a8b0ec'
ARCHIVE_GOG_MULTIARCH_18_SIZE='470000'
ARCHIVE_GOG_MULTIARCH_18_VERSION='2019.8.a.1-gog31407'
ARCHIVE_GOG_MULTIARCH_18_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_17='cultist_simulator_2019_7_a_2_30707.sh'
ARCHIVE_GOG_MULTIARCH_17_MD5='06e148a85a4b2aa12061c304c4186a75'
ARCHIVE_GOG_MULTIARCH_17_SIZE='470000'
ARCHIVE_GOG_MULTIARCH_17_VERSION='2019.7.a.2-gog30707'
ARCHIVE_GOG_MULTIARCH_17_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_16='cultist_simulator_2019_7_a_1_30684.sh'
ARCHIVE_GOG_MULTIARCH_16_MD5='813105778fdd1564c96ea6a9b503704c'
ARCHIVE_GOG_MULTIARCH_16_SIZE='470000'
ARCHIVE_GOG_MULTIARCH_16_VERSION='2019.7.a.1-gog30684'
ARCHIVE_GOG_MULTIARCH_16_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_15='cultist_simulator_2019_6_a_1_30011.sh'
ARCHIVE_GOG_MULTIARCH_15_MD5='8c620ffaf00824efa1d4d83ea3c19875'
ARCHIVE_GOG_MULTIARCH_15_SIZE='470000'
ARCHIVE_GOG_MULTIARCH_15_VERSION='2019.6.a.1-gog30011'
ARCHIVE_GOG_MULTIARCH_15_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_14='cultist_simulator_2019_5_g_1_29892.sh'
ARCHIVE_GOG_MULTIARCH_14_MD5='cfc19d5d71038fd1fd6aecc1063c937b'
ARCHIVE_GOG_MULTIARCH_14_SIZE='470000'
ARCHIVE_GOG_MULTIARCH_14_VERSION='2019.5.g.1-gog29892'
ARCHIVE_GOG_MULTIARCH_14_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_13='cultist_simulator_2019_5_d_2_29725.sh'
ARCHIVE_GOG_MULTIARCH_13_MD5='4b525f0a328ef20152f780aa27666229'
ARCHIVE_GOG_MULTIARCH_13_SIZE='460000'
ARCHIVE_GOG_MULTIARCH_13_VERSION='2019.5.d.2-gog29725'
ARCHIVE_GOG_MULTIARCH_13_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_12='cultist_simulator_2019_5_a_3_29482.sh'
ARCHIVE_GOG_MULTIARCH_12_MD5='7dae35420e935e922d0028e151a40b45'
ARCHIVE_GOG_MULTIARCH_12_SIZE='450000'
ARCHIVE_GOG_MULTIARCH_12_VERSION='2019.5.a.3-gog29482'
ARCHIVE_GOG_MULTIARCH_12_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_11='cultist_simulator_2019_2_b_1_27664.sh'
ARCHIVE_GOG_MULTIARCH_11_MD5='acab3e94356ac2b7f22919c858e136b7'
ARCHIVE_GOG_MULTIARCH_11_SIZE='430000'
ARCHIVE_GOG_MULTIARCH_11_VERSION='2019.2.b.1-gog27664'
ARCHIVE_GOG_MULTIARCH_11_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_10='cultist_simulator_2019_1_k_1_26890.sh'
ARCHIVE_GOG_MULTIARCH_10_MD5='4902a7b52f6c28e4a069becd829092df'
ARCHIVE_GOG_MULTIARCH_10_SIZE='440000'
ARCHIVE_GOG_MULTIARCH_10_VERSION='2019.1.k.1-gog26890'
ARCHIVE_GOG_MULTIARCH_10_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_9='cultist_simulator_2019_1_i_4_26849.sh'
ARCHIVE_GOG_MULTIARCH_9_MD5='a9dd0bc41b522acf67e279bf32a46264'
ARCHIVE_GOG_MULTIARCH_9_SIZE='440000'
ARCHIVE_GOG_MULTIARCH_9_VERSION='2019.1.i.4-gog26849'
ARCHIVE_GOG_MULTIARCH_9_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_8='cultist_simulator_2019_1_i_1_26823.sh'
ARCHIVE_GOG_MULTIARCH_8_MD5='9f8e8e58150acec6a31b2ac9ca620a99'
ARCHIVE_GOG_MULTIARCH_8_SIZE='440000'
ARCHIVE_GOG_MULTIARCH_8_VERSION='2019.1.i.1-gog26823'
ARCHIVE_GOG_MULTIARCH_8_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_7='cultist_simulator_2018_12_b_1_25838.sh'
ARCHIVE_GOG_MULTIARCH_7_MD5='24d89e01593a6860e841242818c5e0a4'
ARCHIVE_GOG_MULTIARCH_7_SIZE='430000'
ARCHIVE_GOG_MULTIARCH_7_VERSION='2018.12.b.1-gog25838'
ARCHIVE_GOG_MULTIARCH_7_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_6='cultist_simulator_2018_10_i_5_24471.sh'
ARCHIVE_GOG_MULTIARCH_6_MD5='d6f4c068f71dcc7bde8157c0ffd265da'
ARCHIVE_GOG_MULTIARCH_6_SIZE='300000'
ARCHIVE_GOG_MULTIARCH_6_VERSION='2018.10.i.5-gog24471'
ARCHIVE_GOG_MULTIARCH_6_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_5='cultist_simulator_en_2018_8_a_2_22766.sh'
ARCHIVE_GOG_MULTIARCH_5_MD5='bb46774fc98174e3b36257ee9b344543'
ARCHIVE_GOG_MULTIARCH_5_SIZE='330000'
ARCHIVE_GOG_MULTIARCH_5_VERSION='2018.8.a.2-gog22766'
ARCHIVE_GOG_MULTIARCH_5_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_4='cultist_simulator_en_2018_7_b_1_22190.sh'
ARCHIVE_GOG_MULTIARCH_4_MD5='05b6fe0fc497fa84ffd3a54089252840'
ARCHIVE_GOG_MULTIARCH_4_SIZE='330000'
ARCHIVE_GOG_MULTIARCH_4_VERSION='2018.7.b.1-gog22190'
ARCHIVE_GOG_MULTIARCH_4_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_3='cultist_simulator_en_v2018_6_k_2_21613.sh'
ARCHIVE_GOG_MULTIARCH_3_MD5='4956d00d5ac6d7caa01b5323797d3a1b'
ARCHIVE_GOG_MULTIARCH_3_SIZE='320000'
ARCHIVE_GOG_MULTIARCH_3_VERSION='2018.6.k.2-gog21613'
ARCHIVE_GOG_MULTIARCH_3_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_2='cultist_simulator_en_v2018_6_f_1_21446.sh'
ARCHIVE_GOG_MULTIARCH_2_MD5='b98da20e3ae0a8892988ad8c09383d40'
ARCHIVE_GOG_MULTIARCH_2_SIZE='320000'
ARCHIVE_GOG_MULTIARCH_2_VERSION='2018.6.f.1-gog21446'
ARCHIVE_GOG_MULTIARCH_2_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_1='cultist_simulator_en_v2018_6_c_7_21347.sh'
ARCHIVE_GOG_MULTIARCH_1_MD5='beff3d27b3cce3f1448cd9cd46d488bc'
ARCHIVE_GOG_MULTIARCH_1_SIZE='310000'
ARCHIVE_GOG_MULTIARCH_1_VERSION='2018.6.c.7-gog21347'
ARCHIVE_GOG_MULTIARCH_1_TYPE='mojosetup'

ARCHIVE_GOG_MULTIARCH_0='cultist_simulator_en_v2018_5_x_6_21178.sh'
ARCHIVE_GOG_MULTIARCH_0_MD5='7885e6e571940ddc0f8c6101c2af77a5'
ARCHIVE_GOG_MULTIARCH_0_SIZE='310000'
ARCHIVE_GOG_MULTIARCH_0_VERSION='2018.5.x.6-gog21178'
ARCHIVE_GOG_MULTIARCH_0_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data/noarch/game'
ARCHIVE_DOC_DATA_FILES='README'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='CS.x86_64 UnityPlayer.so CS_Data/MonoBleedingEdge CS_Data/Plugins'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='CS_Data version.txt'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# Work around Unity3D poor support for non-US locales
export LANG=C'
APP_MAIN_EXE='CS.x86_64'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='CS_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx"

# Keep compatibility with old multiarch builds

PACKAGES_LIST_GOG_MULTIARCH='PKG_BIN32 PKG_BIN64 PKG_DATA'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='CS.x86 libsteam_api.so CS_Data/Mono/x86 CS_Data/MonoBleedingEdge/x86 CS_Data/Plugins/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='CS.x86_64 libsteam_api64.so CS_Data/Mono/x86_64 CS_Data/MonoBleedingEdge/x86_64 CS_Data/Plugins/x86_64'

APP_MAIN_EXE_BIN32='CS.x86'
APP_MAIN_EXE_BIN64='CS.x86_64'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ gtk2 glx libgdk_pixbuf-2.0.so.0 libglib-2.0.so.0"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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

# Set list of packages to build based on provided archive

use_archive_specific_value 'PACKAGES_LIST'
set_temp_directories $PACKAGES_LIST

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

case "$ARCHIVE" in
	('ARCHIVE_GOG_MULTIARCH'*)
		for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
			launchers_write 'APP_MAIN'
		done
	;;
	(*)
		PKG='PKG_BIN'
		launchers_write 'APP_MAIN'
	;;
esac

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
