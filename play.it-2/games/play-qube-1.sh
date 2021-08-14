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
# Q.U.B.E.
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210508.3

# Set game-specific variables

GAME_ID='qube-1'
GAME_NAME='Q.U.B.E.'

ARCHIVE_BASE_0='QUBE-Linux-2015052901.sh'
ARCHIVE_BASE_0_MD5='5da6f592bad4aa71c6e2a469f7435453'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_VERSION='2.8-humble2015052901'
ARCHIVE_BASE_0_SIZE='1300000'
ARCHIVE_BASE_0_URL='https://www.humblebundle.com/store/qube-directors-cut'

ARCHIVE_DOC_DATA_PATH='data/noarch'
ARCHIVE_DOC_DATA_FILES='README.linux UpdateLog.txt BuildVersion.txt'

ARCHIVE_GAME_BIN_PATH='data/x86'
ARCHIVE_GAME_BIN_FILES='Binaries/Linux/QUBEGame-Linux Binaries/Linux/lib/libPhysX*.so* Binaries/Linux/lib/libsteam_api.so Binaries/Linux/lib/libtcmalloc.so.0'

ARCHIVE_GAME_DATA_PATH='data/noarch'
ARCHIVE_GAME_DATA_FILES='QUBEGame Engine QUBEIcon.*'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Binaries/Linux/QUBEGame-Linux'
APP_MAIN_ICON='QUBEIcon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc libstdc++ glx libSDL2-2.0.so.0 libopenal.so.1 libvorbisfile.so.3 libasound.so.2"
PKG_BIN_DEPS_DEB='libogg0'
PKG_BIN_DEPS_ARCH='lib32-libogg'
PKG_BIN_DEPS_GENTOO='media-libs/libogg[abi_x86_32]'

# Run the game binary from its directory

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Run the game binary from its directory
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'

# Use persistent storage for saved games

DATA_FILES="${DATA_FILES} Binaries/Linux/SaveGame.bin"

# Include shipped SDL2_Mixer library
# The game ships a patched SDL2_Mixer that has an additional symbol: MinorityMix_SetPosition, the SDL2_Mixer source code has no reference to it (only Mix_SetPosition) and online searching only shows similar problems with other Unreal Engine games. It might be possible to fix this using preloading or using an SDL2_Mixer wrapper instead. Analysis of the binary's MinorityMix_SetPosition function is welcome.

ARCHIVE_GAME_BIN_FILES="${ARCHIVE_GAME_BIN_FILES} Binaries/Linux/lib/libSDL2_mixer-2.0.so.0"

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
