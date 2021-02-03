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
# Warhammer 40,000: Gladius - Relics of War
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210226.2

# Set game-specific variables

GAME_ID='warhammer-40k-gladius-relics-of-war'
GAME_NAME='Warhammer 40,000: Gladius - Relics of War'

ARCHIVES_LIST='
ARCHIVE_GOG_28
ARCHIVE_GOG_27
ARCHIVE_GOG_26
ARCHIVE_GOG_25
ARCHIVE_GOG_24
ARCHIVE_GOG_23
ARCHIVE_GOG_22
ARCHIVE_GOG_21
ARCHIVE_GOG_20
ARCHIVE_GOG_19
ARCHIVE_GOG_18
ARCHIVE_GOG_17
ARCHIVE_GOG_16
ARCHIVE_GOG_15
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

ARCHIVE_GOG_28='warhammer_40_000_gladius_relics_of_war_1_07_04_44200.sh'
ARCHIVE_GOG_28_MD5='b8534d0956159736ee49f207da516ba6'
ARCHIVE_GOG_28_TYPE='mojosetup'
ARCHIVE_GOG_28_SIZE='2600000'
ARCHIVE_GOG_28_VERSION='1.7.4-gog44200'
ARCHIVE_GOG_28_URL='https://www.gog.com/game/warhammer_40000_gladius_relics_of_war'

ARCHIVE_GOG_27='warhammer_40_000_gladius_relics_of_war_1_07_03_43452.sh'
ARCHIVE_GOG_27_MD5='8350b6521fb0b66b31892d67f849cbcd'
ARCHIVE_GOG_27_TYPE='mojosetup'
ARCHIVE_GOG_27_SIZE='2600000'
ARCHIVE_GOG_27_VERSION='1.7.3-gog43452'

ARCHIVE_GOG_26='warhammer_40_000_gladius_relics_of_war_1_07_01_42686.sh'
ARCHIVE_GOG_26_MD5='e6c3cedfa4c9e5b51daa2e9b6b89c86b'
ARCHIVE_GOG_26_TYPE='mojosetup'
ARCHIVE_GOG_26_SIZE='2600000'
ARCHIVE_GOG_26_VERSION='1.7.1-gog42686'

ARCHIVE_GOG_25='warhammer_40_000_gladius_relics_of_war_1_07_00_42663.sh'
ARCHIVE_GOG_25_MD5='7b79c17dc30f78fafdc19759aa97f012'
ARCHIVE_GOG_25_TYPE='mojosetup'
ARCHIVE_GOG_25_SIZE='2600000'
ARCHIVE_GOG_25_VERSION='1.7.0-gog42663'

ARCHIVE_GOG_24='warhammer_40_000_gladius_relics_of_war_1_06_4b_41966.sh'
ARCHIVE_GOG_24_MD5='dbdcdd7450f009ffd2c5feae2fbc9fd2'
ARCHIVE_GOG_24_TYPE='mojosetup'
ARCHIVE_GOG_24_SIZE='2300000'
ARCHIVE_GOG_24_VERSION='1.6.4b-gog41966'

ARCHIVE_GOG_23='warhammer_40_000_gladius_relics_of_war_1_06_4a_40621.sh'
ARCHIVE_GOG_23_MD5='59a4a1ba453420a970edb886a0f179f0'
ARCHIVE_GOG_23_TYPE='mojosetup'
ARCHIVE_GOG_23_SIZE='2300000'
ARCHIVE_GOG_23_VERSION='1.6.4a-gog40621'

ARCHIVE_GOG_22='warhammer_40_000_gladius_relics_of_war_1_06_03_01_39396.sh'
ARCHIVE_GOG_22_MD5='a307b99b6d5b55ec19cd9d6747a5929b'
ARCHIVE_GOG_22_TYPE='mojosetup'
ARCHIVE_GOG_22_SIZE='2300000'
ARCHIVE_GOG_22_VERSION='1.6.3.1-gog39396'

ARCHIVE_GOG_21='warhammer_40_000_gladius_relics_of_war_1_06_02_38991.sh'
ARCHIVE_GOG_21_MD5='6d4455466f5f14bcfa49fb8730982837'
ARCHIVE_GOG_21_TYPE='mojosetup'
ARCHIVE_GOG_21_SIZE='2300000'
ARCHIVE_GOG_21_VERSION='1.6.2-gog38991'

ARCHIVE_GOG_20='warhammer_40_000_gladius_relics_of_war_1_05_01_36614.sh'
ARCHIVE_GOG_20_MD5='faf0d5df1a800d8102bdf20309aa9b6c'
ARCHIVE_GOG_20_TYPE='mojosetup'
ARCHIVE_GOG_20_SIZE='2200000'
ARCHIVE_GOG_20_VERSION='1.5.1-gog36614'

ARCHIVE_GOG_19='warhammer_40_000_gladius_relics_of_war_1_05_00_36394.sh'
ARCHIVE_GOG_19_MD5='84cb0b1a6f64fe2e239c4cd94fa34f92'
ARCHIVE_GOG_19_TYPE='mojosetup'
ARCHIVE_GOG_19_SIZE='2200000'
ARCHIVE_GOG_19_VERSION='1.5.0-gog36394'

