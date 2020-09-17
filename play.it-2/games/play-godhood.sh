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
# Godhoob
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200819.5

# Set game-specific variables

GAME_ID='godhood'
GAME_NAME='Godhood'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='godhood_1_0_5_40453.sh'
ARCHIVE_GOG_0_MD5='6e0b1ddd1b9575b2c7d1f61ca2d57681'
ARCHIVE_GOG_0_TYPE='mojosetup'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/godhood'
ARCHIVE_GOG_0_SIZE='900000'
ARCHIVE_GOG_0_VERSION='1.0.5-gog40453'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='godhood libc++abi.so.1  libc++.so.1'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='*.bni data i18n'

CONFIG_DIRS='./userdata/Godhood/userdata'
DATA_DIRS='./userdata/Godhood/savedata'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='godhood'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx glu xcursor sdl2 libxrandr"
PKG_BIN_DEPS_ARCH='libx11'
PKG_BIN_DEPS_DEB='libx11-6'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11'

# Create required directory for saved games

APP_MAIN_PRERUN='# Create required directory for saved games
mkdir --parents userdata/Godhood/savedata/Player'

# Load common functions

target_version='2.12'

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

# Ensure availability of libcurl.so.4 providing CURL_OPENSSL_3 symbol

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
			message='Lʼarchive suivante nʼayant pas été fournie, libcurl.so.4.5.0 ne sera pas inclus dans les paquets : %s\n'
			message="$message"'Cette archive peut être téléchargée depuis %s\n'
		;;
		('en'|*)
			message='Due to the following archive missing, the packages will not include libcurl.so.4.5.0: %s\n'
			message="$message"'This archive can be downloaded from %s\n'
		;;
	esac
	print_warning
	printf "$message" "$ARCHIVE_OPTIONAL_LIBCURL3" "$ARCHIVE_OPTIONAL_LIBCURL3_URL"
	printf '\n'
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launcher

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
