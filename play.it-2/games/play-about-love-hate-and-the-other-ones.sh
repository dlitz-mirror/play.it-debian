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
# About Love, Hate and the Other Ones
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190602.1

# Set game-specific variables

GAME_ID='about-love-hate-and-the-other-ones'
GAME_NAME='About Love, Hate and the Other Ones'

ARCHIVE_HUMBLE='aboutloveandhate-1.3.1.deb'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/about-love-hate-and-the-other-ones'
ARCHIVE_HUMBLE_MD5='65c314a2a970b5c787d4e7e2a837e211'
ARCHIVE_HUMBLE_SIZE='570000'
ARCHIVE_HUMBLE_VERSION='1.3.1-humble150312'

ARCHIVE_DOC_DATA_PATH='usr/local/games/loveandhate'
ARCHIVE_DOC_DATA_FILES='README'

ARCHIVE_GAME_BIN32_PATH='usr/local/games/loveandhate/bin32'
ARCHIVE_GAME_BIN32_FILES='loveandhate'

ARCHIVE_GAME_BIN64_PATH='usr/local/games/loveandhate/bin64'
ARCHIVE_GAME_BIN64_FILES='loveandhate'

ARCHIVE_GAME_DATA_PATH='usr/local/games/loveandhate'
ARCHIVE_GAME_DATA_FILES='bin'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='loveandhate'
APP_MAIN_EXE_BIN64='loveandhate'
APP_MAIN_ICONS_LIST=''
for icon_resolution in '16' '24' '32' '48' '64' '128' '256'; do
	export APP_MAIN_ICON_${icon_resolution}="usr/share/icons/hicolor/${icon_resolution}x${icon_resolution}/apps/loveandhate.png"
	APP_MAIN_ICONS_LIST="$APP_MAIN_ICONS_LIST APP_MAIN_ICON_${icon_resolution}"
done

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc glx openal sdl2"
PKG_BIN32_DEPS_ARCH='lib32-libx11'
PKG_BIN32_DEPS_DEB='libx11-6'
PKG_BIN32_DEPS_GENTOO='x11-libs/libX11[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libx11'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/libX11'

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
prepare_package_layout

# Get icons

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
