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
# Myst: Masterpiece Edition
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190428.1

# Set game-specific variables

GAME_ID='myst-1'
GAME_NAME='Myst: Masterpiece Edition'

ARCHIVE_GOG='setup_myst_masterpiece_edition_1.0_svm_update_4_(22598).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/myst_masterpiece_edition'
ARCHIVE_GOG_MD5='e3c62eeb19abd2c9a947aee8300e995d'
ARCHIVE_GOG_SIZE='1500000'
ARCHIVE_GOG_VERSION='1.0.4-gog22598'
ARCHIVE_GOG_TYPE='innosetup1.7'
ARCHIVE_GOG_PART1='setup_myst_masterpiece_edition_1.0_svm_update_4_(22598)-1.bin'
ARCHIVE_GOG_PART1_MD5='4b84a68ec57e55bcc9b522c6333c669c'
ARCHIVE_GOG_PART1_TYPE='innosetup1.7'

ARCHIVE_GOG_OLD0='setup_myst_masterpiece_2.0.0.22.exe'
ARCHIVE_GOG_OLD0_MD5='e7a979dc6ca044eaec2984877ac032c5'
ARCHIVE_GOG_OLD0_SIZE='620000'
ARCHIVE_GOG_OLD0_VERSION='1.0-gog2.0.0.22'
ARCHIVE_GOG_OLD0_TYPE='innosetup'

ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='manual.pdf readme.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_MAIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='channel.dat credits.dat dunny.dat help.dat intro.dat mechan.dat menu.dat myst.dat selen.dat stone.dat qtw'
# Keep compatibility with old archives
ARCHIVE_GAME_MAIN_PATH_GOG_OLD0='app'

APP_MAIN_TYPE='scummvm'
APP_MAIN_SCUMMID='myst'
APP_MAIN_ICON='app/goggame-1207658818.ico'
# Keep compatibility with old archives
APP_MAIN_ICON_GOG_OLD0='app/myst.exe'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='scummvm'

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
