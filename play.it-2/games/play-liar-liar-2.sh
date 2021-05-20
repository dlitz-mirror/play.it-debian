#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
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
# Liar Liar 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210517.4

# Set game-specific variables

GAME_ID='liar-liar-2'
GAME_NAME='Liar Liar 2: Pants on Fire'

ARCHIVE_BASE_0='liarliar2-all.zip'
ARCHIVE_BASE_0_MD5='6450f265d59ece46331070a2e0a14121'
ARCHIVE_BASE_0_SIZE='110000'
ARCHIVE_BASE_0_VERSION='1.0-itch'
ARCHIVE_BASE_0_URL='https://tokimekiwaku.itch.io/liar-liar-2'

ARCHIVE_DOC_MAIN_PATH='liarliar2-all'
ARCHIVE_DOC_MAIN_FILES='README.html'

ARCHIVE_GAME_MAIN_PATH='liarliar2-all/game'
ARCHIVE_GAME_MAIN_FILES='*'

APP_MAIN_TYPE='renpy'

PKG_MAIN_DEPS='renpy'

# Load common functions

target_version='2.13'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
		'/usr/share/play.it'
	do
		if [ -e "${path}/libplayit2.sh" ]; then
			PLAYIT_LIB2="${path}/libplayit2.sh"
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

# Clean up temporary directories

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

launchers_write 'APP_MAIN'

# Use default Ren'Py icon

desktop_file="$(package_get_path 'PKG_MAIN')${PATH_DESK}/${GAME_ID}.desktop"
pattern='^Icon=.*$'
replacement='Icon=renpy'
expression="s/${pattern}/${replacement}/"
sed --in-place --expression="$expression" "$desktop_file"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
