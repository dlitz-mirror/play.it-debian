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
# Escape Goat 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210524.7

# Set game-specific variables

GAME_ID='escape-goat-2'
GAME_NAME='Escape Goat 2'

ARCHIVE_BASE_0='gog_escape_goat_2_2.0.0.11.sh'
ARCHIVE_BASE_0_MD5='50e77abfe8737c6d0e1e37e8ad2460cc'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='260000'
ARCHIVE_BASE_0_VERSION='1.1.0-gog2.0.0.11'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/escape_goat_2'

ARCHIVE_DOC_DATA_PATH='data/noarch/game'
ARCHIVE_DOC_DATA_FILES='Linux.README ReadMe.txt'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='Content fr mono EscapeGoat2.exe Escape?Goat?2.bmp Common.dll EG2.ICSharpCode.SharpZipLib.dll EG2.Newtonsoft.Json.dll Illuminant.dll MonoGame.Framework.dll Physics.dll SDL2-CS.dll SDL2-CS.dll.config Squared.*.dll'

APP_MAIN_TYPE='mono'
APP_MAIN_EXE='EscapeGoat2.exe'
APP_MAIN_ICON='Escape Goat 2.bmp'

PKG_MAIN_DEPS='mono libopenal.so.1 libSDL2-2.0.so.0'
PKG_MAIN_DEPS_DEB='libmono-i18n4.0-cil, libmono-i18n-west4.0-cil, libmono-posix4.0-cil, libmono-security4.0-cil, libmono-corlib4.5-cil, libmono-system4.0-cil, libmono-system-configuration4.0-cil, libmono-system-core4.0-cil, libmono-system-data4.0-cil, libmono-system-drawing4.0-cil, libmono-system-runtime-serialization4.0-cil, libmono-system-security4.0-cil, libmono-system-xml4.0-cil, libmono-system-xml-linq4.0-cil'

# Ensure easy upgrade from packages generated with pre-20210524.7 game script

PKG_MAIN_PROVIDE='escape-goat-2-data'

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
