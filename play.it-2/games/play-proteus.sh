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
# Proteus
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210513.4

# Set game-specific variables

GAME_ID='proteus'
GAME_NAME='Proteus'

ARCHIVE_BASE_0='proteus-05162014-bin'
ARCHIVE_BASE_0_MD5='8a5911751382bcfb91483f52f781e283'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_VERSION='1.0-humble140516'
ARCHIVE_BASE_0_SIZE='130000'
ARCHIVE_BASE_0_URL='https://www.humblebundle.com/store/proteus'

ARCHIVE_DOC_MAIN_PATH='data'
ARCHIVE_DOC_MAIN_FILES='Linux.README'

ARCHIVE_GAME_MAIN_PATH='data'
ARCHIVE_GAME_MAIN_FILES='Proteus.exe Proteus.png KopiLua.dll KopiLuaDll.dll KopiLuaInterface.dll SDL2-CS.dll SDL2-CS.dll.config Tao.OpenGl.dll Tao.OpenGl.dll.config Tianxia.dll Wuwei.dll resources'

APP_MAIN_TYPE='mono'
APP_MAIN_EXE='Proteus.exe'
APP_MAIN_ICON='Proteus.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='mono glx xcursor libxrandr sdl2_image sdl2_mixer libSDL2-2.0.so.0'
PKG_MAIN_DEPS_DEB='libmono-posix4.0-cil, libmono-security4.0-cil, libmono-corlib4.5-cil, libmono-system-configuration4.0-cil, libmono-system-core4.0-cil, libmono-system-data4.0-cil, libmono-system4.0-cil, libmono-system-drawing4.0-cil, libmono-system-security4.0-cil, libmono-system-xml4.0-cil'

# Ensure easy upgrade from packages built with pre-20210506.8 game script

PKG_MAIN_PROVIDE='proteus-data'

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

icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
