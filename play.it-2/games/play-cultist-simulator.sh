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
# Cultist Simulator
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200618.1

# Set game-specific variables

GAME_ID='cultist-simulator'
GAME_NAME='Cultist Simulator'

ARCHIVES_LIST='
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
'

ARCHIVE_GOG_10='cultist_simulator_2019_2_b_1_27664.sh'
ARCHIVE_GOG_10_URL='https://www.gog.com/game/cultist_simulator'
ARCHIVE_GOG_10_MD5='acab3e94356ac2b7f22919c858e136b7'
ARCHIVE_GOG_10_SIZE='430000'
ARCHIVE_GOG_10_VERSION='2019.2.b.1-gog27664'
ARCHIVE_GOG_10_TYPE='mojosetup'

ARCHIVE_GOG_9='cultist_simulator_2019_1_k_1_26890.sh'
ARCHIVE_GOG_9_MD5='4902a7b52f6c28e4a069becd829092df'
ARCHIVE_GOG_9_SIZE='440000'
ARCHIVE_GOG_9_VERSION='2019.1.k.1-gog26890'
ARCHIVE_GOG_9_TYPE='mojosetup'

ARCHIVE_GOG_8='cultist_simulator_2019_1_i_4_26849.sh'
ARCHIVE_GOG_8_MD5='a9dd0bc41b522acf67e279bf32a46264'
ARCHIVE_GOG_8_SIZE='440000'
ARCHIVE_GOG_8_VERSION='2019.1.i.4-gog26849'
ARCHIVE_GOG_8_TYPE='mojosetup'

ARCHIVE_GOG_7='cultist_simulator_2019_1_i_1_26823.sh'
ARCHIVE_GOG_7_MD5='9f8e8e58150acec6a31b2ac9ca620a99'
ARCHIVE_GOG_7_SIZE='440000'
ARCHIVE_GOG_7_VERSION='2019.1.i.1-gog26823'
ARCHIVE_GOG_7_TYPE='mojosetup'

ARCHIVE_GOG_6='cultist_simulator_2018_12_b_1_25838.sh'
ARCHIVE_GOG_6_MD5='24d89e01593a6860e841242818c5e0a4'
ARCHIVE_GOG_6_SIZE='430000'
ARCHIVE_GOG_6_VERSION='2018.12.b.1-gog25838'
ARCHIVE_GOG_6_TYPE='mojosetup'

ARCHIVE_GOG_5='cultist_simulator_2018_10_i_5_24471.sh'
ARCHIVE_GOG_5_MD5='d6f4c068f71dcc7bde8157c0ffd265da'
ARCHIVE_GOG_5_SIZE='300000'
ARCHIVE_GOG_5_VERSION='2018.10.i.5-gog24471'
ARCHIVE_GOG_5_TYPE='mojosetup'

ARCHIVE_GOG_4='cultist_simulator_en_2018_8_a_2_22766.sh'
ARCHIVE_GOG_4_MD5='bb46774fc98174e3b36257ee9b344543'
ARCHIVE_GOG_4_SIZE='330000'
ARCHIVE_GOG_4_VERSION='2018.8.a.2-gog22766'
ARCHIVE_GOG_4_TYPE='mojosetup'

ARCHIVE_GOG_3='cultist_simulator_en_2018_7_b_1_22190.sh'
ARCHIVE_GOG_3_MD5='05b6fe0fc497fa84ffd3a54089252840'
ARCHIVE_GOG_3_SIZE='330000'
ARCHIVE_GOG_3_VERSION='2018.7.b.1-gog22190'
ARCHIVE_GOG_3_TYPE='mojosetup'

ARCHIVE_GOG_2='cultist_simulator_en_v2018_6_k_2_21613.sh'
ARCHIVE_GOG_2_MD5='4956d00d5ac6d7caa01b5323797d3a1b'
ARCHIVE_GOG_2_SIZE='320000'
ARCHIVE_GOG_2_VERSION='2018.6.k.2-gog21613'
ARCHIVE_GOG_2_TYPE='mojosetup'

ARCHIVE_GOG_1='cultist_simulator_en_v2018_6_f_1_21446.sh'
ARCHIVE_GOG_1_MD5='b98da20e3ae0a8892988ad8c09383d40'
ARCHIVE_GOG_1_SIZE='320000'
ARCHIVE_GOG_1_VERSION='2018.6.f.1-gog21446'
ARCHIVE_GOG_1_TYPE='mojosetup'

ARCHIVE_GOG_0='cultist_simulator_en_v2018_6_c_7_21347.sh'
ARCHIVE_GOG_0_MD5='beff3d27b3cce3f1448cd9cd46d488bc'
ARCHIVE_GOG_0_SIZE='310000'
ARCHIVE_GOG_0_VERSION='2018.6.c.7-gog21347'
ARCHIVE_GOG_0_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='cultist_simulator_en_v2018_5_x_6_21178.sh'
ARCHIVE_GOG_OLD0_MD5='7885e6e571940ddc0f8c6101c2af77a5'
ARCHIVE_GOG_OLD0_SIZE='310000'
ARCHIVE_GOG_OLD0_VERSION='2018.5.x.6-gog21178'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game'
ARCHIVE_DOC1_DATA_FILES='README'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='CS.x86 libsteam_api.so CS_Data/Mono/x86 CS_Data/Plugins/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='CS.x86_64 libsteam_api64.so CS_Data/Mono/x86_64 CS_Data/Plugins/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='CS_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# Work around Unity3D poor support for non-US locales
export LANG=C'
APP_MAIN_EXE_BIN32='CS.x86'
APP_MAIN_EXE_BIN64='CS.x86_64'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='CS_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ gtk2 glx"
PKG_BIN32_DEPS_ARCH='lib32-gdk-pixbuf2 lib32-glib2'
PKG_BIN32_DEPS_DEB='libgdk-pixbuf2.0-0, libglib2.0-0'
PKG_BIN32_DEPS_GENTOO='x11-libs/gdk-pixbuf[abi_x86_32] dev-libs/glib[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='gdk-pixbuf2 glib2'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/gdk-pixbuf dev-libs/glib'

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

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
