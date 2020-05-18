#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, Dominique Derrier
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
# Little Big Adventure 1
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200314.1

# Set game-specific variables

GAME_ID='little-big-adventure-1'
GAME_NAME='Little Big Adventure'

ARCHIVE_GOG='setup_little_big_adventure_1.0_(28186).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/little_big_adventure'
ARCHIVE_GOG_MD5='43d4926dc8a56a95800e746ac9797201'
ARCHIVE_GOG_SIZE='510000'
ARCHIVE_GOG_VERSION='1.0-gog28186'

ARCHIVE_GOG_OLD0='setup_lba_2.1.0.22.exe'
ARCHIVE_GOG_OLD0_MD5='c40177522adcbe50ea52590be57045f8'
ARCHIVE_GOG_OLD0_SIZE='510000'
ARCHIVE_GOG_OLD0_VERSION='1.0-gog2.1.0.22'

ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='*.pdf *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_MAIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='*.cfg *.dll *.ini dos4gw.exe language.exe relent.exe loadpats.exe setup.exe setup.lst *.hqr lba.dat lba.gog setsound.bat vox sample.*'
# Keep compatibility with old archives
ARCHIVE_GAME_MAIN_PATH_GOG_OLD0='app'

GAME_IMAGE='lba.dat'

CONFIG_FILES='*.cfg *.ini'
DATA_FILES='*.LBA'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='relent.exe'
APP_MAIN_ICON='app/goggame-1207658971.ico'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'
# Easier upgrade from packages generated with pre-20200210.3 scripts
PKG_MAIN_PROVIDE='little-big-adventure-1-data'

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

launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
