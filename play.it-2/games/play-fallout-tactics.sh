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
# Fallout Tactics
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200926.3

# Set game-specific variables

GAME_ID='fallout-tactics'
GAME_NAME='Fallout Tactics'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0
'

ARCHIVE_GOG_EN_0='setup_fallout_tactics_2.1.0.12.exe'
ARCHIVE_GOG_EN_0_MD5='9cc1d9987d8a2fa6c1cc6cf9837758ad'
ARCHIVE_GOG_EN_0_TYPE='innosetup'
ARCHIVE_GOG_EN_0_URL='https://www.gog.com/game/fallout_tactics'
ARCHIVE_GOG_EN_0_VERSION='1.27-gog2.1.0.12'
ARCHIVE_GOG_EN_0_SIZE='1900000'

ARCHIVE_GOG_FR_0='setup_fallout_tactics_french_2.1.0.12.exe'
ARCHIVE_GOG_FR_0_MD5='520c29934290910cdeecbc7fcca68f2b'
ARCHIVE_GOG_FR_0_TYPE='innosetup'
ARCHIVE_GOG_FR_0_URL='https://www.gog.com/game/fallout_tactics'
ARCHIVE_GOG_FR_0_VERSION='1.27-gog2.1.0.12'
ARCHIVE_GOG_FR_0_SIZE='1900000'

ARCHIVE_DOC_L10N_PATH='app'
ARCHIVE_DOC_L10N_FILES='readme.txt patch?readme.txt fallout?tactics_license.rtf'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='*.pdf editor_readme.txt fallout?editor?end?user?license?agreement.txt fot_hires_readme.rtf readme.rtf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe core/*.cfg'

ARCHIVE_GAME_L10N_PATH='app'
ARCHIVE_GAME_L10N_FILES='tactics.cfg core/locale core/movie core/music/custom/readme.txt core/entities_0.bos core/gui_0.bos core/locale_0.bos core/loc-mis_*.bos core/mis-core_?.bos'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='bitmaps miles fallouttactics.ico core/missions core/tables core/user core/*.bos core/game.pck'

CONFIG_FILES='./*.cfg ./core/*.cfg'
DATA_DIRS='./core/user'
DATA_FILES='./bos.exe ./ft?tools.exe'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='bos.exe'
APP_MAIN_ICON='fallouttactics.ico'

APP_TOOLS_ID="${GAME_ID}_tools"
APP_TOOLS_NAME="$GAME_NAME - Toolbox"
APP_TOOLS_TYPE='wine'
APP_TOOLS_EXE='ft tools.exe'
APP_TOOLS_ICON='fallouttactics.ico'

APP_MAIN_RESOLUTION_ID="${GAME_ID}_hires"
APP_MAIN_RESOLUTION_NAME="$GAME_NAME - HD patch"
APP_MAIN_RESOLUTION_CAT='Settings'
APP_MAIN_RESOLUTION_TYPE='wine'
APP_MAIN_RESOLUTION_EXE='fot_hires_patch.exe'
APP_MAIN_RESOLUTION_ICON='fallouttactics.ico'

APP_TOOLS_RESOLUTION_ID="${APP_TOOLS_ID}_hires"
APP_TOOLS_RESOLUTION_NAME="$APP_TOOLS_NAME - HD patch"
APP_TOOLS_RESOLUTION_CAT='Settings'
APP_TOOLS_RESOLUTION_TYPE='wine'
APP_TOOLS_RESOLUTION_EXE='fttools_hires_patch.exe'
APP_TOOLS_RESOLUTION_ICON='fallouttactics.ico'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

# Localization - common properties
PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"

# Localization - English version
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'

# Localization - French version
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

# Arch-independent data
PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

# Binaries
PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID $PKG_L10N_ID wine"

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

# Extract game icons

PKG='PKG_DATA'
icons_get_from_package \
	'APP_MAIN' \
	'APP_MAIN_RESOLUTION' \
	'APP_TOOLS' \
	'APP_TOOLS_RESOLUTION'

# Write launchers

PKG='PKG_BIN'
launchers_write \
	'APP_MAIN' \
	'APP_MAIN_RESOLUTION' \
	'APP_TOOLS' \
	'APP_TOOLS_RESOLUTION'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
