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
# Reassembly
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200716.5

# Set game-specific variables

GAME_ID='reassembly'
GAME_NAME='Reassembly'

ARCHIVES_LIST='
ARCHIVE_GOG_0
ARCHIVE_HUMBLE_0
'

ARCHIVE_GOG_0='reassembly_2019_4_04_28550.sh'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/reassembly'
ARCHIVE_GOG_0_MD5='640cc7849af45fb221f349b9d901b9ab'
ARCHIVE_GOG_0_VERSION='20190330-gog28550'
ARCHIVE_GOG_0_SIZE='120000'
ARCHIVE_GOG_0_TYPE='mojosetup'

ARCHIVE_HUMBLE_0='anisopteragames_Reassembly_2019_04_11.tar.gz'
ARCHIVE_HUMBLE_0_MD5='ae516da186f0a2c6799eb8059a51337d'
ARCHIVE_HUMBLE_0_URL='https://www.humblebundle.com/store/reassembly'
ARCHIVE_HUMBLE_0_VERSION='20190330-humble1'
ARCHIVE_HUMBLE_0_SIZE='120000'

ARCHIVE_DOC_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC_DATA_PATH_HUMBLE='Reassembly'
ARCHIVE_DOC_DATA_FILES='*.txt'

# gog.com archive only
ARCHIVE_DOC0_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES_GOG='*.txt'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='Reassembly'
ARCHIVE_GAME_BIN_FILES='linux/ReassemblyRelease64 linux/linux64/libGLEW.so.1.13'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='Reassembly'
ARCHIVE_GAME_DATA_FILES='data linux/reassembly_icon.png'

ARCHIVE_FONTS_PATH_GOG='data/noarch/game/data'
ARCHIVE_FONTS_PATH_HUMBLE='Reassembly/data'
ARCHIVE_FONTS_FILES='*.ttf'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='linux/linux64'
APP_MAIN_EXE='linux/ReassemblyRelease64'
APP_MAIN_ICON='linux/reassembly_icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx sdl2 sdl2_image openal vorbis libcurl"
PKG_BIN_DEPS_DEB='libsdl2-ttf-2.0-0, zlib1g'
PKG_BIN_DEPS_ARCH='sdl2_ttf zlib'
PKG_BIN_DEPS_GENTOO='media-libs/sdl2-ttf sys-libs/zlib'

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

# Include a 64-bit build of libcurl.so.3/libcurl.so.4 including CURL_OPENSSL_3 symbol

ARCHIVE_OPTIONAL_LIBCURL3='libcurl3_7.52.1_64-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBCURL3_URL='https://downloads.dotslashplay.it/resources/libcurl/'
ARCHIVE_OPTIONAL_LIBCURL3_MD5='e276dd3620c31617baace84dfa3dca21'
ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_LIBCURL3' 'ARCHIVE_OPTIONAL_LIBCURL3'
if [ "$ARCHIVE_LIBCURL3" ]; then
	extract_data_from "$ARCHIVE_LIBCURL3"
	mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
	mv "$PLAYIT_WORKDIR"/gamedata/* "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
else
	case "${LANG%_*}" in
		('fr')
			message='Lʼarchive suivante nʼayant pas été fournie, %s ne sera pas inclus dans les paquets : %s\n'
			message="$message"'Cette archive peut être téléchargée depuis %s\n'
		;;
		('en'|*)
			message='Due to the following archive missing, the packages will not include %s: %s\n'
			message="$message"'This archive can be downloaded from %s\n'
		;;
	esac
	print_warning
	printf "$message" 'libcurl.so.4.4.0' "$ARCHIVE_OPTIONAL_LIBCURL3" "$ARCHIVE_OPTIONAL_LIBCURL3_URL"
	printf '\n'
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

# Get shipped fonts

PKG='PKG_DATA'
PATH_FONTS="$OPTION_PREFIX/share/fonts/truetype/$GAME_ID"
organize_data 'FONTS' "$PATH_FONTS"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Link required fonts where the game engine expects to find them
ln --force --symbolic "'"$PATH_FONTS"'"/*.ttf "$PATH_PREFIX/data"'

# Get game data

prepare_package_layout

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
