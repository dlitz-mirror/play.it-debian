#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2017-2020, Jacek Szafarkiewicz
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
# Robin Hood: The Legend of Sherwood
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210623.26

# Set game-specific variables

GAME_ID='robin-hood-the-legend-of-sherwood'
GAME_NAME='Robin Hood: The Legend of Sherwood'

ARCHIVE_BASE_EN_0='setup_robin_hood_-_the_legend_of_sherwood_1.1_hotfix_(24778).exe'
ARCHIVE_BASE_EN_0_MD5='a52ed21f93f17457a3a137b54ee60919'
ARCHIVE_BASE_EN_0_TYPE='innosetup'
ARCHIVE_BASE_EN_0_SIZE='1100000'
ARCHIVE_BASE_EN_0_VERSION='1.1-gog24778'
ARCHIVE_BASE_EN_0_URL='https://www.gog.com/game/robin_hood'
ARCHIVE_BASE_EN_0_PART1='setup_robin_hood_-_the_legend_of_sherwood_1.1_hotfix_(24778)-1.bin'
ARCHIVE_BASE_EN_0_PART1_MD5='6fbcea908c83933326294c0706838da5'
ARCHIVE_BASE_EN_0_PART1_TYPE='innosetup'

ARCHIVE_BASE_FR_0='setup_robin_hood_-_the_legend_of_sherwood_1.1_hotfix_(french)_(24778).exe'
ARCHIVE_BASE_FR_0_MD5='2f945bd2a1d70c1c9ff3b9938e1adf9a'
ARCHIVE_BASE_FR_0_TYPE='innosetup'
ARCHIVE_BASE_FR_0_SIZE='1100000'
ARCHIVE_BASE_FR_0_VERSION='1.1-gog24778'
ARCHIVE_BASE_FR_0_URL='https://www.gog.com/game/robin_hood'
ARCHIVE_BASE_FR_0_PART1='setup_robin_hood_-_the_legend_of_sherwood_1.1_hotfix_(french)_(24778)-1.bin'
ARCHIVE_BASE_FR_0_PART1_MD5='060df1c05868593a59ccc4ca2832cf36'
ARCHIVE_BASE_FR_0_PART1_TYPE='innosetup'

ARCHIVE_BASE_DE_0='setup_robin_hood_-_the_legend_of_sherwood_1.1_hotfix_(german)_(24778).exe'
ARCHIVE_BASE_DE_0_MD5='cdba08e0613408bc3709f387144c7a1d'
ARCHIVE_BASE_DE_0_TYPE='innosetup'
ARCHIVE_BASE_DE_0_SIZE='1100000'
ARCHIVE_BASE_DE_0_VERSION='1.1-gog24778'
ARCHIVE_BASE_DE_0_URL='https://www.gog.com/game/robin_hood'
ARCHIVE_BASE_DE_0_PART1='setup_robin_hood_-_the_legend_of_sherwood_1.1_hotfix_(german)_(24778)-1.bin'
ARCHIVE_BASE_DE_0_PART1_MD5='6291dbee561468bb4fbb769aaf74eb36'
ARCHIVE_BASE_DE_0_PART1_TYPE='innosetup'

ARCHIVE_BASE_PL_0='setup_robin_hood_-_the_legend_of_sherwood_1.1_hotfix_(polish)_(24778).exe'
ARCHIVE_BASE_PL_0_MD5='42066791c34c3ff6f6b9a1404f7afb1e'
ARCHIVE_BASE_PL_0_TYPE='innosetup'
ARCHIVE_BASE_PL_0_SIZE='1100000'
ARCHIVE_BASE_PL_0_VERSION='1.1-gog24778'
ARCHIVE_BASE_PL_0_URL='https://www.gog.com/game/robin_hood'
ARCHIVE_BASE_PL_0_PART1='setup_robin_hood_-_the_legend_of_sherwood_1.1_hotfix_(polish)_(24778)-1.bin'
ARCHIVE_BASE_PL_0_PART1_MD5='dc4bf92553c3a6e436b8d79c99a6287c'
ARCHIVE_BASE_PL_0_PART1_TYPE='innosetup'

ARCHIVE_BASE_ES_0='setup_robin_hood_-_the_legend_of_sherwood_1.1_hotfix_(spanish)_(24778).exe'
ARCHIVE_BASE_ES_0_MD5='7db0f8d9c40bb398acb406224a225eb9'
ARCHIVE_BASE_ES_0_TYPE='innosetup'
ARCHIVE_BASE_ES_0_SIZE='1100000'
ARCHIVE_BASE_ES_0_VERSION='1.1-gog24778'
ARCHIVE_BASE_ES_0_URL='https://www.gog.com/game/robin_hood'
ARCHIVE_BASE_ES_0_PART1='setup_robin_hood_-_the_legend_of_sherwood_1.1_hotfix_(spanish)_(24778)-1.bin'
ARCHIVE_BASE_ES_0_PART1_MD5='e9ba8791951285a814ef86fcf3b8614f'
ARCHIVE_BASE_ES_0_PART1_TYPE='innosetup'

