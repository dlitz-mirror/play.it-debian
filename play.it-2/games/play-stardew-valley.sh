#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
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
# Stardew Valley
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210706.9

# Set game-specific variables

GAME_ID='stardew-valley'
GAME_NAME='Stardew Valley'

ARCHIVE_BASE_11='stardew_valley_1_5_4_981587505_44377.sh'
ARCHIVE_BASE_11_MD5='ffeb52df688e169950d2b9d883c5e390'
ARCHIVE_BASE_11_TYPE='mojosetup'
ARCHIVE_BASE_11_SIZE='650000'
ARCHIVE_BASE_11_VERSION='1.5.4-gog44377'
ARCHIVE_BASE_11_URL='https://www.gog.com/game/stardew_valley'

ARCHIVE_BASE_10='stardew_valley_1_5_3_967165180_44219.sh'
ARCHIVE_BASE_10_MD5='c87b0beffe3236dd8545274037754c18'
ARCHIVE_BASE_10_TYPE='mojosetup'
ARCHIVE_BASE_10_SIZE='650000'
ARCHIVE_BASE_10_VERSION='1.5.3-gog44219'

ARCHIVE_BASE_9='stardew_valley_1_5_2_952803924_44046.sh'
ARCHIVE_BASE_9_MD5='56eb232720c737cb025f404ee74801ce'
ARCHIVE_BASE_9_TYPE='mojosetup'
ARCHIVE_BASE_9_SIZE='650000'
ARCHIVE_BASE_9_VERSION='1.5.2-gog44046'

ARCHIVE_BASE_8='stardew_valley_1_5_1_931692592_43684.sh'
ARCHIVE_BASE_8_MD5='8d9e0b2df18acbc1b83cd10b05ca9196'
ARCHIVE_BASE_8_TYPE='mojosetup'
ARCHIVE_BASE_8_SIZE='650000'
ARCHIVE_BASE_8_VERSION='1.5.1-gog43684'

ARCHIVE_BASE_7='stardew_valley_1_5_928320980_43631.sh'
ARCHIVE_BASE_7_MD5='50e1bbad197664a5b3511cba978c2fde'
ARCHIVE_BASE_7_TYPE='mojosetup'
ARCHIVE_BASE_7_SIZE='650000'
ARCHIVE_BASE_7_VERSION='1.5-gog43631'

ARCHIVE_BASE_6='stardew_valley_1_5_926914271_43619.sh'
ARCHIVE_BASE_6_MD5='cb92377270ecb859117e41dce26eeb69'
ARCHIVE_BASE_6_TYPE='mojosetup'
ARCHIVE_BASE_6_SIZE='650000'
ARCHIVE_BASE_6_VERSION='1.5-gog43619'

ARCHIVE_BASE_5='stardew_valley_1_4_5_433754439_36068.sh'
ARCHIVE_BASE_5_MD5='8d4f4fcef669a08a39e105f0eda790f4'
ARCHIVE_BASE_5_TYPE='mojosetup'
ARCHIVE_BASE_5_SIZE='1100000'
ARCHIVE_BASE_5_VERSION='1.4.5-gog36068'

ARCHIVE_BASE_4='stardew_valley_1_4_3_379_34693.sh'
ARCHIVE_BASE_4_MD5='07875ca8c7823f48a7eb533ac157a9da'
ARCHIVE_BASE_4_TYPE='mojosetup'
ARCHIVE_BASE_4_SIZE='1700000'
ARCHIVE_BASE_4_VERSION='1.4.3-gog34693'

ARCHIVE_BASE_3='stardew_valley_1_4_1_367430508_34378.sh'
ARCHIVE_BASE_3_MD5='2fc31edf997230c90c90c33e096d5762'
ARCHIVE_BASE_3_TYPE='mojosetup'
ARCHIVE_BASE_3_SIZE='1700000'
ARCHIVE_BASE_3_VERSION='1.4.1-gog34378'

