#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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
# Torin’s Passage
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190420.3

# Set game-specific variables

GAME_ID='torins-passage'
GAME_NAME='Torinʼs Passage'

ARCHIVE_GOG='setup_torins_passage_2.0.0.7.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/torins_passage'
ARCHIVE_GOG_MD5='a7398abdb6964bf6a6446248f138d05e'
ARCHIVE_GOG_SIZE='348952'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.7'

ARCHIVE_DOC_MAIN_PATH='app'
ARCHIVE_DOC_MAIN_FILES='torin.txt *.pdf'

ARCHIVE_GAME_MAIN_PATH='app'
ARCHIVE_GAME_MAIN_FILES='*.exe resource.cfg *.drv *.shp *.hlp *.scr install.txt movie patches *.000 *.aud *.sfx *.err version'

DATA_FILES='./version ./AUTOSAVE.* ./TORINSG.*'
CONFIG_FILES='./resource.cfg ./TORIN.PRF'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='sierrah.exe'
APP_MAIN_OPTIONS='resource.cfg'
APP_MAIN_ICON='app/torinhr.ico'

PACKAGES_LIST='PKG_MAIN'

PKG_BIN_DEPS='dosbox'

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

icons_get_from_workdir 'APP_MAIN' >/dev/null 2>&1
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
