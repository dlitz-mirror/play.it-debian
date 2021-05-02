#!/bin/sh
set -o errexit

###
# Copyright (c)      2021, Anna Lea
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# The 7th Guest
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210503.4

# Set game-specific variables

GAME_ID='the-7th-guest'
GAME_NAME='The 7th Guest'

ARCHIVES_LIST='
ARCHIVE_BASE_0'

ARCHIVE_BASE_0='the_7th_guest_en_patch_3_21683.sh'
ARCHIVE_BASE_0_MD5='eb2cd92e06e0594297e1d38e3552df6d'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='780000'
ARCHIVE_BASE_0_VERSION='1.3-gog21683'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/the_7th_guest_25th_anniversary_edition'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*.pdf *.txt'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='*.gjd *.grv *.rl fat.* sphinx.fnt'

APP_MAIN_TYPE='scummvm'
APP_MAIN_SCUMMID='t7g'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='scummvm'

# Load common functions

target_version='2.12'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
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

# Get icon

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
