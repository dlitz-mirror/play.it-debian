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
# Planescape Torment - Enhanced Edition
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190721.3

# Set game-specific variables

GAME_ID='planescape-torment-enhanced-edition'
GAME_NAME='Planescape Torment - Enhanced Edition'

ARCHIVE_GOG='planescape_torment_enhanced_edition_3_1_4_26532.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/planescape_torment_enhanced_edition'
ARCHIVE_GOG_MD5='7d42ae99df8c0a4ff460235ae406f2d6'
ARCHIVE_GOG_SIZE='1800000'
ARCHIVE_GOG_VERSION='3.1.4-gog26532'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_planescape_torment_enhanced_edition_2.1.0.3.sh'
ARCHIVE_GOG_OLD0_MD5='649c1bf9d7ccd81553c574ff1bec2cef'
ARCHIVE_GOG_OLD0_SIZE='1800000'
ARCHIVE_GOG_OLD0_VERSION='3.1.3-gog2.1.0.3'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_OPTIONAL_LIBSSL32='libssl_1.0.0_32-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBSSL32_MD5='9443cad4a640b2512920495eaf7582c4'

ARCHIVE_OPTIONAL_LIBSSL64='libssl_1.0.0_64-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBSSL64_MD5='89917bef5dd34a2865cb63c2287e0bd4'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='Torment'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='Torment64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Torment.pdb music lang engine.lua data chitin.key'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Torment'
APP_MAIN_EXE_BIN64='Torment64'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ openal glx libxrandr alsa xcursor"
PKG_BIN32_DEPS_ARCH='lib32-openssl-1.0 lib32-expat lib32-libx11'
PKG_BIN32_DEPS_DEB='libexpat1, libx11-6'
PKG_BIN32_DEPS_GENTOO='dev-libs/expat[abi_x86_32] x11-libs/libX11[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='openssl-1.0 expat libx11'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='dev-libs/expat x11-libs/libX11'

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

# Use libSSL 1.0.0 archives

case "$OPTION_PACKAGE" in
	('arch') ;;
	(*)
		ARCHIVE_MAIN="$ARCHIVE"
		set_archive 'ARCHIVE_LIBSSL32' 'ARCHIVE_OPTIONAL_LIBSSL32'
		set_archive 'ARCHIVE_LIBSSL64' 'ARCHIVE_OPTIONAL_LIBSSL64'
		ARCHIVE="$ARCHIVE_MAIN"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icons

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include libSSL into the game directory

if [ -n "$ARCHIVE_LIBSSL32" ]; then
	(
		ARCHIVE='ARCHIVE_LIBSSL32'
		extract_data_from "$ARCHIVE_LIBSSL32"
	)
	mkdir --parents "${PKG_BIN32_PATH}${PATH_GAME}/${APP_MAIN_LIBS_BIN32:=libs}"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_LIBS_BIN32"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi
if [ -n "$ARCHIVE_LIBSSL64" ]; then
	(
		ARCHIVE='ARCHIVE_LIBSSL64'
		extract_data_from "$ARCHIVE_LIBSSL64"
	)
	mkdir --parents "${PKG_BIN64_PATH}${PATH_GAME}/${APP_MAIN_LIBS_BIN64:=libs}"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_LIBS_BIN64"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

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
