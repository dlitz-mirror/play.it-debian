#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
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
# Nonsense at Nightfall
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210401.1

# Set game-specific variables

GAME_ID='nonsense-at-nightfall'
GAME_NAME='Nonsense at Nightfall'

ARCHIVE_ITCH='Nonsense at Nightfall.zip'
ARCHIVE_ITCH_URL='https://siegfriedcroes.itch.io/nonsense-at-nightfall'
ARCHIVE_ITCH_MD5='0fc2ea596776428f659a15acfb20dba6'
ARCHIVE_ITCH_SIZE='41000'
ARCHIVE_ITCH_VERSION='1.0-itch'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='Nonsense?at?Nightfall.exe Nonsense?at?Nightfall_Data/Managed MonoBleedingEdge UnityCrashHandler32.exe UnityPlayer.dll'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='Nonsense?at?Nightfall_Data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='Nonsense at Nightfall.exe'
APP_MAIN_ICON='Nonsense at Nightfall.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Load common functions

target_version='2.12'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
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
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Use persistent storage for game settings

REGISTRY_KEY='HKEY_CURRENT_USER\Software\Siegfried Croes\Nonsense at Nightfall'
REGISTRY_DUMP='registry-dumps/settings.reg'

CONFIG_DIRS="${CONFIG_DIRS} ./$(dirname "$REGISTRY_DUMP")"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN

# Set path for persistent dump of registry keys
REGISTRY_KEY='$REGISTRY_KEY'
REGISTRY_DUMP='$REGISTRY_DUMP'"

APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'

# Dump registry keys
regedit -E "$REGISTRY_DUMP" "$REGISTRY_KEY"'

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Load dump of registry keys
if [ -e "$REGISTRY_DUMP" ]; then
	wine regedit.exe "$REGISTRY_DUMP"
fi'

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