ARCHIVE_GOG_18='warhammer_40_000_gladius_relics_of_war_1_04_07_36064.sh'
ARCHIVE_GOG_18_MD5='d42c72ef55cb2a42487f8173d26b2260'
ARCHIVE_GOG_18_TYPE='mojosetup'
ARCHIVE_GOG_18_SIZE='2300000'
ARCHIVE_GOG_18_VERSION='1.4.7-gog36064'

ARCHIVE_GOG_17='warhammer_40_000_gladius_relics_of_war_1_04_06_35728.sh'
ARCHIVE_GOG_17_MD5='012ed368d39019fde24d18fbec0656b6'
ARCHIVE_GOG_17_TYPE='mojosetup'
ARCHIVE_GOG_17_SIZE='2300000'
ARCHIVE_GOG_17_VERSION='1.4.6-gog35728'

ARCHIVE_GOG_16='warhammer_40_000_gladius_relics_of_war_1_04_05_01_35243.sh'
ARCHIVE_GOG_16_MD5='5b35850082c4c02a0eb37e19ba747f30'
ARCHIVE_GOG_16_TYPE='mojosetup'
ARCHIVE_GOG_16_SIZE='2300000'
ARCHIVE_GOG_16_VERSION='1.4.5.1-gog35243'

ARCHIVE_GOG_15='warhammer_40_000_gladius_relics_of_war_1_04_05_00_35202.sh'
ARCHIVE_GOG_15_MD5='972ef197130ab89e2bfe4db660d46f13'
ARCHIVE_GOG_15_TYPE='mojosetup'
ARCHIVE_GOG_15_SIZE='2300000'
ARCHIVE_GOG_15_VERSION='1.4.5.0-gog35202'

ARCHIVE_GOG_14='warhammer_40_000_gladius_relics_of_war_1_04_04_00_34697.sh'
ARCHIVE_GOG_14_MD5='14dae75096f06ae63d232adc19dfef21'
ARCHIVE_GOG_14_TYPE='mojosetup'
ARCHIVE_GOG_14_SIZE='2100000'
ARCHIVE_GOG_14_VERSION='1.4.4.0-gog34697'

ARCHIVE_GOG_13='warhammer_40_000_gladius_relics_of_war_1_04_03_01_34357.sh'
ARCHIVE_GOG_13_MD5='b174fa2e2f68a077e12f8b30fa3a35f0'
ARCHIVE_GOG_13_TYPE='mojosetup'
ARCHIVE_GOG_13_SIZE='2100000'
ARCHIVE_GOG_13_VERSION='1.4.3.1-gog34357'

ARCHIVE_GOG_12='warhammer_40_000_gladius_relics_of_war_1_04_03_34214.sh'
ARCHIVE_GOG_12_MD5='2d15061d4dbaef7d4e1cf6d7f187488e'
ARCHIVE_GOG_12_TYPE='mojosetup'
ARCHIVE_GOG_12_SIZE='2100000'
ARCHIVE_GOG_12_VERSION='1.4.3-gog34214'

ARCHIVE_GOG_11='warhammer_40_000_gladius_relics_of_war_1_04_01_33591.sh'
ARCHIVE_GOG_11_MD5='54c5c2a4c6763d922c718703ad480df9'
ARCHIVE_GOG_11_TYPE='mojosetup'
ARCHIVE_GOG_11_SIZE='2100000'
ARCHIVE_GOG_11_VERSION='1.4.1-gog33591'

ARCHIVE_GOG_10='warhammer_40_000_gladius_relics_of_war_1_04_01_33276.sh'
ARCHIVE_GOG_10_MD5='7e46463d849b90daa75bb3430cffe7e9'
ARCHIVE_GOG_10_TYPE='mojosetup'
ARCHIVE_GOG_10_SIZE='2100000'
ARCHIVE_GOG_10_VERSION='1.4.1-gog33276'

ARCHIVE_GOG_9='warhammer_40_000_gladius_relics_of_war_1_04_00_33227.sh'
ARCHIVE_GOG_9_MD5='cd2eb9299dddb4b3007bcb819a490ac9'
ARCHIVE_GOG_9_TYPE='mojosetup'
ARCHIVE_GOG_9_SIZE='2100000'
ARCHIVE_GOG_9_VERSION='1.4.0-gog33227'

ARCHIVE_GOG_8='warhammer_40_000_gladius_relics_of_war_1_03_08_32868.sh'
ARCHIVE_GOG_8_MD5='0739ede31aa10db01b2afef9f66c5e12'
ARCHIVE_GOG_8_TYPE='mojosetup'
ARCHIVE_GOG_8_SIZE='2100000'
ARCHIVE_GOG_8_VERSION='1.3.8-gog32868'

ARCHIVE_GOG_7='warhammer_40_000_gladius_relics_of_war_1_03_07_32417.sh'
ARCHIVE_GOG_7_MD5='c7b2c3399b54c40b52f8355460f9f95d'
ARCHIVE_GOG_7_TYPE='mojosetup'
ARCHIVE_GOG_7_SIZE='2100000'
ARCHIVE_GOG_7_VERSION='1.3.7-gog32417'

