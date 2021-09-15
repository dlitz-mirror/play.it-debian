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
# Transistor
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210912.1

# Set game-specific variables

GAME_ID='transistor'
GAME_NAME='Transistor'

ARCHIVE_BASE_2='transistor_1_50440_8123_23365.sh'
ARCHIVE_BASE_2_MD5='dc89c175267dc1a1f3434a9d4f903cce'
ARCHIVE_BASE_2_TYPE='mojosetup'
ARCHIVE_BASE_2_SIZE='3600000'
ARCHIVE_BASE_2_VERSION='1.50440.8123-gog23365'
ARCHIVE_BASE_2_URL='https://www.gog.com/game/transistor'

ARCHIVE_BASE_1='transistor_en_v1_50423_21516.sh'
ARCHIVE_BASE_1_MD5='52d0df1d959b333b17ede106f8e53062'
ARCHIVE_BASE_1_TYPE='mojosetup'
ARCHIVE_BASE_1_SIZE='3600000'
ARCHIVE_BASE_1_VERSION='1.50423-gog21516'

ARCHIVE_BASE_0='gog_transistor_2.0.0.3.sh'
ARCHIVE_BASE_0_MD5='53dbaf643471f3b8494548261584dd13'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='3200000'
ARCHIVE_BASE_0_VERSION='1.20140310-gog2.0.0.3'

ARCHIVE_DOC_MAIN_PATH='data/noarch/game'
ARCHIVE_DOC_MAIN_FILES='Linux.README'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='Content *.bmp *.cfg *.pdb *.xml *.txt monoconfig monomachineconfig Transistor.exe Transistor.exe.config Engine.dll Engine.dll.config Engine.SDL2.dll Engine.SDL2.dll.config HostessProtocol.dll KeraLua.dll MonoGame.Framework.SDL2.dll NLua.dll SDL2-CS.dll SDL2-CS.dll.config Newtonsoft.Json.dll Newtonsoft.Json.pdb Newtonsoft.Json.xml'

APP_MAIN_TYPE='mono'
APP_MAIN_EXE='Transistor.exe'
APP_MAIN_ICON='Transistor.bmp'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='glibc libstdc++ mono alsa glx libSDL2-2.0.so.0'
PKG_MAIN_DEPS_DEB='libmono-corlib4.5-cil, libmono-posix4.0-cil, libmono-security4.0-cil, libmono-system4.0-cil, libmono-system-core4.0-cil, libmono-system-configuration4.0-cil, libmono-system-data4.0-cil, libmono-system-design4.0-cil, libmono-system-drawing4.0-cil, libmono-system-management4.0-cil, libmono-system-numerics4.0-cil, libmono-system-runtime-serialization4.0-cil, libmono-system-security4.0-cil, libmono-system-transactions4.0-cil, libmono-system-xml4.0-cil, libmono-system-xml-linq4.0-cil'

# Include shipped libraries that can not be replaced by system ones

ARCHIVE_GAME_LIBS32_PATH='data/noarch/game'
ARCHIVE_GAME_LIBS32_FILES='lib/libBink.so lib/libFModPlugins.so lib/libfmod.so.4 lib/libfmodstudio.so.4 lib/liblua52.so'
ARCHIVE_GAME_LIBS64_PATH='data/noarch/game'
ARCHIVE_GAME_LIBS64_FILES='lib64/libBink.so lib64/libFModPlugins.so lib64/libfmod.so.4 lib64/libfmodstudio.so.4 lib64/liblua52.so'

PACKAGES_LIST="$PACKAGES_LIST PKG_LIBS32 PKG_LIBS64"

PKG_LIBS_ID="${GAME_ID}-libs"
PKG_LIBS32_ID="$PKG_LIBS_ID"
PKG_LIBS32_PROVIDE="$PKG_LIBS_ID"
PKG_LIBS32_ARCH='32'
PKG_LIBS64_ID="$PKG_LIBS_ID"
PKG_LIBS64_PROVIDE="$PKG_LIBS_ID"
PKG_LIBS64_ARCH='64'

PKG_MAIN_DEPS="$PKG_MAIN_DEPS $PKG_LIBS_ID"

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Preload shipped libraries
if [ -e "lib64" ]; then
	APP_LIBS="lib64"
elif [ -e "lib" ]; then
	APP_LIBS="lib"
fi'

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

# Get icon

PKG='PKG_MAIN'
icons_get_from_package 'APP_MAIN'

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Do not use a local user prefix

launcher_write_script_user_files() { true; }
launcher_write_script_prefix_variables() { true; }
launcher_write_script_prefix_functions() { true; }
launcher_write_script_prefix_build() {
	cat >> "$1" <<- 'EOF'
	# Do not use a local user prefix

	export PATH_PREFIX="$PATH_GAME"

	EOF
}

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
