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
# Dead Synchronicity: Tomorrow Comes Today
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210712.7

# Set game-specific variables

GAME_ID='dead-synchronicity'
GAME_NAME='Dead Synchronicity: Tomorrow Comes Today'

ARCHIVE_BASE_ZOOM_0='Dead-Synchronicity-1.1.tar.xz'
ARCHIVE_BASE_ZOOM_0_MD5='625ab4fc87c1b8744de35a5c9b86bdf4'
ARCHIVE_BASE_ZOOM_0_TYPE='tar' # The type declaration should be dropped with ./play.it 2.14 release
ARCHIVE_BASE_ZOOM_0_SIZE='3200000'
ARCHIVE_BASE_ZOOM_0_VERSION='1.0.7-zoom1.1'
ARCHIVE_BASE_ZOOM_0_URL='https://www.zoom-platform.com/product/dead-synchronicity'

ARCHIVE_BASE_HUMBLE_0='Dead_Synchronicity_1.0.7_Linux_Full_EN_FR_IT_DE_ES_KO_JA_Daedalic_noDRM.tar.gz'
ARCHIVE_BASE_HUMBLE_0_MD5='0aee9cc5d5c256f47ce61b313115a601'
ARCHIVE_BASE_HUMBLE_0_SIZE='3200000'
ARCHIVE_BASE_HUMBLE_0_VERSION='1.0.7-humble1'
ARCHIVE_BASE_HUMBLE_0_URL='https://www.humblebundle.com/store/dead-synchronicity-tomorrow-comes-today'

ARCHIVE_GAME_BIN32_PATH='Dead Synchronicity'
ARCHIVE_GAME_BIN32_FILES='Dead?Synchronicity.x86 Dead?Synchronicity_Data/Mono/x86 Dead?Synchronicity_Data/Plugins/x86'

ARCHIVE_GAME_BIN64_PATH='Dead Synchronicity'
ARCHIVE_GAME_BIN64_FILES='Dead?Synchronicity.x86_64 Dead?Synchronicity_Data/Mono/x86_64 Dead?Synchronicity_Data/Plugins/x86_64'

ARCHIVE_GAME_DATA_PATH='Dead Synchronicity'
ARCHIVE_GAME_DATA_FILES='Dead?Synchronicity_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Dead Synchronicity.x86'
APP_MAIN_EXE_BIN64='Dead Synchronicity.x86_64'
APP_MAIN_ICON='Dead Synchronicity_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx xcursor libxrandr gtk2 freetype libGLU.so.1 libX11.so.6 libgdk-x11-2.0.so.0 libgdk_pixbuf-2.0.so.0 libgobject-2.0.so.0 libglib-2.0.so.0"
PKG_BIN32_DEPS_ARCH='lib32-libxext lib32-atk lib32-glib2 lib32-pango lib32-cairo lib32-fontconfig'
PKG_BIN32_DEPS_DEB='libxext6, libatk1.0-0, libglib2.0-0, libpangoft2-1.0-0, libpangocairo-1.0-0, libcairo2, libpango-1.0-0, libfontconfig1'
PKG_BIN32_DEPS_GENTOO='x11-libs/libXext[abi_x86_32] dev-libs/atk[abi_x86_32] dev-libs/glib[abi_x86_32] x11-libs/pango[abi_x86_32] x11-libs/cairo[abi_x86_32] media-libs/fontconfig[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libxext atk glib2 pango cairo fontconfig'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/libXext dev-libs/atk dev-libs/glib x11-libs/pango x11-libs/cairo media-libs/fontconfig'

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

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
set_standard_permissions "${PLAYIT_WORKDIR}/gamedata"
prepare_package_layout

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Delete temporary files

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
