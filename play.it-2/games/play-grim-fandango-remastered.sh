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
# Grim Fandango Remastered
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210328.1

# Set game-specific variables

GAME_ID='grim-fandango'
GAME_NAME='Grim Fandango Remastered'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='gog_grim_fandango_remastered_2.3.0.7.sh'
ARCHIVE_GOG_0_MD5='9c5d124c89521d254b0dc259635b2abe'
ARCHIVE_GOG_0_TYPE='mojosetup_unzip'
ARCHIVE_GOG_0_SIZE='6100000'
ARCHIVE_GOG_0_VERSION='1.4-gog2.3.0.7'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/grim_fandango_remastered'

ARCHIVE_DOC_DATA_PATH='data/noarch/game/bin'
ARCHIVE_DOC_DATA_FILES='*License.txt common-licenses'

ARCHIVE_GAME_BIN_PATH='data/noarch/game/bin'
ARCHIVE_GAME_BIN_FILES='GrimFandango *.so x86'

ARCHIVE_GAME_MOVIES_PATH='data/noarch/game/bin'
ARCHIVE_GAME_MOVIES_FILES='MoviesHD'

ARCHIVE_GAME_DATA_PATH='data/noarch/game/bin'
ARCHIVE_GAME_DATA_FILES='*.lab *.LAB controllerdef.txt en_gagl088.lip FontsHD *.tab icon.png patch_v2_or_v3_to_v4.bin patch_v4_to_v5.bin'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='GrimFandango'
APP_MAIN_ICON='icon.png'

PACKAGES_LIST='PKG_DATA PKG_MOVIES PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_MOVIES_ID="${GAME_ID}-movies"
PKG_MOVIES_DESCRIPTION='movies'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_MOVIES_ID} ${PKG_DATA_ID} glibc libstdc++ sdl2 glx glu alsa"
PKG_BIN_DEPS_ARCH='lib32-libx11'
PKG_BIN_DEPS_DEB='libx11-6'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11[abi_x86_32]'

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

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Use system-provided SDL2 library

case "$OPTION_PACKAGE" in
	('arch')
		SYSTEM_SDL2_PATH='/usr/lib32/libSDL2-2.0.so.0'
	;;
	('deb')
		SYSTEM_SDL2_PATH='/usr/lib/i386-linux-gnu/libSDL2-2.0.so.0'
	;;
	('gentoo')
		SYSTEM_SDL2_PATH='/usr/lib32/libSDL2-2.0.so.0'
	;;
	(*)
		liberror 'OPTION_PACKAGE' "$0"
	;;
esac
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use system-provided SDL2 library
SYSTEM_SDL2_PATH='"'$SYSTEM_SDL2_PATH'"'
ln --force --symbolic "$SYSTEM_SDL2_PATH" ./libSDL2-2.0.so.1'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
