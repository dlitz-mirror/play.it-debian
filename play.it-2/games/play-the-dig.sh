#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, Sébastien “Elzen” Dufromentel
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
# The Dig
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200202.4

# Set game-specific variables

GAME_ID='the-dig'
GAME_NAME='The Dig'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR'

ARCHIVE_GOG_EN='the_dig_en_gog_2_20100.sh'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/the_dig'
ARCHIVE_GOG_EN_MD5='0fd830de17757f78dc9865dd7c06c785'
ARCHIVE_GOG_EN_SIZE='760000'
ARCHIVE_GOG_EN_VERSION='1.0-gog20100'
ARCHIVE_GOG_EN_TYPE='mojosetup'

ARCHIVE_GOG_FR='the_dig_fr_gog_2_20100.sh'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/the_dig'
ARCHIVE_GOG_FR_MD5='b4c2b87f0305a82bb0fa805b01b014f1'
ARCHIVE_GOG_FR_SIZE='760000'
ARCHIVE_GOG_FR_VERSION='1.0-gog20100'
ARCHIVE_GOG_FR_TYPE='mojosetup'

ARCHIVE_DOC_L10N_PATH='data/noarch/docs'
ARCHIVE_DOC_L10N_FILES='*'

ARCHIVE_GAME_L10N_PATH='data/noarch/data'
ARCHIVE_GAME_L10N_FILES='digvoice.bun language.bnd video/digtxt.trs video/sq14sc14.san video/sq14sc22.san video/sq17.san video/sq18b.san video/sq18sc15.san video/sq1.san video/sq2.san video/sq3.san video/sq4.san video/sq8a.san video/sq8b.san video/sq8c.san video/sq9.san'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='dig.la0 dig.la1 digmusic.bun video'

APP_MAIN_TYPE='scummvm'
APP_MAIN_SCUMMID='dig'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_L10N PKG_MAIN'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

PKG_MAIN_DEPS="$PKG_L10N_ID scummvm"

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

# Extract data from game

extract_data_from "$SOURCE_ARCHIVE"
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get icon

PKG='PKG_MAIN'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_MAIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
