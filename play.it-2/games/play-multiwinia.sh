#!/bin/sh -e
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
# Multiwinia
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190210.3

# Set game-specific variables

GAME_ID='multiwinia'
GAME_NAME='Multiwinia'

ARCHIVE_GOG='gog_multiwinia_2.0.0.5.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/multiwinia'
ARCHIVE_GOG_MD5='ec7f0cc245b4fb4bf85cba5fc4a536ba'
ARCHIVE_GOG_VERSION='1.3.1-gog2.0.0.5'
ARCHIVE_GOG_SIZE='66000'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_OPTIONAL_LIBPNG32='libpng_1.2_32-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBPNG32_URL='https://www.dotslashplay.it/ressources/libpng/'
ARCHIVE_OPTIONAL_LIBPNG32_MD5='15156525b3c6040571f320514a0caa80'

ARCHIVE_OPTIONAL_LIBPNG64='libpng_1.2_64-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBPNG64_URL='https://www.dotslashplay.it/ressources/libpng/'
ARCHIVE_OPTIONAL_LIBPNG64_MD5='c7d675c8df2aac9bcb8132b501a10439'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game/docs'
ARCHIVE_DOC1_DATA_FILES='readme.txt manual.pdf'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='multiwinia.bin.x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='multiwinia.bin.x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='*.dat multiwinia.png'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='multiwinia.bin.x86'
APP_MAIN_EXE_BIN64='multiwinia.bin.x86_64'
APP_MAIN_ICON='multiwinia.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID sdl1.2 glx glu openal vorbis glibc libstdc++"
PKG_BIN32_DEPS_ARCH='lib32-libpng12 lib32-libogg'
PKG_BIN32_DEPS_GENTOO='media-libs/libpng:1.2[abi_x86_32] media-libs/libogg[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libpng12 libogg'
PKG_BIN64_DEPS_GENTOO='media-libs/libpng:1.2 media-libs/libogg'

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

# Use libpng 1.2 archives for systems no longer providing it

case "$OPTION_PACKAGE" in
	('deb')
		ARCHIVE_MAIN="$ARCHIVE"
		set_archive 'ARCHIVE_LIBPNG32' 'ARCHIVE_OPTIONAL_LIBPNG32'
		set_archive 'ARCHIVE_LIBPNG64' 'ARCHIVE_OPTIONAL_LIBPNG64'
		ARCHIVE="$ARCHIVE_MAIN"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include libpng 1.2

if [ "$ARCHIVE_LIBPNG32" ]; then
	(
		ARCHIVE='ARCHIVE_LIBPNG32'
		extract_data_from "$ARCHIVE_LIBPNG32"
	)
	mkdir --parents "${PKG_BIN32_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
	mv "$PLAYIT_WORKDIR/gamedata/libpng12.so.0.50.0" "${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	ln --symbolic './libpng12.so.0.50.0' "${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_LIBS/libpng12.so.0"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi
if [ "$ARCHIVE_LIBPNG64" ]; then
	(
		ARCHIVE='ARCHIVE_LIBPNG64'
		extract_data_from "$ARCHIVE_LIBPNG64"
	)
	mkdir --parents "${PKG_BIN64_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
	mv "$PLAYIT_WORKDIR/gamedata/libpng12.so.0.50.0" "${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	ln --symbolic './libpng12.so.0.50.0' "${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_LIBS/libpng12.so.0"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launcher_write 'APP_MAIN'
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
