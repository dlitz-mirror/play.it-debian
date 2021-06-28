#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
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
# Agatha Christie: The ABC Murders
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210628.9

# Set game-specific variables

GAME_ID='agatha-christie-the-abc-murders'
GAME_NAME='Agatha Christie: The ABC Murders'

ARCHIVE_BASE_INTL_0='gog_agatha_christie_the_abc_murders_2.2.0.4.sh'
ARCHIVE_BASE_INTL_0_MD5='271dab525be57f2783622bbbeb30c7c1'
ARCHIVE_BASE_INTL_0_TYPE='mojosetup'
ARCHIVE_BASE_INTL_0_SIZE='2700000'
ARCHIVE_BASE_INTL_0_VERSION='1.0-gog2.2.0.4'
ARCHIVE_BASE_INTL_0_URL='https://www.gog.com/game/agatha_christie_the_abc_murders'

ARCHIVE_BASE_PL_0='gog_agatha_christie_the_abc_murders_polish_2.2.0.4.sh'
ARCHIVE_BASE_PL_0_MD5='a9e8e3dcc65e651302e06abbd1446fe6'
ARCHIVE_BASE_PL_0_TYPE='mojosetup'
ARCHIVE_BASE_PL_0_SIZE='2700000'
ARCHIVE_BASE_PL_0_VERSION='1.0-gog2.2.0.4'
ARCHIVE_BASE_PL_0_URL='https://www.gog.com/game/agatha_christie_the_abc_murders'

ARCHIVE_BASE_RU_0='gog_agatha_christie_the_abc_murders_russian_2.2.0.4.sh'
ARCHIVE_BASE_RU_0_MD5='0becf882ba0e8ae4609c3e771236670c'
ARCHIVE_BASE_RU_0_TYPE='mojosetup'
ARCHIVE_BASE_RU_0_SIZE='2700000'
ARCHIVE_BASE_RU_0_VERSION='1.0-gog2.2.0.4'
ARCHIVE_BASE_RU_0_URL='https://www.gog.com/game/agatha_christie_the_abc_murders'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='The?ABC?Murders.x86 The?ABC?Murders_Data/Mono The?ABC?Murders_Data/Plugins'

ARCHIVE_GAME_L10N_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_FILES='The?ABC?Murders_Data/Managed The?ABC?Murders_Data/level* The?ABC?Murders_Data/mainData The?ABC?Murders_Data/resources.assets'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='The?ABC?Murders_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='The ABC Murders.x86'
APP_MAIN_ICON='The ABC Murders_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_L10N_ID $PKG_DATA_ID alsa glibc glu glx gtk2 libX11.so.6 libgdk_pixbuf-2.0.so.0 libglib-2.0.so.0 libstdc++ libudev1 libxrandr xcursor"

# Localizations

PKG_L10N_ID_INTL="${PKG_L10N_ID}-intl"
PKG_L10N_ID_PL="${PKG_L10N_ID}-pl"
PKG_L10N_ID_RU="${PKG_L10N_ID}-ru"

PKG_L10N_DESCRIPTION_INTL='English, French, German, Spanish, Italian and Portuguese localizations'
PKG_L10N_DESCRIPTION_PL='Polish localization'
PKG_L10N_DESCRIPTION_RU='Russian localization'

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

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

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icons

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "${PLAYIT_WORKDIR}"

# Print instructions

print_instructions

exit 0
