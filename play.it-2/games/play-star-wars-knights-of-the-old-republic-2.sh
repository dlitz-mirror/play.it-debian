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
# Star Wars: Knights of the Old Republic Ⅱ
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200614.2

# Set game-specific variables

GAME_ID='star-wars-knights-of-the-old-republic-2'
GAME_NAME='Star Wars: Knights of the Old Republic Ⅱ - The Sith Lords'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_1
ARCHIVE_GOG_FR_1
ARCHIVE_GOG_RAR_EN_0
ARCHIVE_GOG_RAR_FR_0
'

ARCHIVE_GOG_EN_1='setup_star_wars_-_knights_of_the_old_republic_ii_1.0b_(29869).exe'
ARCHIVE_GOG_EN_1_URL='https://www.gog.com/game/star_wars_knights_of_the_old_republic_ii_the_sith_lords'
ARCHIVE_GOG_EN_1_MD5='7f7a2e14e5ebadf14c0cdbb1ee807521'
ARCHIVE_GOG_EN_1_TYPE='innosetup'
ARCHIVE_GOG_EN_1_VERSION='1.0b-gog29869'
ARCHIVE_GOG_EN_1_SIZE='4700000'
ARCHIVE_GOG_EN_1_PART1='setup_star_wars_-_knights_of_the_old_republic_ii_1.0b_(29869)-1.bin'
ARCHIVE_GOG_EN_1_PART1_MD5='8092cf5da5fa165f88d67e172c610c5e'
ARCHIVE_GOG_EN_1_PART1_TYPE='innosetup'

ARCHIVE_GOG_FR_1='setup_star_wars_-_knights_of_the_old_republic_ii_1.0b_(french)_(29869).exe'
ARCHIVE_GOG_FR_1_URL='https://www.gog.com/game/star_wars_knights_of_the_old_republic_ii_the_sith_lords'
ARCHIVE_GOG_FR_1_MD5='a16a80f377111ec4152e5d1b196f64f5'
ARCHIVE_GOG_FR_1_TYPE='innosetup'
ARCHIVE_GOG_FR_1_VERSION='1.0b-gog29869'
ARCHIVE_GOG_FR_1_SIZE='4600000'
ARCHIVE_GOG_FR_1_PART1='setup_star_wars_-_knights_of_the_old_republic_ii_1.0b_(french)_(29869)-1.bin'
ARCHIVE_GOG_FR_1_PART1_MD5='e68c85d7f0ad6212c9841276526aa5d3'
ARCHIVE_GOG_FR_1_PART1_TYPE='innosetup'

ARCHIVE_GOG_RAR_EN_0='setup_sw_kotor2_2.0.0.3.exe'
ARCHIVE_GOG_RAR_EN_0_MD5='0163b31f8763b77f567f5646d2586b61'
ARCHIVE_GOG_RAR_EN_0_TYPE='rar'
ARCHIVE_GOG_RAR_EN_0_VERSION='1.0b-gog2.0.0.3'
ARCHIVE_GOG_RAR_EN_0_SIZE='4700000'
ARCHIVE_GOG_RAR_EN_0_PART1='setup_sw_kotor2_2.0.0.3-1.bin'
ARCHIVE_GOG_RAR_EN_0_PART1_MD5='bbedad0d349a653a1502f2b9f4c207fc'
ARCHIVE_GOG_RAR_EN_0_PART1_TYPE='rar'

ARCHIVE_GOG_RAR_FR_0='setup_sw_kotor2_french_2.0.0.3.exe'
ARCHIVE_GOG_RAR_FR_0_MD5='81eae2db19c61a25111f2e6e5960a751'
ARCHIVE_GOG_RAR_FR_0_TYPE='rar'
ARCHIVE_GOG_RAR_FR_0_VERSION='1.0b-gog2.0.0.3'
ARCHIVE_GOG_RAR_FR_0_SIZE='4600000'
ARCHIVE_GOG_RAR_FR_0_PART1='setup_sw_kotor2_french_2.0.0.3-1.bin'
ARCHIVE_GOG_RAR_FR_0_PART1_MD5='27a4f0ba820bc66f53aa5117684917cf'
ARCHIVE_GOG_RAR_FR_0_PART1_TYPE='rar'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.pdf *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_RAR='game'

