#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Memoranda
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200328.1

# Set game-specific variables

SCRIPT_DEPS='convert'

GAME_ID='memoranda'
GAME_NAME='Memoranda'

ARCHIVE_GOG='gog_memoranda_2.2.0.3.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/memoranda'
ARCHIVE_GOG_MD5='9671ebb592d4b4a028fd80f76e96c1a1'
ARCHIVE_GOG_SIZE='800000'
ARCHIVE_GOG_VERSION='1.0-gog2.2.0.3'

ARCHIVE_OPTIONAL_LIBSSL32='libssl_1.0.0_32-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBSSL32_URL='https://downloads.dotslashplay.it/resources/libssl/'
ARCHIVE_OPTIONAL_LIBSSL32_MD5='9443cad4a640b2512920495eaf7582c4'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='runner'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='assets'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# Work around Mesa-related startup crash
# cf. https://gitlab.freedesktop.org/mesa/mesa/issues/1310
export radeonsi_sync_compile=true'
APP_MAIN_EXE='runner'
APP_MAIN_ICON='assets/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx openal libxrandr glu"
PKG_BIN_DEPS_ARCH='lib32-zlib lib32-libxxf86vm lib32-libxext lib32-libx11 lib32-openssl-1.0 lib32-gcc-libs'
PKG_BIN_DEPS_DEB='zlib1g, libxxf86vm1, libxext6, libx11-6, libgcc-s1 | libgcc1'
PKG_BIN_DEPS_GENTOO='sys-libs/zlib[abi_x86_32] x11-libs/libXxf86vm[abi_x86_32] x11-libs/libXext[abi_x86_32] x11-libs/libX11[abi_x86_32] dev-libs/openssl-compat[abi_x86_32]'

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

# Use libSSL 1.0.0 32-bit archive (Debian packages only)

case "$OPTION_PACKAGE" in
	('deb')
		ARCHIVE_MAIN="$ARCHIVE"
		archive_set 'ARCHIVE_LIBSSL32' 'ARCHIVE_OPTIONAL_LIBSSL32'
		ARCHIVE="$ARCHIVE_MAIN"
	;;
	('arch'|'gentoo')
		# Both Arch Linux and Gentoo still have official libSSL 1.0.0 packages
	;;
	(*)
		liberror 'OPTION_PACKAGE' "$0"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Build 512×512 icon from the 1024×1024 provided one

PATH_ICON="${PATH_ICON_BASE}/512x512/apps"
mkdir --parents "${PKG_DATA_PATH}${PATH_ICON}"
convert "${PKG_DATA_PATH}${PATH_GAME}/${APP_MAIN_ICON}" -resize 512 "${PKG_DATA_PATH}${PATH_ICON}/${GAME_ID}.png"

# Include libSSL 1.0.0 (Debian packages only)

if [ "$ARCHIVE_LIBSSL32" ]; then
	ARCHIVE='ARCHIVE_LIBSSL32' \
		extract_data_from "$ARCHIVE_LIBSSL32"
	mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

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
