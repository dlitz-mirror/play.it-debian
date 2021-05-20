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
# Opus Magnum
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210511.3

# Set game-specific variables

GAME_ID='opus-magnum'
GAME_NAME='Opus Magnum'

ARCHIVE_BASE_0='opus_magnum_en_17_08_2018_update_23270.sh'
ARCHIVE_BASE_0_MD5='dbe5137d4b7e2edd21f4117a80756872'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='460000'
ARCHIVE_BASE_0_VERSION='2018.08.17-gog23270'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/opus_magnum'

ARCHIVE_DOC_MAIN_PATH='data/noarch/game'
ARCHIVE_DOC_MAIN_FILES='*.txt'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='Content PackedContent monoconfig monomachineconfig Lightning.exe Lightning.exe.config Ionic.Zip.Reduced.dll Steamworks.NET.dll'

APP_MAIN_TYPE='mono'
APP_MAIN_EXE='Lightning.exe'
APP_MAIN_ICON='Lightning.exe'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='mono sdl2 sdl2_image sdl2_mixer vorbis glx'
PKG_MAIN_DEPS_DEB='libmono-posix4.0-cil, libmono-security4.0-cil, libmono-system4.0-cil, libmono-system-configuration4.0-cil, libmono-system-core4.0-cil, libmono-system-data4.0-cil, libmono-system-drawing4.0-cil, libmono-system-security4.0-cil, libmono-system-web4.0-cil, libmono-system-web-extensions4.0-cil, libmono-system-web-http4.0-cil, libmono-system-web-services4.0-cil, libmono-system-xml4.0-cil'

# Ensure easy upgrade from packages generated with pre-20210506.1 script

PKG_MAIN_PROVIDE='opus-magnum-data'

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

# Extract icon

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
