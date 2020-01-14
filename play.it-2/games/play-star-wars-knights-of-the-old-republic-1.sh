#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
# Copyright (c) 2018-2019, BetaRays
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
# STAR WARS™: Knights of the Old Republic
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20191211.1

# Set game-specific variables

GAME_ID='star-wars-knights-of-the-old-republic-1'
GAME_NAME='Star Wars: Knights of the Old Republic'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR ARCHIVE_GOG_DE ARCHIVE_GOG_EN_OLD0 ARCHIVE_GOG_FR_OLD0'

ARCHIVE_GOG_EN='setup_star_wars_-_knights_of_the_old_republic_1.03_(29871).exe'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/star_wars_knights_of_the_old_republic'
ARCHIVE_GOG_EN_MD5='6ea3df208a9cb3c8ca54eac2d0e2e4a9'
ARCHIVE_GOG_EN_VERSION='1.03-gog29871'
ARCHIVE_GOG_EN_SIZE='3800000'
ARCHIVE_GOG_EN_TYPE='innosetup'
ARCHIVE_GOG_EN_GOGID='1207666283'
ARCHIVE_GOG_EN_PART1='setup_star_wars_-_knights_of_the_old_republic_1.03_(29871)-1.bin'
ARCHIVE_GOG_EN_PART1_MD5='51d4eea9a76df9b99fba114c40005cfe'
ARCHIVE_GOG_EN_PART1_TYPE='innosetup'

ARCHIVE_GOG_FR='setup_star_wars_-_knights_of_the_old_republic_1.03_(french)_(29871).exe'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/star_wars_knights_of_the_old_republic'
ARCHIVE_GOG_FR_MD5='8db7abdf7dc05e8f65ea2599c9486b8d'
ARCHIVE_GOG_FR_VERSION='1.03-gog29871'
ARCHIVE_GOG_FR_SIZE='3800000'
ARCHIVE_GOG_FR_TYPE='innosetup'
ARCHIVE_GOG_FR_GOGID='1207666283'
ARCHIVE_GOG_FR_PART1='setup_star_wars_-_knights_of_the_old_republic_1.03_(french)_(29871)-1.bin'
ARCHIVE_GOG_FR_PART1_MD5='010bce761719c5e4570e136092a075fe'
ARCHIVE_GOG_FR_PART1_TYPE='innosetup'

ARCHIVE_GOG_DE='setup_star_wars_-_knights_of_the_old_republic_1.03_(german)_(29871).exe'
ARCHIVE_GOG_DE_URL='https://www.gog.com/game/star_wars_knights_of_the_old_republic'
ARCHIVE_GOG_DE_MD5='ba963a9d4e61aabd7f654437b1f6a69e'
ARCHIVE_GOG_DE_VERSION='1.03-gog29871'
ARCHIVE_GOG_DE_SIZE='3900000'
ARCHIVE_GOG_DE_TYPE='innosetup'
ARCHIVE_GOG_DE_GOGID='1207666283'
ARCHIVE_GOG_DE_PART1='setup_star_wars_-_knights_of_the_old_republic_1.03_(german)_(29871)-1.bin'
ARCHIVE_GOG_DE_PART1_MD5='ac11ebefb89767bc38d3521ba048ec31'
ARCHIVE_GOG_DE_PART1_TYPE='innosetup'

ARCHIVE_GOG_EN_OLD0='setup_sw_kotor_2.0.0.3.exe'
ARCHIVE_GOG_EN_OLD0_MD5='9962e94dabb07411a066c95efb4b78a4'
ARCHIVE_GOG_EN_OLD0_VERSION='1.03-gog2003'
ARCHIVE_GOG_EN_OLD0_SIZE='3800000'
ARCHIVE_GOG_EN_OLD0_TYPE='rar'
ARCHIVE_GOG_EN_OLD0_GOGID='1207666283'
ARCHIVE_GOG_EN_OLD0_PART1='setup_sw_kotor_2.0.0.3.bin'
ARCHIVE_GOG_EN_OLD0_PART1_MD5='2c2cc27ee410948b417f8fa30d0c9201'
ARCHIVE_GOG_EN_OLD0_PART1_TYPE='rar'

