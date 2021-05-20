#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2018-2021, BetaRays
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
# Tooth and Tail
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210516.1

# Set game-specific variables

GAME_ID='tooth-and-tail'
GAME_NAME='Tooth and Tail'

ARCHIVE_BASE_0='toothandtail_linux.zip'
ARCHIVE_BASE_0_MD5='5a01a61889e795b538d3db288a6f519d'
ARCHIVE_BASE_0_VERSION='1.6.1.1-humble1'
ARCHIVE_BASE_0_SIZE='600000'

ARCHIVE_GAME_BIN32_PATH='Release'
ARCHIVE_GAME_BIN32_FILES='lib/libmojoshader.so lib/libtheorafile.so'

ARCHIVE_GAME_BIN64_PATH='Release'
ARCHIVE_GAME_BIN64_FILES='lib64/libfmod.so.10 lib64/libfmodstudio.so.10 lib64/libmojoshader.so lib64/libtheorafile.so'

ARCHIVE_GAME_DATA_PATH='Release'
ARCHIVE_GAME_DATA_FILES='ToothAndTail.exe ToothAndTail.exe.config FNA.dll FNA.dll.config Glide.dll fr/ToothAndTail.resources.dll content'

APP_MAIN_TYPE='mono'
APP_MAIN_LIBS_BIN32='lib'
APP_MAIN_LIBS_BIN64='lib64'
APP_MAIN_EXE='ToothAndTail.exe'
APP_MAIN_ICON='ToothAndTail.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} mono openal sdl2 sdl2_image theora vorbis"
PKG_BIN32_DEPS_DEB='libmono-posix4.0-cil, libmono-security4.0-cil, libmono-corlib4.5-cil, libnewtonsoft-json5.0-cil, libmono-system-configuration4.0-cil, libmono-system-core4.0-cil, libmono-system-data4.0-cil, libmono-system4.0-cil, libmono-system-drawing4.0-cil, libmono-system-net4.0-cil, libmono-system-net-http4.0-cil, libmono-system-runtime-serialization4.0-cil, libmono-system-security4.0-cil, libmono-system-windows-forms4.0-cil, libmono-system-xml4.0-cil, libmono-system-xml-linq4.0-cil'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"

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

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
