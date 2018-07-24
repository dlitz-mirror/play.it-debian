#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# Star Wars: Knights of the Old Republic II
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180224.1

# Set game-specific variables

GAME_ID='star-wars-knights-of-the-old-republic-2'
GAME_NAME='Star Wars: Knights of the Old Republic II'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR'

ARCHIVE_GOG_EN='setup_sw_kotor2_2.0.0.3.exe'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/star_wars_knights_of_the_old_republic_ii_the_sith_lords'
ARCHIVE_GOG_EN_MD5='0163b31f8763b77f567f5646d2586b61'
ARCHIVE_GOG_EN_TYPE='rar'
ARCHIVE_GOG_EN_VERSION='1.0b-gog2.0.0.3'
ARCHIVE_GOG_EN_SIZE='4700000'
ARCHIVE_GOG_EN_PART1='setup_sw_kotor2_2.0.0.3-1.bin'
ARCHIVE_GOG_EN_PART1_MD5='bbedad0d349a653a1502f2b9f4c207fc'
ARCHIVE_GOG_EN_PART1_TYPE='rar'

ARCHIVE_GOG_FR='setup_sw_kotor2_french_2.0.0.3.exe'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/star_wars_knights_of_the_old_republic_ii_the_sith_lords'
ARCHIVE_GOG_FR_MD5='81eae2db19c61a25111f2e6e5960a751'
ARCHIVE_GOG_FR_TYPE='rar'
ARCHIVE_GOG_FR_VERSION='1.0b-gog2.0.0.3'
ARCHIVE_GOG_FR_SIZE='4600000'
ARCHIVE_GOG_FR_PART1='setup_sw_kotor2_french_2.0.0.3-1.bin'
ARCHIVE_GOG_FR_PART1_MD5='27a4f0ba820bc66f53aa5117684917cf'
ARCHIVE_GOG_FR_PART1_TYPE='rar'

ARCHIVE_DOC_DATA_PATH='game'
ARCHIVE_DOC_DATA_FILES='./*.pdf ./*.txt'

ARCHIVE_GAME1_BIN_PATH='game'
ARCHIVE_GAME1_BIN_FILES='./*.exe ./binkw32.dll ./mss32.dll ./patchw32.dll ./miles ./utils'

ARCHIVE_GAME2_BIN_PATH='support/app'
ARCHIVE_GAME2_BIN_FILES='./*.ini'

ARCHIVE_GAME_L10N_PATH='game'
ARCHIVE_GAME_L10N_FILES='./dialog.tlk ./override/*.2da ./override/*.gui ./override/*.tpc ./override/*.wav ./lips ./streamsounds/a_* ./streamsounds/n_* ./streamsounds/p_* ./streamvoice ./movies/kre* ./movies/permov01.bik ./movies/scn* ./movies/trailer.bik'

ARCHIVE_GAME_DATA_PATH='game'
ARCHIVE_GAME_DATA_FILES='./chitin.key ./override/*.mdl ./modules ./streammusic ./streamsounds/al_* ./streamsounds/amb_* ./streamsounds/as_* ./streamounds/avo_* ./streamsounds/c_* ./streamsounds/dr_* ./streamsounds/echo_* ./streamsounds/evt_* ./streamsounds/mgs_* ./streamsounds/mus_* ./texturepacks ./data ./movies/credits.bik ./movies/dan* ./movies/hyp* ./movies/kho* ./movies/kor* ./movies/leclogo.bik ./movies/legal.bik ./movies/mal* ./movies/nar* ./movies/obsidianent.bik ./movies/ond* ./movies/permov02.bik ./movies/permov03.bik ./movies/permov04.bik ./movies/permov05.bik ./movies/permov06.bik ./movies/permov07.bik ./movies/tel*'

CONFIG_FILES='./*.ini'
DATA_DIRS='./override ./saves'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='swkotor2.exe'
APP_MAIN_ICON='swkotor2.exe'
APP_MAIN_ICON_RES='32 48'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_TYPE='wine'
APP_CONFIG_EXE='swconfig.exe'
APP_CONFIG_ICON='swconfig.exe'
APP_CONFIG_ICON_RES='32 48'
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_CAT='Settings'

PACKAGES_LIST='PKG_L10N PKG_DATA PKG_BIN'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ID="$GAME_ID"
PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_L10N_ID $PKG_DATA_ID wine"

# Load common functions

target_version='2.2'

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
. "$PLAYIT_LIB2"

# Check that all parts of the installer are present

ARCHIVE_MAIN="$ARCHIVE"
case "$ARCHIVE_MAIN" in
	('ARCHIVE_GOG_EN')
		set_archive 'ARCHIVE_PART1' 'ARCHIVE_GOG_EN_PART1'
		[ "$ARCHIVE_PART1" ] || set_archive_error_not_found 'ARCHIVE_GOG_EN_PART1'
	;;
	('ARCHIVE_GOG_FR')
		set_archive 'ARCHIVE_PART1' 'ARCHIVE_GOG_FR_PART1'
		[ "$ARCHIVE_PART1" ] || set_archive_error_not_found 'ARCHIVE_GOG_FR_PART1'
	;;
esac
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$ARCHIVE_PART1"
tolower "$PLAYIT_WORKDIR/gamedata"

for PKG in $PACKAGES_LIST; do
	organize_data "DOC_${PKG#PKG_}"   "$PATH_DOC"
	organize_data "GAME_${PKG#PKG_}"  "$PATH_GAME"
	organize_data "GAME1_${PKG#PKG_}" "$PATH_GAME"
	organize_data "GAME2_${PKG#PKG_}" "$PATH_GAME"
done

PKG='PKG_BIN'
extract_and_sort_icons_from 'APP_MAIN' 'APP_CONFIG'
move_icons_to 'PKG_DATA'

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Disable frame buffer effects on first launch

file="${PKG_BIN_PATH}${PATH_GAME}/swkotor2.ini"
regex='s/\[Graphics Options\]/&\nFrame Buffer=0/'
sed --in-place "$regex" "$file"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN' 'APP_CONFIG'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
