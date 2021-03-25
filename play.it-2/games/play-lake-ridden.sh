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
# Lake Ridden
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210413.7

# Set game-specific variables

GAME_ID='lake-ridden'
GAME_NAME='Lake Ridden'

ARCHIVES_LIST='
ARCHIVE_BASE_1
ARCHIVE_BASE_0'

ARCHIVE_BASE_1='setup_lake_ridden_1.7.1853_(64bit)_(45634).exe'
ARCHIVE_BASE_1_MD5='e5629cee62ab9e90c59a079697674fa4'
ARCHIVE_BASE_1_TYPE='innosetup'
ARCHIVE_BASE_1_SIZE='2700000'
ARCHIVE_BASE_1_VERSION='1.7.1853-gog45634'
ARCHIVE_BASE_1_URL='https://www.gog.com/game/lake_ridden'

ARCHIVE_BASE_0='setup_lake_ridden_1.6.1526_(64bit)_(25884).exe'
ARCHIVE_BASE_0_MD5='12b62c3399e51b27b5f91d9276d1aabe'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_SIZE='2100000'
ARCHIVE_BASE_0_VERSION='1.6.1526-gog25884'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe monobleedingedge lakeridden_data/plugins lakeridden_data/mono'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='lakeridden_data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='lakeridden.exe'
APP_MAIN_ICON='lakeridden.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
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
prepare_package_layout

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Use persistent storage for game settings

REGISTRY_KEY='HKEY_CURRENT_USER\Software\Midnight Hub\Lake Ridden'
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

# Use persistent storage for game progress

DATA_FILES="${DATA_FILES} ./userdata/save.json"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use persistent storage for game progress
userdata_path_prefix="$WINEPREFIX/drive_c/users/$USER/AppData/LocalLow/Midnight Hub/Lake Ridden"
userdata_path_persistent="$PATH_PREFIX/userdata"
mkdir --parents "$userdata_path_persistent"
if [ ! -h "$userdata_path_prefix" ]; then
	if [ -d "$userdata_path_prefix" ]; then
		# Migrate existing user data to the persistent path
		mv "$userdata_path_prefix"/* "$userdata_path_persistent"
		rmdir "$userdata_path_prefix"
	fi
	# Create link from prefix to persistent path
	mkdir --parents "$(dirname "$userdata_path_prefix")"
	ln --symbolic "$userdata_path_persistent" "$userdata_path_prefix"
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
