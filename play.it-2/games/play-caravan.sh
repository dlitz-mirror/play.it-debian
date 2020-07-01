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
# Caravan
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200619.2

# Set game-specific variables

GAME_ID='caravan'
GAME_NAME='Caravan'

ARCHIVES_LIST='
ARCHIVE_HUMBLE_0
'

ARCHIVE_HUMBLE_0='caravan_linux_v1.1.17513.zip'
ARCHIVE_HUMBLE_0_URL='https://www.humblebundle.com/store/caravan'
ARCHIVE_HUMBLE_0_MD5='286f762190d74e27c353b5616b9e6dee'
ARCHIVE_HUMBLE_0_SIZE='600000'
ARCHIVE_HUMBLE_0_VERSION='1.1.17513-humble1'
ARCHIVE_HUMBLE_0_TYPE='zip_unclean'

ARCHIVE_GAME_BIN32_PATH='Caravan'
ARCHIVE_GAME_BIN32_FILES='Caravan.x86 Caravan_Data/Mono/x86 Caravan_Data/Plugins/x86'

ARCHIVE_GAME_BIN64_PATH='Caravan'
ARCHIVE_GAME_BIN64_FILES='Caravan.x86_64 Caravan_Data/Mono/x86_64 Caravan_Data/Plugins/x86_64'

ARCHIVE_GAME_DATA_PATH='Caravan'
ARCHIVE_GAME_DATA_FILES='Caravan_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Caravan.x86'
APP_MAIN_EXE_BIN64='Caravan.x86_64'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='Caravan_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glu glx xcursor libxrandr gtk2"
PKG_BIN32_DEPS_ARCH='lib32-libx11 lib32-gdk-pixbuf2 lib32-glib2'
PKG_BIN32_DEPS_DEB='libx11-6, libgdk-pixbuf2.0-0, libglib2.0-0'
PKG_BIN32_DEPS_GENTOO='x11-libs/libX11[abi_x86_32] x11-libs/gdk-pixbuf[abi_x86_32] dev-libs/glib[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libx11 gdk-pixbuf2 glib2'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/libX11 x11-libs/gdk-pixbuf dev-libs/glib'

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
(
	ARCHIVE='ARCHIVE_INNER'
	ARCHIVE_INNER="$PLAYIT_WORKDIR/gamedata/Caravan_1.1.17513_Full_DEB_Multi_Daedalic_ESD.tar.gz"
	ARCHIVE_INNER_TYPE='tar.gz'
	extract_data_from "$ARCHIVE_INNER"
	rm "$ARCHIVE_INNER"
)
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