ARCHIVE_BASE_EN_OLDPATH_1='setup_robin_hood_-_the_legend_of_sherwood_1.1_(17797).exe'
ARCHIVE_BASE_EN_OLDPATH_1_MD5='e8808cdafc7ea75cbcfaa850275b3dd6'
ARCHIVE_BASE_EN_OLDPATH_1_TYPE='innosetup'
ARCHIVE_BASE_EN_OLDPATH_1_SIZE='1200000'
ARCHIVE_BASE_EN_OLDPATH_1_VERSION='1.1-gog17797'

ARCHIVE_BASE_FR_OLDPATH_1='setup_robin_hood_-_the_legend_of_sherwood_french_1.1_(17797).exe'
ARCHIVE_BASE_FR_OLDPATH_1_MD5='8b19812fb424651fc482cb7a9c5ed665'
ARCHIVE_BASE_FR_OLDPATH_1_SIZE='1200000'
ARCHIVE_BASE_FR_OLDPATH_1_VERSION='1.1-gog17797'

ARCHIVE_BASE_EN_OLDPATH_0='setup_robin_hood_2.0.0.12.exe'
ARCHIVE_BASE_EN_OLDPATH_0_MD5='9e2452c88f154c5e0306ca98e6b773ef'
ARCHIVE_BASE_EN_OLDPATH_0_SIZE='1100000'
ARCHIVE_BASE_EN_OLDPATH_0_VERSION='1.1-gog2.0.0.12'

ARCHIVE_BASE_FR_OLDPATH_0='setup_robin_hood_french_2.1.0.15.exe'
ARCHIVE_BASE_FR_OLDPATH_0_MD5='f6775cefa54e15141b855d037eafb8d9'
ARCHIVE_BASE_FR_OLDPATH_0_SIZE='1100000'
ARCHIVE_BASE_FR_OLDPATH_0_VERSION='1.1-gog2.1.0.15'

ARCHIVE_DOC_L10N_PATH='.'
ARCHIVE_DOC_L10N_FILES='manual.pdf'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe launch data/savegame.exe'

ARCHIVE_GAME_L10N_PATH='.'
ARCHIVE_GAME_L10N_FILES='1031 1036 1045 2047 3082 data/configuration data/interface data/text data/levels/*.rhm data/levels/*.scb data/sounds/fx_0017.sfk data/sounds/snd_055.sfk'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='data/robinhood.bks data/robinhood.dic data/animations data/characters data/levels data/musics data/sounds'

CONFIG_FILES='./launch/settings.ini'
CONFIG_DIRS='./data/configuration'
DATA_DIRS='./data/savegame'
DATA_FILES='./campaign.bck'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='game.exe'
APP_MAIN_ICON='robin hood.exe'

PACKAGES_LIST='PKG_L10N PKG_DATA PKG_BIN'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DESCRIPTION='localization'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} ${PKG_L10N_ID} wine glx"

# Localizations

PKG_L10N_ID_EN="${PKG_L10N_ID}-en"
PKG_L10N_ID_FR="${PKG_L10N_ID}-fr"
PKG_L10N_ID_DE="${PKG_L10N_ID}-de"
PKG_L10N_ID_PL="${PKG_L10N_ID}-pl"
PKG_L10N_ID_ES="${PKG_L10N_ID}-es"

PKG_L10N_DESCRIPTION_EN="${PKG_L10N_DESCRIPTION} - English"
PKG_L10N_DESCRIPTION_FR="${PKG_L10N_DESCRIPTION} - French"
PKG_L10N_DESCRIPTION_DE="${PKG_L10N_DESCRIPTION} - German"
PKG_L10N_DESCRIPTION_PL="${PKG_L10N_DESCRIPTION} - Polish"
PKG_L10N_DESCRIPTION_ES="${PKG_L10N_DESCRIPTION} - Spanish"

# Keep compatibility with old archives

ARCHIVE_DOC_L10N_PATH_EN_OLDPATH='app'
ARCHIVE_DOC_L10N_PATH_FR_OLDPATH='app'
ARCHIVE_GAME_BIN_PATH_EN_OLDPATH='app'
ARCHIVE_GAME_BIN_PATH_FR_OLDPATH='app'
ARCHIVE_GAME_DATA_PATH_EN_OLDPATH='app'
ARCHIVE_GAME_DATA_PATH_FR_OLDPATH='app'

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

# Hide innoextract warnings
# « Warning: Ignoring OS constraint for GOG Galaxy file goggame-1207659008.hashdb: win81# »
extract_data_from "$SOURCE_ARCHIVE" 2>/dev/null
prepare_package_layout

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