ARCHIVE_GOG_6='warhammer_40_000_gladius_relics_of_war_1_03_05_31840.sh'
ARCHIVE_GOG_6_MD5='3d44bb09b3beee7ea34e17b621f9ff03'
ARCHIVE_GOG_6_TYPE='mojosetup'
ARCHIVE_GOG_6_SIZE='2100000'
ARCHIVE_GOG_6_VERSION='1.3.5-gog31840'

ARCHIVE_GOG_5='warhammer_40_000_gladius_relics_of_war_1_03_04_06_31598.sh'
ARCHIVE_GOG_5_MD5='fa36d050eb352b52082beea3ef414324'
ARCHIVE_GOG_5_TYPE='mojosetup'
ARCHIVE_GOG_5_SIZE='2100000'
ARCHIVE_GOG_5_VERSION='1.3.4-gog31598'

ARCHIVE_GOG_4='warhammer_40_000_gladius_relics_of_war_1_03_03_31235.sh'
ARCHIVE_GOG_4_MD5='6e80aca35b75153c5c469584edf332fa'
ARCHIVE_GOG_4_TYPE='mojosetup'
ARCHIVE_GOG_4_SIZE='2000000'
ARCHIVE_GOG_4_VERSION='1.3.3-gog31235'

ARCHIVE_GOG_3='warhammer_40_000_gladius_relics_of_war_1_03_02a_31191.sh'
ARCHIVE_GOG_3_MD5='365ed8bc91dae2e38d2fe075601f372c'
ARCHIVE_GOG_3_TYPE='mojosetup'
ARCHIVE_GOG_3_SIZE='2000000'
ARCHIVE_GOG_3_VERSION='1.3.2-gog31191'

ARCHIVE_GOG_2='warhammer_40_000_gladius_relics_of_war_1_03_01_31091.sh'
ARCHIVE_GOG_2_TYPE='mojosetup'
ARCHIVE_GOG_2_MD5='57d2c488752a9bf1fd24843b232db78b'
ARCHIVE_GOG_2_SIZE='2000000'
ARCHIVE_GOG_2_VERSION='1.3.1-gog31091'

ARCHIVE_GOG_1='warhammer_40_000_gladius_relics_of_war_1_03_00_31042.sh'
ARCHIVE_GOG_1_MD5='c169fb5b60a2bf04a0e0ae625d53239b'
ARCHIVE_GOG_1_TYPE='mojosetup'
ARCHIVE_GOG_1_SIZE='2000000'
ARCHIVE_GOG_1_VERSION='1.3.0-gog31042'

ARCHIVE_GOG_0='warhammer_40_000_gladius_relics_of_war_1_02_00_26649.sh'
ARCHIVE_GOG_0_MD5='93fdb930918dfd5467c0b5b8838aa795'
ARCHIVE_GOG_0_TYPE='mojosetup'
ARCHIVE_GOG_0_SIZE='1900000'
ARCHIVE_GOG_0_VERSION='1.2.0-gog26649'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='Binaries/Linux-x86_64/Gladius.bin Binaries/Linux-x86_64/libjpeg.so.8 Binaries/Linux-x86_64/libsteam_api.so Binaries/Linux-x86_64/libboost* Binaries/Linux-x86_64/libicu* Binaries/Linux-x86_64/libEOSSDK-Linux-Shipping.so'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_FILES_GOG_0='Binaries/Gladius.bin Binaries/libjpeg.so.8 Binaries/libsteam_api.so Binaries/libboost* Binaries/libicu*'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='*.doc *.pdf Data Documents Manuals Resources'

APP_MAIN_TYPE='native_no-prefix'
APP_MAIN_LIBS='Binaries/Linux-x86_64'
APP_MAIN_PRERUN='# Set working directory to the directory containing the game binary before running it
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'
APP_MAIN_EXE='Binaries/Linux-x86_64/Gladius.bin'
APP_MAIN_ICON='Data/Video/Textures/Icon.png'
# Keep compatibility with old archives
APP_MAIN_LIBS_GOG_0='Binaries'
APP_MAIN_EXE_GOG_0='Binaries/Gladius.bin'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ freetype openal vorbis libcurl"
PKG_BIN_DEPS_ARCH='glfw vulkan-icd-loader libpng ffmpeg miniupnpc zlib'
PKG_BIN_DEPS_DEB='libgcc1, libglfw3 | libglfw3-wayland, libvulkan1, libpng16-16, libavcodec58 | libavcodec-extra58, libavformat58, libavutil56, libminiupnpc17, zlib1g'
PKG_BIN_DEPS_GENTOO='media-libs/glfw media-libs/vulkan-loader media-libs/libpng media-video/ffmpeg net-libs/miniupnpc sys-libs/zlib'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
# Game version < 1.3 uses a different path for binary and libraries
use_archive_specific_value 'APP_MAIN_LIBS'
use_archive_specific_value 'APP_MAIN_EXE'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
