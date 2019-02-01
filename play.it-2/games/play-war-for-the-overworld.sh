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
# War for the Overworld
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181121.1

# Set game-specific variables

GAME_ID='war-for-the-overworld'
GAME_NAME='War for the Overworld'

ARCHIVE_GOG='war_for_the_overworld_2_0_6f1_24637.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/war_for_the_overworld'
ARCHIVE_GOG_MD5='e58f2720ed974185e9e5b29d08aa6238'
ARCHIVE_GOG_SIZE='4700000'
ARCHIVE_GOG_VERSION='2.0.6f1-gog24637'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD6='war_for_the_overworld_2_0_5_24177.sh'
ARCHIVE_GOG_OLD6_MD5='79b604f0d19caf3af5fdc4cb3903b370'
ARCHIVE_GOG_OLD6_SIZE='4700000'
ARCHIVE_GOG_OLD6_VERSION='2.0.5-gog24177'
ARCHIVE_GOG_OLD6_TYPE='mojosetup'

ARCHIVE_GOG_OLD5='war_for_the_overworld_en_2_0_4_23102.sh'
ARCHIVE_GOG_OLD5_MD5='2873095f86b17c613b84af9624986f42'
ARCHIVE_GOG_OLD5_SIZE='4700000'
ARCHIVE_GOG_OLD5_VERSION='2.0.4-gog23102'
ARCHIVE_GOG_OLD5_TYPE='mojosetup'

ARCHIVE_GOG_OLD4='war_for_the_overworld_en_2_0_3f1_22287.sh'
ARCHIVE_GOG_OLD4_MD5='4f1ff4e136aeaa795fce8ba26445cbe8'
ARCHIVE_GOG_OLD4_SIZE='4700000'
ARCHIVE_GOG_OLD4_VERSION='2.0.3f1-gog22287'
ARCHIVE_GOG_OLD4_TYPE='mojosetup'

ARCHIVE_GOG_OLD3='war_for_the_overworld_en_2_0_1_21758.sh'
ARCHIVE_GOG_OLD3_MD5='41c4746b17874ca4c42712ffe2b20381'
ARCHIVE_GOG_OLD3_SIZE='4600000'
ARCHIVE_GOG_OLD3_VERSION='2.0.1-gog20414'
ARCHIVE_GOG_OLD3_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='war_for_the_overworld_en_2_0f4_20414.sh'
ARCHIVE_GOG_OLD2_MD5='9110eadd613d39f95e08e182f08546cf'
ARCHIVE_GOG_OLD2_SIZE='4500000'
ARCHIVE_GOG_OLD2_VERSION='2.0f4-gog20414'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='war_for_the_overworld_en_2_0f1_20175.sh'
ARCHIVE_GOG_OLD1_MD5='51bcd2bd37c4914f5074a622767859d4'
ARCHIVE_GOG_OLD1_SIZE='4500000'
ARCHIVE_GOG_OLD1_VERSION='2.0f1-gog20175'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='war_for_the_overworld_en_1_6_66_16455.sh'
ARCHIVE_GOG_OLD0_MD5='3317bba3d2ec7dc5715f0d44e6cb70c1'
ARCHIVE_GOG_OLD0_SIZE='2800000'
ARCHIVE_GOG_OLD0_VERSION='1.6.66-gog16455'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_HUMBLE='War_for_the_Overworld_v1.5.2_-_Linux_x64.zip'
ARCHIVE_HUMBLE_MD5='bedee8b966767cf42c55c6b883e3127c'
ARCHIVE_HUMBLE_SIZE='2500000'
ARCHIVE_HUMBLE_VERSION='1.5.2-humble170202'

ARCHIVE_DOC_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='Linux'
ARCHIVE_GAME_BIN_FILES='*.x86_64 *_Data/Plugins *_Data/Mono *_Data/CoherentUI_Host'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='Linux'
ARCHIVE_GAME_DATA_FILES='*_Data *.info'

DATA_DIRS='./*_Data/GameData ./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_GOG='WFTOGame.x86_64'
APP_MAIN_EXE_HUMBLE='WFTO.x86_64'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON_GOG='WFTOGame_Data/Resources/UnityPlayer.png'
APP_MAIN_ICON_HUMBLE='WFTO_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx xcursor gtk2"
# Keep compatibility with old archives
PKG_BIN_DEPS_HUMBLE="$PKG_DATA_ID glibc libstdc++ glx xcursor gtk2 gconf"
PKG_BIN_DEPS_GOG_OLD0="$PKG_BIN_DEPS_HUMBLE"
PKG_BIN_DEPS_GOG_OLD1="$PKG_BIN_DEPS_HUMBLE"
PKG_BIN_DEPS_GOG_OLD2="$PKG_BIN_DEPS_HUMBLE"
PKG_BIN_DEPS_GOG_OLD3="$PKG_BIN_DEPS_HUMBLE"

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

# Tweaks for old versions

for file in\
	"${PKG_BIN_PATH}${PATH_GAME}"/*_Data/CoherentUI_Host/linux/CoherentUI_Host\
	"${PKG_BIN_PATH}${PATH_GAME}"/*_Data/CoherentUI_Host/linux/CoherentUI_Host.bin
do
	if [ -e "$file" ]; then
		chmod +x "$file"
	fi
done

file="${PKG_DATA_PATH}${PATH_GAME}"/*_Data/uiresources/maps/Stonegate.unity.png
if [ -e "$file" ]; then
	(
		cd "${file%/*}"
		mv "${file##*/}" 'stonegate.unity.png'
	)
fi

# Write launchers

PKG='PKG_BIN'
use_archive_specific_value 'APP_MAIN_EXE'
use_archive_specific_value 'APP_MAIN_ICON'
write_launcher 'APP_MAIN'

# Build packages

use_archive_specific_value 'PKG_BIN_DEPS'
PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
