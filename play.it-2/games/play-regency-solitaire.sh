#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2017-2018, Solène Huault
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
# Regency Solitaire
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181024.2

# Set game-specific variables

GAME_ID='regency-solitaire'
GAME_NAME='Regency Solitaire'

ARCHIVE_HUMBLE='RegencySolitaireV117b_1472495785.tar.gz'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/regency-solitaire'
ARCHIVE_HUMBLE_MD5='15e8377d2cac99a52407cb399bd1ee7c'
ARCHIVE_HUMBLE_SIZE='71000'
ARCHIVE_HUMBLE_VERSION='1.17b-humble160829'

ARCHIVE_OPTIONAL_ICONS='regency-solitaire_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_URL='https://www.dotslashplay.it/ressources/regency-solitaire/'
ARCHIVE_OPTIONAL_ICONS_MD5='01a7c7b168e2cb315d2058ff5e6a53aa'

ARCHIVE_GAME_BIN_PATH='RegencySolitaireV117b'
ARCHIVE_GAME_BIN_FILES='RegencySolitaire'

ARCHIVE_GAME_DATA_PATH='RegencySolitaireV117b'
ARCHIVE_GAME_DATA_FILES='data'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 32x32 48x48 256x256'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='RegencySolitaire'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glu"

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

# Try to load icons archive

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get icons

if [ "$ARCHIVE_ICONS" ]; then
	(
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
	PKG='PKG_DATA'
	organize_data 'ICONS' "$PATH_ICON_BASE"
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
