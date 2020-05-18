#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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
# Don’t Starve
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190706.1

# Set game-specific variables

GAME_ID='dont-starve'
GAME_NAME='Donʼt Starve'

ARCHIVES_LIST='ARCHIVE_GOG ARCHIVE_GOG_MULTIARCH_OLD2 ARCHIVE_GOG_MULTIARCH_OLD1 ARCHIVE_GOG_MULTIARCH_OLD0'

ARCHIVE_GOG='don_t_starve_en_222215_22450.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/dont_starve'
ARCHIVE_GOG_MD5='611cd70afd9b9feb3aca4d1eaf9ebbda'
ARCHIVE_GOG_TYPE='mojosetup'
ARCHIVE_GOG_SIZE='760000'
ARCHIVE_GOG_VERSION='276758-gog22450'

ARCHIVE_GOG_MULTIARCH_OLD2='don_t_starve_en_20171215_17629.sh'
ARCHIVE_GOG_MULTIARCH_OLD2_MD5='f7dda3b3bdb15ac62acb212a89b24623'
ARCHIVE_GOG_MULTIARCH_OLD2_TYPE='mojosetup'
ARCHIVE_GOG_MULTIARCH_OLD2_SIZE='670000'
ARCHIVE_GOG_MULTIARCH_OLD2_VERSION='246924-gog17629'

ARCHIVE_GOG_MULTIARCH_OLD1='gog_don_t_starve_2.7.0.9.sh'
ARCHIVE_GOG_MULTIARCH_OLD1_MD5='01d7496de1c5a28ffc82172e89dd9cd6'
ARCHIVE_GOG_MULTIARCH_OLD1_SIZE='660000'
ARCHIVE_GOG_MULTIARCH_OLD1_VERSION='222215-gog2.7.0.9'

ARCHIVE_GOG_MULTIARCH_OLD0='gog_don_t_starve_2.6.0.8.sh'
ARCHIVE_GOG_MULTIARCH_OLD0_MD5='2b0d363bea53654c0267ae424de7130a'
ARCHIVE_GOG_MULTIARCH_OLD0_SIZE='650000'
ARCHIVE_GOG_MULTIARCH_OLD0_VERSION='198251-gog2.6.0.8'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game/dontstarve32'
ARCHIVE_GAME_BIN32_FILES='*.json bin/dontstarve bin/lib32/libfmodevent.so bin/lib32/libfmodevent-4.44.07.so bin/lib32/libfmodex.so bin/lib32/libfmodex-4.44.07.so bin/lib32/libSDL2*'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game/dontstarve64'
ARCHIVE_GAME_BIN64_FILES='*.json bin/dontstarve bin/lib64/libfmodevent64.so bin/lib64/libfmodevent64-4.44.07.so bin/lib64/libfmodex64.so bin/lib64/libfmodex64-4.44.07.so bin/lib64/libSDL2*'

ARCHIVE_GAME_DATA_PATH='data/noarch/game/dontstarve64'
ARCHIVE_GAME_DATA_FILES='data mods dontstarve.xpm'

DATA_DIRS='./mods'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='bin/dontstarve'
APP_MAIN_ICON='dontstarve.xpm'

PACKAGES_LIST='PKG_BIN64 PKG_DATA'
# Keep compatibility with old archives
PACKAGES_LIST_GOG_MULTIARCH='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_DATA_ID glibc libstdc++ libcurl-gnutls glx sdl2"

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_BIN64_DEPS"

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

# Update list of packages to build, based on source archive

use_archive_specific_value 'PACKAGES_LIST'
# shellcheck disable=SC2086
set_temp_directories $PACKAGES_LIST

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get icon

PKG='PKG_DATA'
# Work around icon_extract_png_from_file not supporting .xpm files yet
if [ $DRY_RUN -eq 0 ]; then
	ln --symbolic "$APP_MAIN_ICON" "${PKG_DATA_PATH}${PATH_GAME}/${APP_MAIN_ICON%.xpm}.bmp"
fi
APP_MAIN_ICON="${APP_MAIN_ICON%.xpm}.bmp" icons_get_from_package 'APP_MAIN'
rm --force "${PKG_DATA_PATH}${PATH_GAME}/${APP_MAIN_ICON%.xpm}.bmp"

# Write launchers

PKG='PKG_BIN64'
launchers_write 'APP_MAIN'
if [ -n "$PKG_BIN32_PATH" ] && [ -d "$PKG_BIN32_PATH" ]; then
	PKG='PKG_BIN32'
	launchers_write 'APP_MAIN'
fi

# Set working directory to the directory containing the game binary before running it

# shellcheck disable=SC2016
pattern='s|^cd "$PATH_PREFIX"$|cd "$PATH_PREFIX/${APP_EXE%/*}"|'
# shellcheck disable=SC2016
pattern="$pattern"';s|^"\./$APP_EXE"|"./${APP_EXE##*/}"|'
file="${PKG_BIN64_PATH}${PATH_BIN}/$GAME_ID"
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place "$pattern" "$file"
fi
if [ -n "$PKG_BIN32_PATH" ] && [ -d "$PKG_BIN32_PATH" ]; then
	file="${PKG_BIN32_PATH}${PATH_BIN}/$GAME_ID"
	if [ $DRY_RUN -eq 0 ]; then
		sed --in-place "$pattern" "$file"
	fi
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
