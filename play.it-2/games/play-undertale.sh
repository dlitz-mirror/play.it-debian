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
# Undertale
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200328.2

# Set game-specific variables

GAME_ID='undertale'
GAME_NAME='Undertale'

ARCHIVE_GOG='undertale_en_1_08_18328.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/undertale'
ARCHIVE_GOG_MD5='b134d85dd8bf723a74498336894ca723'
ARCHIVE_GOG_SIZE='160000'
ARCHIVE_GOG_VERSION='1.08-gog18328'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='undertale_en_1_06_15928.sh'
ARCHIVE_GOG_OLD1_MD5='54f9275d3def027e9f3f65a61094a662'
ARCHIVE_GOG_OLD1_SIZE='160000'
ARCHIVE_GOG_OLD1_VERSION='1.06-gog15928'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_undertale_2.0.0.1.sh'
ARCHIVE_GOG_OLD0_MD5='e740df4e15974ad8c21f45ebe8426fb0'
ARCHIVE_GOG_OLD0_SIZE='160000'
ARCHIVE_GOG_OLD0_VERSION='1.001-gog2.0.0.1'

ARCHIVE_DOC_PATH='data/noarch/docs'
ARCHIVE_DOC_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='runner'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_FILES_OLD1='UNDERTALE'
ARCHIVE_GAME_BIN_FILES_OLD0='UNDERTALE'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='assets'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='runner'
APP_MAIN_ICON='assets/icon.png'
# Keep compatibility with old archives
APP_MAIN_EXE_OLD1='UNDERTALE'
APP_MAIN_EXE_OLD0='UNDERTALE'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx openal libxrandr glu"
PKG_BIN_DEPS_ARCH='lib32-libxext lib32-libx11'
PKG_BIN_DEPS_DEB='libxext6, libx11-6'
PKG_BIN_DEPS_GENTOO='x11-libs/libXext[abi_x86_32] x11-libs/libX11[abi_x86_32]'

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

# Ensure availability of 32-bit libssl.so.1.0.0

case "$OPTION_PACKAGE" in
	('arch')
		# Use package from official repositories
		PKG_BIN_DEPS_ARCH="$PKG_BIN_DEPS_ARCH lib32-openssl-1.0"
	;;
	('deb')
		# Use archive provided by ./play.it
		ARCHIVE_OPTIONAL_LIBSSL32='libssl_1.0.0_32-bit.tar.gz'
		ARCHIVE_OPTIONAL_LIBSSL32_URL='https://www.dotslashplay.it/ressources/libssl/'
		ARCHIVE_OPTIONAL_LIBSSL32_MD5='9443cad4a640b2512920495eaf7582c4'
		ARCHIVE_MAIN="$ARCHIVE"
		set_archive 'ARCHIVE_LIBSSL32' 'ARCHIVE_OPTIONAL_LIBSSL32'
		ARCHIVE="$ARCHIVE_MAIN"
		if [ "$ARCHIVE_LIBSSL32" ]; then
			ARCHIVE='ARCHIVE_LIBSSL32' \
				extract_data_from "$ARCHIVE_LIBSSL32"
			mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
			mv "$PLAYIT_WORKDIR"/gamedata/* "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
			rm --recursive "$PLAYIT_WORKDIR/gamedata"
		fi
	;;
	('gentoo')
		# Use package from official repositories
		PKG_BIN_DEPS_GENTOO="$PKG_BIN_DEPS_GENTOO dev-libs/openssl-compat[abi_x86_32]"
	;;
	(*)
		# Unsupported package type, throw an error
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