ARCHIVE_BASE_2='stardew_valley_1_3_36_27827.sh'
ARCHIVE_BASE_2_MD5='8dd18eb151471a5901592188dfecb8a3'
ARCHIVE_BASE_2_TYPE='mojosetup'
ARCHIVE_BASE_2_SIZE='990000'
ARCHIVE_BASE_2_VERSION='1.3.36-gog27827'

ARCHIVE_BASE_1='stardew_valley_en_1_3_28_22957.sh'
ARCHIVE_BASE_1_MD5='e1e98cc3e891f5aafc23fb6617d6bc05'
ARCHIVE_BASE_1_TYPE='mojosetup'
ARCHIVE_BASE_1_SIZE='970000'
ARCHIVE_BASE_1_VERSION='1.3.28-gog22957'

ARCHIVE_BASE_0='gog_stardew_valley_2.8.0.10.sh'
ARCHIVE_BASE_0_MD5='27c84537bee1baae4e3c2f034cb0ff2d'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='490000'
ARCHIVE_BASE_0_VERSION='1.2.33-gog2.8.0.10'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='Content mono monoconfig StardewValley.exe BmFont.dll GalaxyCSharp.dll GalaxyCSharp.dll.config libSkiaSharp.dll Lidgren.Network.dll MonoGame.Framework.dll MonoGame.Framework.dll.config SkiaSharp.dll StardewValley.GameData.dll xTile.dll xTilePipeline.dll'

APP_MAIN_TYPE='mono'
APP_MAIN_EXE='StardewValley.exe'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='mono glx alsa libopenal.so.1 libSDL2-2.0.so.0'
PKG_MAIN_DEPS_DEB='libmono-corlib4.5-cil, libmono-posix4.0-cil, libmono-security4.0-cil, libmono-system4.0-cil, libmono-system-configuration4.0-cil, libmono-system-core4.0-cil, libmono-system-data4.0-cil, libmono-system-drawing4.0-cil, libmono-system-runtime-serialization4.0-cil, libmono-system-security4.0-cil, libmono-system-xml4.0-cil, libmono-system-xml-linq4.0-cil, libmono-windowsbase4.0-cil'

# The game manager is provided as an ELF binary

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='mcs.bin.x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='mcs.bin.x86_64'

PACKAGES_LIST="$PACKAGES_LIST PKG_BIN32 PKG_BIN64"

PKG_BIN_ID="${GAME_ID}-bin"
PKG_BIN_DESCRIPTION='game manager binary'

PKG_BIN32_ID="$PKG_BIN_ID"
PKG_BIN32_ARCH='32'
PKG_BIN32_DESCRIPTION="$PKG_BIN_DESCRIPTION"

PKG_BIN64_ID="$PKG_BIN_ID"
PKG_BIN64_ARCH='64'
PKG_BIN64_DESCRIPTION="$PKG_BIN_DESCRIPTION"

PKG_MAIN_DEPS="$PKG_MAIN_DEPS $PKG_BIN_ID"

# The game fails to load libraries if they are not inside some hardcoded path

# shellcheck disable=SC1004
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# The game fails to load libraries if they are not inside some hardcoded path
mkdir --parents lib
ln --force --no-target-directory --symbolic lib lib64
library_file=$(/sbin/ldconfig --print-cache | \
	awk -F " => " "/libSDL2-2\.0\.so\.0/ {print \$2}" | \
	head --lines=1)
ln --force --symbolic "$library_file" lib
library_file=$(/sbin/ldconfig --print-cache | \
	awk -F " => " "/libopenal\.so\.1/ {print \$2}" | \
	head --lines=1)
ln --force --symbolic "$library_file" lib'

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

# Get game icon

PKG='PKG_MAIN'
icons_get_from_workdir 'APP_MAIN'

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Ensure game manager binaries are executable

if [ $DRY_RUN -eq 0 ]; then
	chmod +x "$(package_get_path 'PKG_BIN32')${PATH_GAME}/mcs.bin.x86"
	chmod +x "$(package_get_path 'PKG_BIN64')${PATH_GAME}/mcs.bin.x86_64"
fi

# Write launchers

PKG='PKG_MAIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
