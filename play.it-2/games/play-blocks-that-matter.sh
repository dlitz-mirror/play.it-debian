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
# Blocks that matter
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181022.4

# Set game-specific variables

GAME_ID='blocks-that-matter'
GAME_NAME='Blocks that matter'

ARCHIVE_GOG='gog_blocks_that_matter_2.0.0.3.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/blocks_that_matter'
ARCHIVE_GOG_MD5='af9cec2b6104720c32718c02be120657'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.3'
ARCHIVE_GOG_SIZE='200000'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_DOC0_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC0_MAIN_FILES='*.txt'

ARCHIVE_DOC1_MAIN_PATH='data/noarch/game/README'
ARCHIVE_DOC1_MAIN_FILES='*'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='BTM.jar BTM_lib liblwjgl*.so libjinput-linux*.so BTM.png BTM.bftm config/DisplayOptions.xml config/KeyMapping.xml'

CONFIG_FILES='./config/*.xml'

APP_MAIN_TYPE='java'
APP_MAIN_LIBS='.'
APP_MAIN_EXE='BTM.jar'
# shellcheck disable=SC2016
APP_MAIN_JAVA_OPTIONS='-Djava.library.path="." -Dorg.lwjgl.librarypath="$PWD"'
APP_MAIN_ICON='BTM.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS="$PKG_DATA_ID xcursor libxrandr openal java"

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

write_launcher 'APP_MAIN'

# Build package

icons_linking_postinst 'APP_MAIN'
if [ "$OPTION_PACKAGE" = 'deb' ]; then
	cat >> "$postinst" <<- EOF
	if [ -e /usr/lib/i386-linux-gnu/libopenal.so.1 ]; then
	    ln --force --symbolic /usr/lib/i386-linux-gnu/libopenal.so.1 "$PATH_GAME/libopenal.so"
	fi
	if [ -e /usr/lib/x86_64-linux-gnu/libopenal.so.1 ]; then
	    ln --force --symbolic /usr/lib/x86_64-linux-gnu/libopenal.so.1 "$PATH_GAME/libopenal64.so"
	fi
	EOF
	cat >> "$prerm" <<- EOF
	rm --force "$PATH_GAME/libopenal.so"
	rm --force "$PATH_GAME/libopenal64.so"
	EOF
fi
write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
