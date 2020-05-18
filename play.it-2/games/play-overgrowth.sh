#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, BetaRays
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
# Overgrowth
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190603.14

# Set game-specific variables

GAME_ID='overgrowth'
GAME_NAME='Overgrowth'

ARCHIVE_HUMBLE='overgrowth-1.4.0_build-5584-linux64.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/overgrowth'
ARCHIVE_HUMBLE_MD5='748f6888386d842193218c53396ac844'
ARCHIVE_HUMBLE_VERSION='1.4.0.5584-humble'
ARCHIVE_HUMBLE_SIZE='22000000'

ARCHIVE_GAME_BIN_PATH='Overgrowth'
ARCHIVE_GAME_BIN_FILES='Overgrowth.bin.x86_64 lib64/libsteam_api.so'

ARCHIVE_GAME_TEXTURES_TERRAIN_PATH='Overgrowth'
ARCHIVE_GAME_TEXTURES_TERRAIN_FILES='Data/Textures/Terrain'

ARCHIVE_GAME_TEXTURES_PATH='Overgrowth'
ARCHIVE_GAME_TEXTURES_FILES='Data/Textures'

ARCHIVE_GAME_DATA_PATH='Overgrowth'
ARCHIVE_GAME_DATA_FILES='Data'

DATA_DIRS='./Data/Levels ./Data/Mods ./Data/Scripts'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Overgrowth.bin.x86_64'
APP_MAIN_ICON='Data/Textures/ui/ogicon.png'

PACKAGES_LIST='PKG_BIN PKG_TEXTURES_TERRAIN PKG_TEXTURES PKG_DATA'

PKG_TEXTURES_TERRAIN_ID="${GAME_ID}-textures-terrain"
PKG_TEXTURES_TERRAIN_DESCRIPTION='textures - terrain'

PKG_TEXTURES_ID="${GAME_ID}-textures"
PKG_TEXTURES_DESCRIPTION='textures'
PKG_TEXTURES_DEPS="$PKG_TEXTURES_TERRAIN_ID"

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DEPS="$PKG_TEXTURES_ID"

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ sdl2 openal gtk2 glx glu"
PKG_BIN_DEPS_DEB='libsdl2-net-2.0-0, zlib1g, libglib2.0-0, libfreeimage3'
PKG_BIN_DEPS_ARCH='sdl2_net zlib glib2 freeimage'
PKG_BIN_DEPS_GENTOO='media-libs/sdl2-net sys-libs/zlib dev-libs/glib:2 media-libs/freeimage'

# Load common functions

target_version='2.11'

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
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

PKG='PKG_TEXTURES'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_TEXTURES'
write_metadata 'PKG_BIN' 'PKG_DATA' 'PKG_TEXTURES_TERRAIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
