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

script_version=20210524.2

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

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='EscapeGoat2.bin.x86 lib/libmono-2.0.so.1'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='EscapeGoat2.bin.x86_64 lib64/libmono-2.0.so.1'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Common.dll Content EG2.ICSharpCode.SharpZipLib.dll EG2.Newtonsoft.Json.dll fr Escape?Goat?2.bmp I18N.dll I18N.West.dll Illuminant.dll mono MonoGame.Framework.dll Mono.Posix.dll Mono.Security.dll mscorlib.dll Physics.dll SDL2-CS.dll SDL2-CS.dll.config Squared.Game.dll Squared.Render.dll Squared.Task.dll Squared.Util.dll System.Configuration.dll System.Core.dll System.Data.dll System.dll System.Drawing.dll System.Runtime.Serialization.dll System.Security.dll System.Xml.dll System.Xml.Linq.dll EscapeGoat2.exe'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='EscapeGoat2.bin.x86'
APP_MAIN_EXE_BIN64='EscapeGoat2.bin.x86_64'
APP_MAIN_ICON='Escape Goat 2.bmp'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc libstdc++ libopenal.so.1 libSDL2-2.0.so.0"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="${PKG_BIN32_DEPS}"

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
