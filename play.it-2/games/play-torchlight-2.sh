#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Torchlight 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210507.3

# Set game-specific variables

GAME_ID='torchlight-2'
GAME_NAME='Torchlight Ⅱ'

ARCHIVE_BASE_GOG_0='gog_torchlight_2_2.0.0.2.sh'
ARCHIVE_BASE_GOG_0_MD5='e107f6d4c6d4cecea37ade420a8d4892'
ARCHIVE_BASE_GOG_0_TYPE='mojosetup'
ARCHIVE_BASE_GOG_0_SIZE='1700000'
ARCHIVE_BASE_GOG_0_VERSION='1.25.9.7-gog2.0.0.2'
ARCHIVE_BASE_GOG_0_URL='https://www.gog.com/game/torchlight_ii'

ARCHIVE_BASE_HUMBLE_0='Torchlight2-linux-2015-04-01.sh'
ARCHIVE_BASE_HUMBLE_0_MD5='730a5d08c8f1cd4a65afbc0ca631d85c'
ARCHIVE_BASE_HUMBLE_0_TYPE='mojosetup'
ARCHIVE_BASE_HUMBLE_0_SIZE='1700000'
ARCHIVE_BASE_HUMBLE_0_VERSION='1.25.2.4-humble150402'
ARCHIVE_BASE_HUMBLE_0_URL='https://www.humblebundle.com/store/torchlight-ii'

ARCHIVE_DOC0_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC0_DATA_PATH_HUMBLE='data/noarch'
ARCHIVE_DOC0_DATA_FILES='licenses'

ARCHIVE_DOC1_DATA_PATH_HUMBLE='data'
ARCHIVE_DOC1_DATA_FILES='EULA'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='data/x86'
ARCHIVE_GAME_BIN32_FILES='lib *.bin.x86'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='data/x86_64'
ARCHIVE_GAME_BIN64_FILES='lib64 *.bin.x86_64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='data/noarch'
ARCHIVE_GAME_DATA_FILES='*.bmp *.cfg *.png icons movies music PAKS porting programs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Torchlight2.bin.x86'
APP_MAIN_EXE_BIN64='Torchlight2.bin.x86_64'
APP_MAIN_ICON='Delvers.png'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc libstdc++ sdl2 freetype glx"
PKG_BIN32_DEPS_ARCH='lib32-bzip2 lib32-libxft'
PKG_BIN32_DEPS_DEB='libbz2-1.0, libxft2'
PKG_BIN32_DEPS_GENTOO='app-arch/bzip2[abi_x86_32] x11-libs/libXft[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='bzip2 libxft'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='app-arch/bzip2 x11-libs/libXft'

# Easier upgrade from packages generated with pre-20200212.2 scripts

PKG_DATA_PROVIDE='torchlight-2-media'

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

# Add execution bit on all binaries

chmod 755 "${PKG_BIN32_PATH}${PATH_GAME}"/*.bin.x86
chmod 755 "${PKG_BIN64_PATH}${PATH_GAME}"/*.bin.x86_64

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
