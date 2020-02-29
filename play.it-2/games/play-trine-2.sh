#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Trine 2
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190704.1

# Set game-specific variables

GAME_ID='trine-2'
GAME_NAME='Trine 2'

ARCHIVE_GOG='gog_trine_2_complete_story_2.0.0.5.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/trine_2_complete_story'
ARCHIVE_GOG_MD5='dd7126c1a6210e56fde20876bdb0a2ac'
ARCHIVE_GOG_VERSION='2.01.425-gog2.0.0.5'
ARCHIVE_GOG_SIZE='3700000'

ARCHIVE_GOG_OLD0='gog_trine_2_complete_story_2.0.0.4.sh'
ARCHIVE_GOG_OLD0_MD5='dae867bff938dde002eafcce0b72e5b4'
ARCHIVE_GOG_OLD0_VERSION='2.01.425-gog2.0.0.4'
ARCHIVE_GOG_OLD0_SIZE='3700000'

ARCHIVE_HUMBLE='trine2_complete_story_v2_01_build_425_humble_linux_full.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/trine-2-complete-story'
ARCHIVE_HUMBLE_MD5='82049b65c1bce6841335935bc05139c8'
ARCHIVE_HUMBLE_VERSION='2.01build425-humble141016'
ARCHIVE_HUMBLE_SIZE='3700000'

ARCHIVE_OPTIONAL_LIBPNG32='libpng_1.2_32-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBPNG32_URL='https://www.dotslashplay.it/ressources/libpng/'
ARCHIVE_OPTIONAL_LIBPNG32_MD5='15156525b3c6040571f320514a0caa80'

ARCHIVE_DOC0_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC1_DATA_PATH_HUMBLE='.'
ARCHIVE_DOC1_DATA_FILES='readme*'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='.'
ARCHIVE_GAME_BIN_FILES='bin lib'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='.'
ARCHIVE_GAME_DATA_FILES='data *.fbq trine2.png'

DATA_DIRS='./log'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='lib/lib32'
APP_MAIN_EXE='bin/trine2_linux_launcher_32bit'
APP_MAIN_ICON='trine2.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc glu openal gtk2 vorbis alsa"
PKG_BIN_DEPS_ARCH='lib32-libpng12'
PKG_BIN_DEPS_GENTOO='media-libs/libpng:1.2[abi_x86_32]'

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

# Use libpng 1.2 archive for systems no longer providing it

case "$OPTION_PACKAGE" in
	('deb')
		ARCHIVE_MAIN="$ARCHIVE"
		set_archive 'ARCHIVE_LIBPNG32' 'ARCHIVE_OPTIONAL_LIBPNG32'
		ARCHIVE="$ARCHIVE_MAIN"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Set execution permissions on all binaries

if [ $DRY_RUN -eq 0 ]; then
	find "${PKG_BIN_PATH}${PATH_GAME}/bin" -type f -exec chmod 755 '{}' +
fi

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Include libpng 1.2

if [ "$ARCHIVE_LIBPNG32" ]; then
	(
		ARCHIVE='ARCHIVE_LIBPNG32'
		extract_data_from "$ARCHIVE_LIBPNG32"
	)
	mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
	mv "$PLAYIT_WORKDIR/gamedata/libpng12.so.0.50.0" "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	ln --symbolic './libpng12.so.0.50.0' "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS/libpng12.so.0"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
