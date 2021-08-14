#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2020, Mopi
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
# Windosill
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201203.1

# Set game-specific variables

GAME_ID='windosill'
GAME_NAME='Windosill'

ARCHIVES_LIST='
ARCHIVE_ITCH_0'

ARCHIVE_ITCH_0='Windosill'
ARCHIVE_ITCH_0_MD5='853ab5f3ea6b2691718466f0479b867f'
ARCHIVE_ITCH_0_TYPE='file' # Dummy type, the archive is copied as-is in the package
ARCHIVE_ITCH_0_SIZE='19000'
ARCHIVE_ITCH_0_VERSION='1.0-itch'
ARCHIVE_ITCH_0_URL='https://vectorpark.itch.io/windosill'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Windosill'

PACKAGES_LIST='PKG_MAIN'

###
# TODO
# Add missing Arch Linux dependencies for:
# - libfontconfig.so.1
# - libatk-1.0.so.0
# - libpangoft2-1.0.so.0
# - libpangocairo-1.0.so.0
# - libcairo.so.2
# - libpango-1.0.so.0
# - libgmodule-2.0.so.0
# - libssl3.so
# - libsmime3.so
# - libnss3.so
# - libnssutil3.so
# - libplds4.so
# - libplc4.so
# - libnspr4.so
# - libXrender.so.1
###
PKG_MAIN_ARCH='32'
PKG_MAIN_DEPS='glibc freetype gtk2 libgdk_pixbuf-2.0.so.0 libgobject-2.0.so.0 libglib-2.0.so.0 xcursor'
PKG_MAIN_DEPS_ARCH='lib32-libx11 lib32-libxext lib32-libxt'
PKG_MAIN_DEPS_DEB='libx11-6, libxext6, libxt6, libfontconfig1, libatk1.0-0, libpangoft2-1.0-0, libpangocairo-1.0-0, libcairo2, libpango-1.0-0, libglib2.0-0, libnss3, libnspr4, libxrender1'
PKG_MAIN_DEPS_GENTOO='x11-libs/libX11[abi_x86_32] x11-libs/libXext[abi_x86_32] x11-libs/libXt[abi_x86_32] media-libs/fontconfig[abi_x86_32] dev-libs/atk[abi_x86_32] x11-libs/pango[abi_x86_32] x11-libs/cairo[abi_x86_32] dev-libs/glib[abi_x86_32] dev-libs/nss[abi_x86_32] dev-libs/nspr[abi_x86_32] x11-libs/libXrender[abi_x86_32]'

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

mkdir --parents "${PKG_MAIN_PATH}${PATH_GAME}"
cp "$SOURCE_ARCHIVE" "${PKG_MAIN_PATH}${PATH_GAME}/Windosill"

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
