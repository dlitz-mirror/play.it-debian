#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Litil Divil
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180224.1

# Set game-specific variables

GAME_ID='litil-divil'
GAME_NAME='Litil Divil'

ARCHIVES_LIST='ARCHIVE_GOG'

ARCHIVE_GOG='gog_litil_divil_2.0.0.21.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/litil_divil'
ARCHIVE_GOG_MD5='1258be406cb4b40c912c4846df2ac92b'
ARCHIVE_GOG_SIZE='44000'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.21'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_DOC1_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC1_DATA_FILES='./*.txt ./*.pdf'

ARCHIVE_DOC2_DATA_PATH='data/noarch/data'
ARCHIVE_DOC2_DATA_FILES='./config.doc'

ARCHIVE_GAME_BIN_PATH='data/noarch/data'
ARCHIVE_GAME_BIN_FILES='./config.exe ./data/divil.exe ./divils.cfg'

ARCHIVE_GAME_DATA_PATH='data/noarch/data'
ARCHIVE_GAME_DATA_FILES='./gfx ./data/*.map ./data/gfx ./data/level*'

CONFIG_FILES='./divils.cfg'

GAME_IMAGE='data'
GAME_IMAGE_TYPE='cdrom'

APP_MAIN_TYPE='dosbox'
APP_MAIN_PRERUN='d:'
APP_MAIN_EXE='divil.exe'
APP_MAIN_OPTIONS='c:'
APP_MAIN_ICON='data/noarch/support/icon.png'
APP_MAIN_ICON_RES='512'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_TYPE='dosbox'
APP_CONFIG_EXE='config.exe'
APP_CONFIG_CAT='Settings'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID dosbox"

# Load common functions

target_version='2.4'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	if [ -e "$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh" ]; then
		PLAYIT_LIB2="$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh"
	elif [ -e './libplayit2.sh' ]; then
		PLAYIT_LIB2='./libplayit2.sh'
	else
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
tolower "$PLAYIT_WORKDIR/gamedata"

for PKG in $PACKAGES_LIST; do
	organize_data "DOC1_${PKG#PKG_}" "$PATH_DOC"
	organize_data "DOC2_${PKG#PKG_}" "$PATH_DOC"
	organize_data "GAME_${PKG#PKG_}" "$PATH_GAME"
done

PKG='PKG_DATA'
get_icon_from_temp_dir 'APP_MAIN'

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN' 'APP_CONFIG'

# Use base game icon for settings launcher

file="${PKG_BIN_PATH}${PATH_DESK}/$APP_CONFIG_ID.desktop"
regex="s/\\(Icon=\\).\\+/\\1$GAME_ID/"
sed --in-place "$regex" "$file"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "${PLAYIT_WORKDIR}"

# Print instructions

print_instructions

exit 0
