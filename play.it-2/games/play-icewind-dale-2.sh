#!/bin/sh
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
# Icewind Dale 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200503.4

# Set game-specific variables

GAME_ID='icewind-dale-2'
GAME_NAME='Icewind Dale Ⅱ'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0
'

ARCHIVE_GOG_EN_0='setup_icewind_dale2_2.1.0.13.exe'
ARCHIVE_GOG_EN_0_MD5='9a68fdabdaff58bebc67092d47d4174e'
ARCHIVE_GOG_EN_0_TYPE='innosetup'
ARCHIVE_GOG_EN_0_URL='https://www.gog.com/game/icewind_dale_2'
ARCHIVE_GOG_EN_0_VERSION='2.01.101615-gog2.1.0.13'
ARCHIVE_GOG_EN_0_SIZE='1500000'

ARCHIVE_GOG_FR_0='setup_icewind_dale2_french_2.1.0.13.exe'
ARCHIVE_GOG_FR_0_MD5='04f25433d405671a8975be6540dd55fa'
ARCHIVE_GOG_FR_0_TYPE='innosetup'
ARCHIVE_GOG_FR_0_URL='https://www.gog.com/game/icewind_dale_2'
ARCHIVE_GOG_FR_0_VERSION='2.01.101615-gog2.1.0.13'
ARCHIVE_GOG_FR_0_SIZE='1500000'

ARCHIVE_DOC_L10N_PATH='app'
ARCHIVE_DOC_L10N_FILES='manual.pdf patch.txt readme.htm'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='binkw32.dll icewind2.ini keymap.ini *.exe'

ARCHIVE_GAME_L10N_PATH='app'
ARCHIVE_GAME_L10N_FILES='characters override sounds language.ini party.ini *.tlk'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='cd2 chitin.key data music scripts'

CONFIG_FILES='./*.ini'
DATA_DIRS='./characters ./mpsave ./override ./portraits ./scripts'

APP_WINETRICKS='csmt=off'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='iwd2.exe'
APP_MAIN_ICON='iwd2.exe'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_TYPE='wine'
APP_CONFIG_EXE='config.exe'
APP_CONFIG_ICON='config.exe'
APP_CONFIG_CAT='Settings'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

# Common section for localization packages
PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
# English localization
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
# French localization
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_L10N_ID $PKG_DATA_ID wine winetricks"

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
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_CONFIG'
icons_move_to 'PKG_DATA'

# Update game path in .ini file

pattern1='HD0:=.\+'
replacement1='HD0:=C:\\'"${GAME_ID}"'\\'
pattern2='CD1:=.\+'
replacement2='CD1:=C:\\'"${GAME_ID}"'\\data\\'
pattern3='CD2:=.\+'
replacement3='CD2:=C:\\'"${GAME_ID}"'\\cd2\\'
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place \
		"s/${pattern1}/${replacement1}/;s/${pattern2}/${replacement2}/;s/${pattern3}/${replacement3}/" \
		"${PKG_BIN_PATH}${PATH_GAME}/icewind2.ini"
fi

# Default to windowed mode on first launch

pattern='Full Screen=.\+'
replacement='Full Screen=0'
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place \
		"s/${pattern}/${replacement}/" \
		"${PKG_BIN_PATH}${PATH_GAME}/icewind2.ini"
fi

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
