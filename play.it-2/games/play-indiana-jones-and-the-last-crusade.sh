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
# Indiana Jones and the Last Crusade
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200209.1

# Set game-specific variables

GAME_ID='indiana-jones-and-the-last-crusade'
GAME_NAME='Indiana Jones and the Last Crusade'

ARCHIVE_GOG='indiana_jones_and_the_last_crusade_en_gog_2_20145.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/indiana_jones_and_the_last_crusade'
ARCHIVE_GOG_MD5='b00d2c5498376718caad19db54265b29'
ARCHIVE_GOG_SIZE='90000'
ARCHIVE_GOG_VERSION='1.0-gog20145'
ARCHIVE_GOG_TYPE='mojosetup'

# Reference card and Grail Diary are missing from main archive
ARCHIVE_OPTIONAL_DOC0='indiana_jones_last_crucade_reference_card.zip'
ARCHIVE_OPTIONAL_DOC0_URL='https://www.gog.com/downloads/indiana_jones_and_the_last_crusade/73603'
ARCHIVE_OPTIONAL_DOC0_MD5='e6d8dc70f1dc06f0e58fb1636970b8c0'
ARCHIVE_OPTIONAL_DOC1='indiana_jones_last_crusade_grail_diary.zip'
ARCHIVE_OPTIONAL_DOC1_URL='https://www.gog.com/downloads/indiana_jones_and_the_last_crusade/73613'
ARCHIVE_OPTIONAL_DOC1_MD5='13eb5e708eb947107ee5d01930507df4'

# Fix typos in file names
ARCHIVE_OPTIONAL_DOC0_RENAME_FROM='Indiana Jones The Last Cusade - Reference Card.pdf'
ARCHIVE_OPTIONAL_DOC0_RENAME_TO='indiana jones and the last crusade - reference card.pdf'
ARCHIVE_OPTIONAL_DOC1_RENAME_FROM='Indiana Jones The Last Crusae - Grail Diary.pdf'
ARCHIVE_OPTIONAL_DOC1_RENAME_TO='indiana jones and the last crusade - grail diary.pdf'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*.txt'
ARCHIVE_DOC0_MAIN_PATH='indiana_jones_last_crucade_reference_card'
ARCHIVE_DOC0_MAIN_FILES='*.pdf'
ARCHIVE_DOC1_MAIN_PATH='indiana_jones_last_crusade_grail_diary'
ARCHIVE_DOC1_MAIN_FILES='*.pdf'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='*.lfl'

APP_MAIN_TYPE='scummvm'
APP_MAIN_SCUMMID='indy3'
APP_MAIN_ICON='data/noarch/support/icon.png'

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

# Try to load extra doc archives

ARCHIVE_MAIN="$ARCHIVE"
for i in 0 1; do
	archive_set "ARCHIVE_DOC$i" "ARCHIVE_OPTIONAL_DOC$i"
done
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
tolower "$PLAYIT_WORKDIR/gamedata"

# Extract extra doc archives

for i in 0 1; do
	archive=$(get_value "ARCHIVE_DOC$i")
	if [ "$archive" ]; then
		(
			ARCHIVE="ARCHIVE_DOC$i"
			extract_data_from "$archive"
			# Rename extracted files, if necessary
			archdir="$PLAYIT_WORKDIR/gamedata/$(basename "$archive" .zip)"
			if [ -d "$archdir" ]; then
				cd "$archdir"
				from=$(get_value "ARCHIVE_OPTIONAL_DOC${i}_RENAME_FROM")
				to=$(get_value "ARCHIVE_OPTIONAL_DOC${i}_RENAME_TO")
				if [ -n "$from" ] && [ -n "$to" ] && [ -e "$from" ] && [ ! -e "$to" ]; then
					mv "$from" "$to"
				fi
			fi
		)
	fi
done

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
