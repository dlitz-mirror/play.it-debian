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
# Divine Divinity
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200710.2

# Set game-specific variables

GAME_ID='divine-divinity'
GAME_NAME='Divine Divinity'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0'

ARCHIVE_GOG_EN_0='setup_divine_divinity_2.0.0.21.exe'
ARCHIVE_GOG_EN_0_URL='https://www.gog.com/game/divine_divinity'
ARCHIVE_GOG_EN_0_MD5='3798d48f04a7a8444fd9f4c32b75b41d'
ARCHIVE_GOG_EN_0_VERSION='1.0062a-gog2.0.0.21'
ARCHIVE_GOG_EN_0_SIZE='2400000'
ARCHIVE_GOG_EN_0_TYPE='innosetup'

ARCHIVE_GOG_FR_0='setup_divine_divinity_french_2.1.0.32.exe'
ARCHIVE_GOG_FR_0_URL='https://www.gog.com/game/divine_divinity'
ARCHIVE_GOG_FR_0_MD5='f755d69ad7d319fb70298844dcb3861a'
ARCHIVE_GOG_FR_0_VERSION='1.0062a-gog2.1.0.32'
ARCHIVE_GOG_FR_0_SIZE='2400000'
ARCHIVE_GOG_FR_0_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='*.pdf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe sound.cfg secdrv.sys'

ARCHIVE_GAME_L10N_PATH='app'
ARCHIVE_GAME_L10N_FILES='localizations dat/english dat/french config.lcl'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='capture dat fonts global main sound static divinityevent.dat testimage.tga keylist.txt'

CONFIG_FILES='*.cfg config.div config.lcl keylist.txt'
DATA_DIRS='./dynamic ./global ./savegames'
DATA_FILES='*.000 static/*.000 persist.dat static/imagelists/collide.* dat/usernotes.bin'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='div.exe'
APP_MAIN_ICON='div.exe'

APP_CONFIG_ID="${GAME_ID}_configuration"
APP_CONFIG_NAME="${GAME_NAME} - Configuration"
APP_CONFIG_CAT='Settings'
APP_CONFIG_TYPE='wine'
APP_CONFIG_EXE='configtool.exe'
APP_CONFIG_ICON='configtool.exe'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
# English
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
# French
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID $PKG_L10N_ID wine glx"

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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_CONFIG'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_CONFIG'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
