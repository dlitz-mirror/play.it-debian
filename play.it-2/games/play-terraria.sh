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
# Terraria
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210504.3

# Set game-specific variables

GAME_ID='terraria'
GAME_NAME='Terraria'

ARCHIVES_LIST='
ARCHIVE_BASE_2
ARCHIVE_BASE_1
ARCHIVE_BASE_0
ARCHIVE_BASE_MULTIARCH_4
ARCHIVE_BASE_MULTIARCH_3
ARCHIVE_BASE_MULTIARCH_2
ARCHIVE_BASE_MULTIARCH_1
ARCHIVE_BASE_MULTIARCH_0'

ARCHIVE_BASE_2='terraria_english_v1_4_1_2_42620.sh'
ARCHIVE_BASE_2_MD5='c84d418147004790d97f47c36a1987ba'
ARCHIVE_BASE_2_SIZE='730000'
ARCHIVE_BASE_2_VERSION='1.4.1.2-gog42620'
ARCHIVE_BASE_2_TYPE='mojosetup'
ARCHIVE_BASE_2_URL='https://www.gog.com/game/terraria'

ARCHIVE_BASE_1='terraria_v1_4_1_1_41975.sh'
ARCHIVE_BASE_1_MD5='e0158c754f9a7259d28f1cd3c1e1c747'
ARCHIVE_BASE_1_SIZE='720000'
ARCHIVE_BASE_1_VERSION='1.4.1.1-gog41975'
ARCHIVE_BASE_1_TYPE='mojosetup'

ARCHIVE_BASE_0='terraria_v1_4_1_0_41944.sh'
ARCHIVE_BASE_0_MD5='6d8fd3976503695205e80ba10e8249de'
ARCHIVE_BASE_0_SIZE='720000'
ARCHIVE_BASE_0_VERSION='1.4.1.0-gog41944'
ARCHIVE_BASE_0_TYPE='mojosetup'

ARCHIVE_BASE_MULTIARCH_4='terraria_v1_4_0_5_38805.sh'
ARCHIVE_BASE_MULTIARCH_4_MD5='88940054c5d5a5f556f0bd955559426a'
ARCHIVE_BASE_MULTIARCH_4_SIZE='760000'
ARCHIVE_BASE_MULTIARCH_4_VERSION='1.4.0.5-gog38805'
ARCHIVE_BASE_MULTIARCH_4_TYPE='mojosetup'

ARCHIVE_BASE_MULTIARCH_3='terraria_1_4_0_4_38513.sh'
ARCHIVE_BASE_MULTIARCH_3_MD5='5704d188ab8374f0a36e86bad8adb5a1'
ARCHIVE_BASE_MULTIARCH_3_SIZE='760000'
ARCHIVE_BASE_MULTIARCH_3_VERSION='1.4.0.4-gog38513'
ARCHIVE_BASE_MULTIARCH_3_TYPE='mojosetup'

ARCHIVE_BASE_MULTIARCH_2='terraria_v1_4_0_2_38384.sh'
ARCHIVE_BASE_MULTIARCH_2_MD5='85d3ddcbafdef8412e4f96f3adbc2ed9'
ARCHIVE_BASE_MULTIARCH_2_SIZE='760000'
ARCHIVE_BASE_MULTIARCH_2_VERSION='1.4.0.2-gog38384'
ARCHIVE_BASE_MULTIARCH_2_TYPE='mojosetup'

ARCHIVE_BASE_MULTIARCH_1='terraria_en_1_3_5_3_14602.sh'
ARCHIVE_BASE_MULTIARCH_1_MD5='c99fdc0ae15dbff1e8147b550db4e31a'
ARCHIVE_BASE_MULTIARCH_1_SIZE='490000'
ARCHIVE_BASE_MULTIARCH_1_VERSION='1.3.5.3-gog14602'
ARCHIVE_BASE_MULTIARCH_1_TYPE='mojosetup'

ARCHIVE_BASE_MULTIARCH_0='gog_terraria_2.17.0.21.sh'
ARCHIVE_BASE_MULTIARCH_0_MD5='90ec196ec38a7f7a5002f5a8109493cc'
ARCHIVE_BASE_MULTIARCH_0_SIZE='490000'
ARCHIVE_BASE_MULTIARCH_0_VERSION='1.3.5.3-gog2.17.0.21'

ARCHIVE_DOC_DATA_PATH='data/noarch/game'
ARCHIVE_DOC_DATA_FILES='changelog.txt'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='lib64/libmojoshader.so lib64/libFNA3D.so.0'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Content Terraria.png monoconfig monomachineconfig open-folder Terraria.exe TerrariaServer.exe FNA.dll FNA.dll.config SteelSeriesEngineWrapper.dll'

APP_MAIN_TYPE='mono'
APP_MAIN_LIBS='lib64'
APP_MAIN_EXE='Terraria.exe'
APP_MAIN_ICON='Terraria.png'

APP_SERVER_ID="$GAME_ID-server"
APP_SERVER_NAME="$GAME_NAME Server"
APP_SERVER_TYPE='mono'
APP_SERVER_LIBS="$APP_MAIN_LIBS"
APP_SERVER_EXE='TerrariaServer.exe'
APP_SERVER_ICON='Terraria.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID mono sdl2 openal glx"
PKG_BIN_DEPS_ARCH='faudio'
PKG_BIN_DEPS_DEB='libmono-windowsbase4.0-cil, libmono-system-windows-forms4.0-cil, libmono-system-runtime-serialization4.0-cil, libfaudio0'
PKG_BIN_DEPS_GENTOO='app-emulation/faudio'

# Old archives provide a x86_32 binary + libraries

PACKAGES_LIST_BASE_MULTIARCH='PKG_BIN32 PKG_BIN PKG_DATA'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='lib/libmojoshader.so'

APP_MAIN_LIBS_BIN32='lib'

APP_SERVER_LIBS_BIN32='lib'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID mono sdl2 openal glx"
PKG_BIN32_DEPS_DEB='libmono-windowsbase4.0-cil, libmono-system-windows-forms4.0-cil, libmono-system-runtime-serialization4.0-cil'

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

# Update the list of packages to build, based on the source archive

use_archive_specific_value 'PACKAGES_LIST'
# shellcheck disable=SC2086
set_temp_directories $PACKAGES_LIST

# Dependency on FAudio is only required starting with game version 1.4.1

case "$ARCHIVE" in
	('ARCHIVE_BASE_MULTIARCH'*)
		unset PKG_BIN_DEPS_ARCH
		unset PKG_BIN_DEPS_GENTOO
		export PKG_BIN_DEPS_DEB='libmono-windowsbase4.0-cil, libmono-system-windows-forms4.0-cil, libmono-system-runtime-serialization4.0-cil'
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icons

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN' 'APP_SERVER'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_SERVER'
case "$ARCHIVE" in
	('ARCHIVE_BASE_MULTIARCH'*)
		PKG='PKG_BIN32'
		launchers_write 'APP_MAIN' 'APP_SERVER'
	;;
esac

# Always run the server in a terminal

desktop_file="${PKG_BIN_PATH}${PATH_DESK}/${APP_SERVER_ID}.desktop"
cat >> "$desktop_file" << EOF
Terminal=true
EOF
case "$ARCHIVE" in
	('ARCHIVE_GOG_MULTIARCH'*)
		desktop_file="${PKG_BIN32_PATH}${PATH_DESK}/${APP_SERVER_ID}.desktop"
		cat >> "$desktop_file" <<- EOF
		Terminal=true
		EOF
	;;
esac

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

#print instructions

print_instructions

exit 0
