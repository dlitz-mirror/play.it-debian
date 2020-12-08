#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
# Copyright (c) 2018-2020, Andrey Butirsky
# Copyright (c)      2020, macaron
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
# Little Big Adventure 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200924.1

# Set game-specific variables

GAME_ID='little-big-adventure-2'
GAME_NAME='Little Big Adventure 2'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0'

ARCHIVE_GOG_1='setup_little_big_adventure_2_1.0_(28192).exe'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/little_big_adventure_2'
ARCHIVE_GOG_1_MD5='80b95bb8faa2353284b321748021da16'
ARCHIVE_GOG_1_SIZE='750000'
ARCHIVE_GOG_1_VERSION='1.0-gog28192'

ARCHIVE_GOG_0='setup_lba2_2.1.0.8.exe'
ARCHIVE_GOG_0_MD5='9909163b7285bd37417f6d3c1ccfa3ee'
ARCHIVE_GOG_0_SIZE='750000'
ARCHIVE_GOG_0_VERSION='1.0-gog2.1.0.8'

ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='*.pdf *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_MAIN_PATH_GOG_0='app'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='*.bat *.cfg *.dos *.exe *.ini drivers *.hqr *.ile *.obl lba2.dat lba2.gog lba2.ogg'
# Keep compatibility with old archives
ARCHIVE_GAME_MAIN_PATH_GOG_0='app'

GAME_IMAGE='lba2.dat'

CONFIG_FILES='*.cfg'
DATA_DIRS='save vox'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='lba2.exe'
APP_MAIN_ICON='app/goggame-1207658974.ico'

APP_SETUP_TYPE='dosbox'
APP_SETUP_EXE='setup.exe'
APP_SETUP_ID="${GAME_ID}_setup"
APP_SETUP_NAME="$GAME_NAME - Setup"
APP_SETUP_CAT='Settings'
APP_SETUP_ICON="$APP_MAIN_ICON"

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icons

icons_get_from_workdir 'APP_MAIN' 'APP_SETUP'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Keep Voices on HD

file="${PKG_MAIN_PATH}${PATH_GAME}/lba2.cfg"
pattern='s/\(FlagKeepVoice:\) OFF/\1 ON/'
sed --in-place "$pattern" "$file"

# Write launchers

launchers_write 'APP_MAIN' 'APP_SETUP'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
