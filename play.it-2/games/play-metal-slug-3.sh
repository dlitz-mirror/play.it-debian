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
# Metal Slug 3
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190622.2

# Set game-specific variables

GAME_ID='metal-slug-3'
GAME_NAME='Metal Slug 3'

ARCHIVE_HUMBLE='MetalSlug3_jan2016.sh'
ARCHIVE_HUMBLE_MD5='a6854b31e7757f447c9c05281b28f57a'
ARCHIVE_HUMBLE_VERSION='1.0-humble1601'
ARCHIVE_HUMBLE_SIZE='110000'
ARCHIVE_HUMBLE_TYPE='mojosetup'

ARCHIVE_HUMBLE_OLD0='MetalSlug3-Linux-2014-06-09.sh'
ARCHIVE_HUMBLE_OLD0_MD5='a8a3aee4e3438d2d6d5bab23236e43a3'
ARCHIVE_HUMBLE_OLD0_VERSION='1.0-humble140609'
ARCHIVE_HUMBLE_OLD0_SIZE='83000'
ARCHIVE_HUMBLE_OLD0_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data/noarch'
ARCHIVE_DOC_DATA_FILES='ARPHICPL.TXT LICENSES.txt README.linux'

ARCHIVE_GAME_BIN32_PATH='data/x86'
ARCHIVE_GAME_BIN32_FILES='NeogeoEmu.bin.x86 lib/libRocketControls.so.1 lib/libRocketCore.so.1 lib/libRocketDebugger.so.1'

ARCHIVE_GAME_BIN64_PATH='data/x86_64'
ARCHIVE_GAME_BIN64_FILES='NeogeoEmu.bin.x86_64 lib64/libRocketControls.so.1 lib64/libRocketCore.so.1 lib64/libRocketDebugger.so.1'

ARCHIVE_GAME_DATA_PATH='data/noarch'
ARCHIVE_GAME_DATA_FILES='*'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='NeogeoEmu.bin.x86'
APP_MAIN_EXE_BIN64='NeogeoEmu.bin.x86_64'
APP_MAIN_ICON='MetalSlug3.png'
# Keep compatibility with old archives
APP_MAIN_EXE_BIN32_HUMBLE_OLD0='MetalSlug3.bin.x86'
APP_MAIN_EXE_BIN64_HUMBLE_OLD0='MetalSlug3.bin.x86_64'
APP_MAIN_ICON_HUMBLE_OLD0='icon.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ sdl2 glx alsa libudev1"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
