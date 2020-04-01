#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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

script_version=20200401.2

# Set game-specific variables

GAME_ID='stardew-valley'
GAME_NAME='Stardew Valley'

ARCHIVE_GOG='stardew_valley_1_4_5_433754439_36068.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/stardew_valley'
ARCHIVE_GOG_MD5='8d4f4fcef669a08a39e105f0eda790f4'
ARCHIVE_GOG_SIZE='1100000'
ARCHIVE_GOG_VERSION='1.4.5-gog36068'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD4='stardew_valley_1_4_3_379_34693.sh'
ARCHIVE_GOG_OLD4_MD5='07875ca8c7823f48a7eb533ac157a9da'
ARCHIVE_GOG_OLD4_SIZE='1700000'
ARCHIVE_GOG_OLD4_VERSION='1.4.3-gog34693'
ARCHIVE_GOG_OLD4_TYPE='mojosetup'

ARCHIVE_GOG_OLD3='stardew_valley_1_4_1_367430508_34378.sh'
ARCHIVE_GOG_OLD3_MD5='2fc31edf997230c90c90c33e096d5762'
ARCHIVE_GOG_OLD3_SIZE='1700000'
ARCHIVE_GOG_OLD3_VERSION='1.4.1-gog34378'
ARCHIVE_GOG_OLD3_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='stardew_valley_1_3_36_27827.sh'
ARCHIVE_GOG_OLD2_MD5='8dd18eb151471a5901592188dfecb8a3'
ARCHIVE_GOG_OLD2_SIZE='990000'
ARCHIVE_GOG_OLD2_VERSION='1.3.36-gog27827'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='stardew_valley_en_1_3_28_22957.sh'
ARCHIVE_GOG_OLD1_MD5='e1e98cc3e891f5aafc23fb6617d6bc05'
ARCHIVE_GOG_OLD1_SIZE='970000'
ARCHIVE_GOG_OLD1_VERSION='1.3.28-gog22957'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_stardew_valley_2.8.0.10.sh'
ARCHIVE_GOG_OLD0_MD5='27c84537bee1baae4e3c2f034cb0ff2d'
ARCHIVE_GOG_OLD0_SIZE='490000'
ARCHIVE_GOG_OLD0_VERSION='1.2.33-gog2.8.0.10'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='lib mcs.bin.x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='lib64 mcs.bin.x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Content mono monoconfig StardewValley.exe BmFont.dll GalaxyCSharp.dll GalaxyCSharp.dll.config libSkiaSharp.dll Lidgren.Network.dll MonoGame.Framework.dll MonoGame.Framework.dll.config SkiaSharp.dll StardewValley.GameData.dll xTile.dll xTilePipeline.dll'

APP_MAIN_TYPE='mono'
APP_MAIN_LIBS_BIN32='lib'
APP_MAIN_LIBS_BIN64='lib64'
APP_MAIN_EXE='StardewValley.exe'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID mono openal sdl2 glx alsa"
PKG_BIN32_DEPS_DEB='libmono-corlib4.5-cil, libmono-posix4.0-cil, libmono-security4.0-cil, libmono-system4.0-cil, libmono-system-configuration4.0-cil, libmono-system-core4.0-cil, libmono-system-data4.0-cil, libmono-system-drawing4.0-cil, libmono-system-runtime-serialization4.0-cil, libmono-system-security4.0-cil, libmono-system-xml4.0-cil, libmono-system-xml-linq4.0-cil, libmono-windowsbase4.0-cil'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"

# Load common functions

target_version='2.12'

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

# Get game icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Make save game manager binaries executable

if [ $DRY_RUN -eq 0 ]; then
	chmod +x "${PKG_BIN32_PATH}${PATH_GAME}/mcs.bin.x86"
	chmod +x "${PKG_BIN64_PATH}${PATH_GAME}/mcs.bin.x86_64"
fi

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
