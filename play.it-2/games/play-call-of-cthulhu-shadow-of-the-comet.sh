#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2020, macaron
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
# Call of Cthulhu: Shadow of the Comet
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200223.1

# Set game-specific variables

GAME_ID='call-of-cthulhu-shadow-of-the-comet'
GAME_NAME='Call of Cthulhu: Shadow of the Comet'

ARCHIVE_GOG='gog_call_of_cthulhu_shadow_of_the_comet_2.0.0.4.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/call_of_cthulhu_shadow_of_the_comet'
ARCHIVE_GOG_MD5='18c4f78b766e8e1d638e4ac32df0be60'
ARCHIVE_GOG_SIZE='150000'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.4'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*.pdf *.txt'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='infogram cd'

GAME_IMAGE='CD'
GAME_IMAGE_TYPE='cdrom'

CONFIG_FILES='INFOGRAM/SHADOW.CD/*.CFG INFOGRAM/SHADOW.CD/*.OPT'
DATA_FILES='INFOGRAM/SHADOW.CD/*.SAV'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='SHADOW.EXE'
APP_MAIN_PRERUN='d:
config -set cpu cycles=fixed 13000'
APP_MAIN_ICON='data/noarch/support/icon.png'

APP_MUSEUM_TYPE='dosbox'
APP_MUSEUM_EXE='MUSEUM.EXE'
APP_MUSEUM_PRERUN='d:
config -set cpu cycles=fixed 13000'
APP_MUSEUM_ID="${GAME_ID}_museum"
APP_MUSEUM_NAME="$GAME_NAME - Lovecraft Museum"
APP_MUSEUM_ICON="$APP_MAIN_ICON"

APP_SETUP_TYPE='dosbox'
APP_SETUP_EXE='INSTALL.EXE'
APP_SETUP_PRERUN='d:'
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
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
toupper "$PKG_MAIN_PATH$PATH_GAME"

# Extract icons

icons_get_from_workdir 'APP_MAIN' 'APP_MUSEUM' 'APP_SETUP'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

launchers_write 'APP_MAIN' 'APP_MUSEUM' 'APP_SETUP'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
