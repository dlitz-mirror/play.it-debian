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
# Torment: Tides of Numenera
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200201.1

# Set game-specific variables

GAME_ID='torment-tides-of-numenera'
GAME_NAME='Torment: Tides of Numenera'

ARCHIVE_GOG='gog_torment_tides_of_numenera_2.3.0.4.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/torment_tides_of_numenera_legacy_edition_content'
ARCHIVE_GOG_MD5='839337b42a1618f3b445f363eca210d3'
ARCHIVE_GOG_SIZE='9300000'
ARCHIVE_GOG_VERSION='1.1.0-gog2.3.0.4'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='TidesOfNumenera TidesOfNumenera_Data/Mono TidesOfNumenera_Data/Plugins'

ARCHIVE_GAME_AUDIO_PATH='data/noarch/game'
ARCHIVE_GAME_AUDIO_FILES='TidesOfNumenera_Data/StreamingAssets/Audio'

ARCHIVE_GAME_RESOURCES_PATH='data/noarch/game'
ARCHIVE_GAME_RESOURCES_FILES='TidesOfNumenera_Data/resources.assets*'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='TidesOfNumenera_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# Work around engine bugs on non-US locales
export LANG=C'
APP_MAIN_EXE='TidesOfNumenera'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='TidesOfNumenera_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_AUDIO PKG_RESOURCES PKG_DATA'

PKG_AUDIO_ID="${GAME_ID}-audio"
PKG_AUDIO_DESCRIPTION='audio'

PKG_RESOURCES_ID="${GAME_ID}-resources"
PKG_RESOURCES_DESCRIPTION='resources'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DEPS="$PKG_AUDIO_ID $PKG_RESOURCES_ID"

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx xcursor libxrandr sdl2 gtk2"
PKG_BIN_DEPS_ARCH='libx11 gdk-pixbuf2 glib2'
PKG_BIN_DEPS_DEB='libx11-6, libgdk-pixbuf2.0-0, libglib2.0-0'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11 x11-libs/gdk-pixbuf dev-libs/glib'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
