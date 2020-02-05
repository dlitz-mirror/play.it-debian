#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2020-2021, Hoël Bézier
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
# The Count Lucanor
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210529.1

# Set game-specific variables

GAME_ID='the-count-lucanor'
GAME_NAME='The Count Lucanor'

ARCHIVE_BASE_1='the_count_lucanor_1_4_23_36418.sh'
ARCHIVE_BASE_1_MD5='59bdd0ee4d7525be7b5ba346ffefa5b9'
ARCHIVE_BASE_1_TYPE='mojosetup'
ARCHIVE_BASE_1_SIZE='760000'
ARCHIVE_BASE_1_VERSION='1.4.23-gog36418'
ARCHIVE_BASE_1_URL='https://www.gog.com/game/the_count_lucanor'

ARCHIVE_BASE_0='the_count_lucanor_1_1_4_7_23841.sh'
ARCHIVE_BASE_0_MD5='5a224a28d6e1a3b894e712db056fab07'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='720000'
ARCHIVE_BASE_0_VERSION='1.1.4.7-gog23841'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='lucanor.ico lib res'

CONFIG_DIRS='./res/settings'
DATA_DIRS='./logs ./res/level ./res/db'

APP_MAIN_TYPE='java'
APP_MAIN_JAVA_OPTIONS='-Dfile.encoding=UTF-8 -Xmx1024m -Xms512m'
APP_MAIN_EXE='lib/build-desktop.jar'
APP_MAIN_LIBS='lib'
APP_MAIN_ICON='lucanor.ico'

PKG_MAIN_DEPS='java'

# Ensure the game finds the libva.so.1 library it depends on

PKG_MAIN_DEPS_ARCH="${PKG_MAIN_DEPS_ARCH} libva1"
PKG_MAIN_DEPS_GENTOO="${PKG_MAIN_DEPS_ARCH} x11-libs/libva"
if [ -n "$PKG_MAIN_DEPS_DEB" ]; then
	PKG_MAIN_DEPS_DEB="${PKG_MAIN_DEPS_DEB}, libva2 | libva1"
else
	PKG_MAIN_DEPS_DEB='libva2 | libva1'
fi
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Ensure the game finds the libva.so.1 library it depends on
if [ ! -e "${APP_LIBS:=libs}/libva.so.1" ]; then
	library_file=$(/sbin/ldconfig --print-cache | awk -F " => " '\''/libva\.so/ {print $2}'\'' | head --lines=1)
	ln --force --symbolic "$library_file" "${APP_LIBS}/libva.so.1"
fi'

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

icons_get_from_package 'APP_MAIN'

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
