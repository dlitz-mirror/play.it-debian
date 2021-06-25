#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
# Copyright (c)      2021, Anna Lea
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
# Afterlife
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210625.7

# Set game-specific variables

GAME_ID='afterlife'
GAME_NAME='Afterlife'

ARCHIVE_BASE_EN_0='gog_afterlife_2.2.0.8.sh'
ARCHIVE_BASE_EN_0_MD5='3aca0fac1b93adec5aff39d395d995ab'
ARCHIVE_BASE_EN_0_TYPE='mojosetup'
ARCHIVE_BASE_EN_0_SIZE='260000'
ARCHIVE_BASE_EN_0_VERSION='1.0-gog2.2.0.8'
ARCHIVE_BASE_EN_0_URL='https://www.gog.com/game/afterlife'

ARCHIVE_BASE_FR_0='gog_afterlife_french_2.2.0.8.sh'
ARCHIVE_BASE_FR_0_MD5='56b3efee60bc490c68f8040587fc1878'
ARCHIVE_BASE_FR_0_TYPE='mojosetup'
ARCHIVE_BASE_FR_0_SIZE='250000'
ARCHIVE_BASE_FR_0_VERSION='1.0-gog2.2.0.8'
ARCHIVE_BASE_FR_0_URL='https://www.gog.com/game/afterlife'

ARCHIVE_DOC0_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC0_MAIN_FILES='*.pdf *.txt'

ARCHIVE_DOC1_MAIN_PATH='data/noarch/data'
ARCHIVE_DOC1_DATA_FILES='*.txt'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='*.asc *.exe *.ini alife.* alife'

CONFIG_FILES='./*.ini */*.ini'
DATA_DIRS='./save'

APP_MAIN_TYPE='dosbox'
APP_MAIN_PRERUN='cd alife'
APP_MAIN_EXE='afterdos.bat'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="$GAME_ID"
PKG_MAIN_PROVIDE="$PKG_MAIN_ID"
PKG_MAIN_DEPS='dosbox'

# Localizations

PKG_MAIN_ID_EN="${PKG_MAIN_ID}-en"
PKG_MAIN_ID_FR="${PKG_MAIN_ID}-fr"

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
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get game icon

PKG='PKG_MAIN'
icons_get_from_workdir 'APP_MAIN'

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
