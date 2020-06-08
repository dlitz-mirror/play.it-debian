#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2020, Hoël Bézier
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
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200608.1

# Set game-specific variables

GAME_ID='the-count-lucanor'
GAME_NAME='The Count Lucanor'

ARCHIVE_GOG='the_count_lucanor_1_4_23_36418.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_count_lucanor'
ARCHIVE_GOG_MD5='59bdd0ee4d7525be7b5ba346ffefa5b9'
ARCHIVE_GOG_SIZE='760000'
ARCHIVE_GOG_VERSION='1.4.23-gog36418'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='the_count_lucanor_1_1_4_7_23841.sh'
ARCHIVE_GOG_OLD0_MD5='5a224a28d6e1a3b894e712db056fab07'
ARCHIVE_GOG_OLD0_SIZE='720000'
ARCHIVE_GOG_OLD0_VERSION='1.1.4.7-gog23841'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='lucanor.ico lib res'

CONFIG_DIRS='./res/settings'
DATA_DIRS='./logs ./res/level ./res/db'

APP_MAIN_TYPE='java'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='
if [ ! -e lib/libva.so.1 ]; then
	library_file="$(/sbin/ldconfig --print-cache | awk -F " => " '\''/libva\.so/ {print $2}'\'' | head --lines=1)"
	ln --force --symbolic "$library_file" lib/libva.so.1
fi
LD_LIBRARY_PATH="lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH
'
APP_MAIN_JAVA_OPTIONS='-Dfile.encoding=UTF-8 -Xmx1024m -Xms512m'
APP_MAIN_EXE='lib/build-desktop.jar'
APP_MAIN_ICON='lucanor.ico'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='java'
PKG_MAIN_DEPS_ARCH='' #TODO
PKG_MAIN_DEPS_DEB='libva2 | libva1'
PKG_MAIN_DEPS_GENTOO='' #TODO

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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon

icons_get_from_package 'APP_MAIN'

# Write launchers

launcher_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
