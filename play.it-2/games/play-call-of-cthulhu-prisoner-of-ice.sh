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
# Call of Cthulhu: Prisoner of Ice
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200223.1

# Set game-specific variables

GAME_ID='call-of-cthulhu-prisoner-of-ice'
GAME_NAME='Call of Cthulhu: Prisoner of Ice'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR'

ARCHIVE_GOG_EN='call_of_cthulhu_prisoner_of_ice_en_gog_5_17654.sh'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/call_of_cthulhu_prisoner_of_ice'
ARCHIVE_GOG_EN_MD5='c3f64c02981cfacefd3b3f8d0d504ac3'
ARCHIVE_GOG_EN_SIZE='310000'
ARCHIVE_GOG_EN_VERSION='1.0-gog17654'
ARCHIVE_GOG_EN_TYPE='mojosetup'

ARCHIVE_GOG_FR='call_of_cthulhu_prisoner_of_ice_fr_gog_5_17654.sh'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/call_of_cthulhu_prisoner_of_ice'
ARCHIVE_GOG_FR_MD5='da1f4dad3ee3817a026390fa28320284'
ARCHIVE_GOG_FR_SIZE='350000'
ARCHIVE_GOG_FR_VERSION='1.0-gog17654'
ARCHIVE_GOG_FR_TYPE='mojosetup'

ARCHIVE_DOC0_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC0_MAIN_FILES='*.pdf *.txt'
ARCHIVE_DOC1_MAIN_PATH='data/noarch/data'
ARCHIVE_DOC1_MAIN_FILES='*.txt'
ARCHIVE_DOC2_MAIN_PATH_GOG_EN='data/noarch/docs/english'
ARCHIVE_DOC2_MAIN_PATH_GOG_FR='data/noarch/docs/french'
ARCHIVE_DOC2_MAIN_FILES='*.pdf *.txt'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='ice cd'

GAME_IMAGE='CD'
GAME_IMAGE_TYPE='cdrom'

CONFIG_FILES='ICE/*.CFG ICE/*.PCK'
DATA_FILES='ICE/*.ICE'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='ICE640.EXE'
APP_MAIN_PRERUN='d:'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="$GAME_ID"
PKG_MAIN_ID_GOG_EN="${GAME_ID}-en"
PKG_MAIN_ID_GOG_FR="${GAME_ID}-fr"
PKG_MAIN_PROVIDE="$PKG_MAIN_ID"
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
