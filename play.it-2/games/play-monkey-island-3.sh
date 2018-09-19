#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, Solène Huault
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
# Monkey Island 3: The Curse of Monkey Island
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180919.3

# Set game-specific variables

SCRIPT_DEPS='icotool'

GAME_ID='monkey-island-3'
GAME_NAME='Monkey Island 3: The Curse of Monkey Island'

ARCHIVE_GOG='setup_the_curse_of_monkey_islandtm_1.0l_(20628).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_curse_of_monkey_island'
ARCHIVE_GOG_MD5='fcd4a7cd9c0304c15a0a059f6eb299e8'
ARCHIVE_GOG_SIZE='1200000'
ARCHIVE_GOG_VERSION='1.0l-gog20628'
ARCHIVE_GOG_TYPE='innosetup1.7'
ARCHIVE_GOG_PART1='setup_the_curse_of_monkey_islandtm_1.0l_(20628)-1.bin'
ARCHIVE_GOG_PART1_MD5='931e6e35fdc7e0a14f2559984620f8f3'
ARCHIVE_GOG_PART1_TYPE='innosetup1.7'

ARCHIVE_GOG_OLD0='setup_the_curse_of_monkey_island_1.0_(18253).exe'
ARCHIVE_GOG_OLD0_MD5='20c74e5f60bd724182ec2bdbae6d9a49'
ARCHIVE_GOG_OLD0_SIZE='1200000'
ARCHIVE_GOG_OLD0_VERSION='1.0-gog18253'
ARCHIVE_GOG_OLD0_TYPE='innosetup'

ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='*.pdf'
# Keep compatibility with old archives
ARCHIVE_DOC_MAIN_PATH_OLD0='app'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='comi.la? resource'
# Keep compatibility with old archives
ARCHIVE_GAME_MAIN_PATH_OLD0='app'

APP_MAIN_TYPE='scummvm'
APP_MAIN_SCUMMID='comi'
APP_MAIN_ICON='app/goggame-1528148981.ico'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='scummvm'

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	: ${XDG_DATA_HOME:="$HOME/.local/share"}
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
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Work around "insufficient image data" issue with convert from imagemagick
icon_extract_png_from_ico() {
	[ "$DRY_RUN" = '1' ] && return 0
	icotool --extract --output="$2" "$1" 2>/dev/null
}

# Extract icons

icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
