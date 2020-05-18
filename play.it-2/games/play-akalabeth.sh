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
# Akalabeth: World of Doom
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190310.3

# Set game-specific variables

GAME_ID='akalabeth'
GAME_NAME='Akalabeth: World of Doom'

ARCHIVES_LIST='ARCHIVE_GOG ARCHIVE_GOG_1998 ARCHIVE_GOG_1998_TAR'

ARCHIVE_GOG='gog_akalabeth_world_of_doom_2.0.0.3.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/akalabeth_world_of_doom'
ARCHIVE_GOG_MD5='11a770db592af2ac463e6cdc453b555b'
ARCHIVE_GOG_SIZE='13000'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.3'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_1998='akalabeth_1998_linux.zip'
ARCHIVE_GOG_1998_MD5='9c549339b300c3bfe73f8430d8fc74af'
ARCHIVE_GOG_1998_SIZE='18000'
ARCHIVE_GOG_1998_VERSION='1.0-gog1.0.0.1'
ARCHIVE_GOG_1998_TYPE='zip'

ARCHIVE_GOG_1998_TAR='gog_akalabeth_bonus_1998_1.0.0.1.tar.gz'
ARCHIVE_GOG_1998_TAR_MD5='3fccd2febb80c3eb0a2e78123207d1d7'
ARCHIVE_GOG_1998_TAR_SIZE='18000'
ARCHIVE_GOG_1998_TAR_VERSION='1.0-gog1.0.0.1'
ARCHIVE_GOG_1998_TAR_TYPE='tar'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_PATH_GOG_1998='akalabeth - bonus 1998/docs'
ARCHIVE_DOC_MAIN_FILES='*.pdf'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_PATH_GOG_1998='akalabeth - bonus 1998/data'
ARCHIVE_GAME_MAIN_FILES='*'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='aklabeth.exe'
APP_MAIN_EXE_GOG_1998='ak.exe'
APP_MAIN_ICON='data/noarch/support/icon.png'
APP_MAIN_ICON_GOG_1998='akalabeth - bonus 1998/support/gog-akalabeth-bonus-1998.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'

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
if [ "$ARCHIVE" = 'ARCHIVE_GOG_1998' ]; then
	ARCHIVE_GOG_1998_TYPE='tar'
	extract_data_from "$PLAYIT_WORKDIR/gamedata/gog_akalabeth_bonus_1998_1.0.0.1.tar.gz"
	rm --force "$PLAYIT_WORKDIR/gamedata/gog_akalabeth_bonus_1998_1.0.0.1.tar.gz"
fi
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get icon

icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

use_archive_specific_value 'APP_MAIN_EXE'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