ARCHIVE_GAME1_BIN_PATH='.'
ARCHIVE_GAME1_BIN_FILES='*.exe binkw32.dll mss32.dll patchw32.dll miles utils'
# Keep compatibility with old archives
ARCHIVE_GAME1_BIN_PATH_GOG_RAR='game'

ARCHIVE_GAME2_BIN_PATH='__support/app'
ARCHIVE_GAME2_BIN_FILES='*.ini'
# Keep compatibility with old archives
ARCHIVE_GAME2_BIN_PATH_GOG_RAR='support/app'

ARCHIVE_GAME_L10N_PATH='.'
ARCHIVE_GAME_L10N_FILES='dialog.tlk override/*.2da override/*.gui override/*.tpc override/*.wav lips streamsounds/a_* streamsounds/n_* streamsounds/p_* streamvoice movies/kre* movies/permov01.bik movies/scn* movies/trailer.bik'
# Keep compatibility with old archives
ARCHIVE_GAME_L10N_PATH_GOG_RAR='game'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='chitin.key override/*.mdl modules streammusic streamsounds/al_* streamsounds/amb_* streamsounds/as_* streamounds/avo_* streamsounds/c_* streamsounds/dr_* streamsounds/echo_* streamsounds/evt_* streamsounds/mgs_* streamsounds/mus_* texturepacks data movies/credits.bik movies/dan* movies/hyp* movies/kho* movies/kor* movies/leclogo.bik movies/legal.bik movies/mal* movies/nar* movies/obsidianent.bik movies/ond* movies/permov02.bik movies/permov03.bik movies/permov04.bik movies/permov05.bik movies/permov06.bik movies/permov07.bik movies/tel*'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_RAR='game'

CONFIG_FILES='./*.ini'
DATA_DIRS='./override ./saves'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='swkotor2.exe'
APP_MAIN_ICON='swkotor2.exe'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_CAT='Settings'
APP_CONFIG_TYPE='wine'
APP_CONFIG_EXE='swconfig.exe'
APP_CONFIG_ICON='swconfig.exe'

PACKAGES_LIST='PKG_L10N PKG_DATA PKG_BIN'

# Localization package - common properties
PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"

# Localization package - English
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
# Keep compatibility with old archives
PKG_L10N_ID_GOG_RAR_EN="$PKG_L10N_ID_GOG_EN"
PKG_L10N_DESCRIPTION_GOG_RAR_EN="$PKG_L10N_DESCRIPTION_GOG_EN"

# Localization package - French
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_GOG_FR='French localization'
# Keep compatibility with old archives
PKG_L10N_ID_GOG_RAR_FR="$PKG_L10N_ID_GOG_FR"
PKG_L10N_DESCRIPTION_GOG_RAR_FR="$PKG_L10N_DESCRIPTION_GOG_FR"

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ID="$GAME_ID"
PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_L10N_ID $PKG_DATA_ID wine"

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

case "$ARCHIVE" in
	('ARCHIVE_GOG_RAR_'*)
		extract_data_from "$SOURCE_ARCHIVE_PART1"
		tolower "$PLAYIT_WORKDIR/gamedata"
	;;
	(*)
		extract_data_from "$SOURCE_ARCHIVE"
	;;
esac
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_CONFIG'
icons_move_to 'PKG_DATA'

# Disable frame buffer effects on first launch

file="${PKG_BIN_PATH}${PATH_GAME}/swkotor2.ini"
regex='s/\[Graphics Options\]/&\nFrame Buffer=0/'
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place "$regex" "$file"
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
