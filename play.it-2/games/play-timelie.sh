#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c)      2021, Daguhh
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
# Timelie
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210709.9

# Set game-specific variables

GAME_ID='timelie'
GAME_NAME='Timelie'

ARCHIVE_BASE_0='setup_timelie_1.1.0_(64bit)_(41792).exe'
ARCHIVE_BASE_0_MD5='7786ab76c953fda21ee196a69ad2b4ee'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_VERSION='1.1.0-gog41792'
ARCHIVE_BASE_0_SIZE='1400000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/timelie'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe timelie_data/plugins'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='timelie_data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='timelie.exe'
APP_MAIN_ICON='timelie.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

# Use persistent storage for saved games

APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"'
userdata:users/${USER}/AppData/LocalLow/Urnique Studio/Timelie'
DATA_FILES="$DATA_FILES userdata/game.sav"

# Use persistent storage for game settings

REGISTRY_KEY='HKEY_CURRENT_USER\Software\Urnique Studio\Timelie'
REGISTRY_DUMP='registry-dumps/settings.reg'

CONFIG_DIRS="${CONFIG_DIRS} ./$(dirname "$REGISTRY_DUMP")"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Set path for persistent dump of registry keys
REGISTRY_KEY="'"$REGISTRY_KEY"'"
REGISTRY_DUMP="'"$REGISTRY_DUMP"'"

# Load dump of registry keys
if [ -e "$REGISTRY_DUMP" ]; then
	wine regedit.exe "$REGISTRY_DUMP"
fi'
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'

# Dump registry keys
wine regedit.exe -E "$REGISTRY_DUMP" "$REGISTRY_KEY"'

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

# Enable dxvk patches in the WINE prefix

# shellcheck disable=SC1004
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Install dxvk on first launch
if [ ! -e dxvk_installed ]; then
	# Wait until the WINE prefix creation is complete
	printf "Waiting for the WINE prefix initialization to complete, it might take a couple seconds…\n"
	while [ ! -f "$WINEPREFIX/system.reg" ]; do
		sleep 1s
	done

	if \
		command -v dxvk-setup >/dev/null 2>&1 && \
		command -v wine-development >/dev/null 2>&1
	then
		dxvk-setup install --development
		touch dxvk_installed
	elif command -v winetricks >/dev/null 2>&1; then
		winetricks dxvk
		touch dxvk_installed
	else
		message="\\033[1;33mWarning:\\033[0m\\n"
		message="${message}DXVK patches could not be installed in the WINE prefix.\\n"
		message="${message}The game might run with display or performance issues.\\n"
		printf "\\n${message}\\n"
	fi

	# Wait a bit to ensure there is no lingering wine process
	sleep 1s
fi'
case "$OPTION_PACKAGE" in
	('deb')
		# Debian-based distributions should use repositories-provided dxvk
		# winetricks is used as a fallback for branches not having access to dxvk-setup
		extra_dependencies='mesa-vulkan-drivers | vulkan-icd, dxvk-wine64-development | winetricks, dxvk | winetricks'
		if [ -n "$PKG_BIN_DEPS_DEB" ]; then
			PKG_BIN_DEPS_DEB="${PKG_BIN_DEPS_DEB}, ${extra_dependencies}"
		else
			PKG_BIN_DEPS_DEB="$extra_dependencies"
		fi
	;;
	(*)
		# Default is to use winetricks
		PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Delete temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