ARCHIVE_GOG_FR_OLD0='setup_sw_kotor_french_2.0.0.3.exe'
ARCHIVE_GOG_FR_OLD0_MD5='42b90743d069ca60dfd96f9991a5a37c'
ARCHIVE_GOG_FR_OLD0_VERSION='1.03-gog2003'
ARCHIVE_GOG_FR_OLD0_SIZE='3900000'
ARCHIVE_GOG_FR_OLD0_TYPE='rar'
ARCHIVE_GOG_FR_OLD0_GOGID='1207666283'
ARCHIVE_GOG_FR_OLD0_PART1='setup_sw_kotor_french_2.0.0.3.bin'
ARCHIVE_GOG_FR_OLD0_PART1_MD5='81c2b828d0b2708fae8c7b15248bb22d'
ARCHIVE_GOG_FR_OLD0_PART1_TYPE='rar'

ARCHIVE_DOC_L10N_PATH='game'
ARCHIVE_DOC_L10N_FILES='docs'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_PATH_GOG_EN_OLD0='game'
ARCHIVE_DOC_DATA_PATH_GOG_FR_OLD0="$ARCHIVE_DOC_DATA_PATH_GOG_EN_OLD0"
ARCHIVE_DOC_DATA_FILES='swkotorv103.txt manual.pdf'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_PATH_GOG_EN_OLD0='game'
ARCHIVE_GAME_BIN_PATH_GOG_FR_OLD0="$ARCHIVE_GAME_BIN_PATH_GOG_EN_OLD0"
ARCHIVE_GAME_BIN_FILES='*.exe binkw32.dll patchw32.dll mss32.dll utils/*.exe utils/*.txt'

ARCHIVE_GAME_L10N_PATH='.'
ARCHIVE_GAME_L10N_PATH_GOG_EN_OLD0='game'
ARCHIVE_GAME_L10N_PATH_GOG_FR_OLD0="$ARCHIVE_GAME_L10N_PATH_GOG_EN_OLD0"
ARCHIVE_GAME_L10N_FILES='patch.erf utils/*.ini utils/swupdateskins lips streamwaves streamsounds dialog.tlk movies/01a.bik movies/02.bik movies/09.bik movies/31a.bik movies/50.bik movies/56b.bik movies/leclogo.bik movies/legal.bik movies/01a.bik movies/02.bik movies/09.bik movies/31a.bik movies/50.bik movies/56b.bik movies/leclogo.bik movies/legal.bik'

ARCHIVE_GAME0_DATA_PATH='.'
ARCHIVE_GAME0_DATA_PATH_GOG_EN_OLD0='game'
ARCHIVE_GAME0_DATA_PATH_GOG_FR_OLD0="$ARCHIVE_GAME0_DATA_PATH_GOG_EN_OLD0"
ARCHIVE_GAME0_DATA_FILES='chitin.key data miles modules rims streammusic texturepacks movies'

ARCHIVE_GAME1_DATA_PATH='__support/app'
ARCHIVE_GAME1_DATA_PATH_GOG_EN_OLD0='support/app'
ARCHIVE_GAME1_DATA_PATH_GOG_FR_OLD0="$ARCHIVE_GAME1_DATA_PATH_GOG_EN_OLD0"
ARCHIVE_GAME1_DATA_FILES='swkotor.ini'

DATA_DIRS='./saves ./override'
CONFIG_FILES='./swkotor.ini'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='swkotor.exe'
APP_MAIN_ICON='swkotor.exe'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_TYPE='wine'
APP_CONFIG_EXE='swconfig.exe'
APP_CONFIG_ICON='swconfig.exe'
APP_CONFIG_NAME="${GAME_NAME} - Configuration"
APP_CONFIG_CAT='Settings'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_ID_GOG_DE="${PKG_L10N_ID}-de"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
PKG_L10N_DESCRIPTION_GOG_FR='French localization'
PKG_L10N_DESCRIPTION_GOG_DE='German localization'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# Easier upgrade from packages generated with 20190122.6 scripts
PKG_DATA_PROVIDE='star-wars-knights-of-the-old-republic-data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_L10N_ID $PKG_DATA_ID wine glx libxrandr"
# Easier upgrade from packages generated with 20190122.6 scripts
PKG_BIN_PROVIDE='star-wars-knights-of-the-old-republic'

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
	(*'_OLD0')
		extract_data_from "$SOURCE_ARCHIVE_PART1"
		tolower "$PLAYIT_WORKDIR/gamedata"
	;;
	(*)
		extract_data_from "$SOURCE_ARCHIVE"
	;;
esac
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_CONFIG'
icons_move_to 'PKG_DATA'

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
