#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Wayward Manor
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210519.3

# Set game-specific variables

GAME_ID='wayward-manor'
GAME_NAME='Wayward Manor'

# The inner archive is based on InnoSetup

SCRIPT_DEPS='innoextract'

ARCHIVE_BASE_0='WaywardManorWin78Version1.01.zip'
ARCHIVE_BASE_0_MD5='1a832bc0fbf67f5c4675f47988ec2243'
ARCHIVE_BASE_0_TYPE='zip'
ARCHIVE_BASE_0_SIZE='2500000'
ARCHIVE_BASE_0_VERSION='1.01-humble.2014.07.24'
ARCHIVE_BASE_0_URL='https://www.humblebundle.com/store/wayward-manor'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='waywardmanor_data/mono waywardmanor_data/plugins *.dll *.exe'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='waywardmanor_data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='waywardmanor.exe'
APP_MAIN_ICON='waywardmanor.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine glx"
PKG_BIN_DEPS_ARCH='dos2unix sed'
PKG_BIN_DEPS_DEB='dos2unix, sed'
PKG_BIN_DEPS_GENTOO='app-text/dos2unix sys-apps/sed'

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
ARCHIVE_INNER="${PLAYIT_WORKDIR}/gamedata/Wayward Manor Win 7 & 8 Version 1.01/WMSetup.exe"
ARCHIVE_INNER_TYPE='innosetup'
(
	ARCHIVE='ARCHIVE_INNER'
	extract_data_from "$ARCHIVE_INNER"
)
rm "$ARCHIVE_INNER"
prepare_package_layout

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary directories

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Set up a WINE virtual desktop on first launch, using the current desktop resolution

APP_WINETRICKS="${APP_WINETRICKS} vd=\$(xrandr|awk '/\\*/ {print \$1}')"
PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks xrandr"

# Use persistent storage for registry keys
# Game progress and settings are stored in the registry

REGISTRY_KEY='HKEY_CURRENT_USER\Software\TheOddGentlemen\Wayward Manor'
REGISTRY_DUMP='registry-dumps/persistent.reg'

DATA_DIRS="${DATA_DIRS} ./$(dirname "$REGISTRY_DUMP")"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Set path for persistent dump of registry keys
REGISTRY_KEY="'"$REGISTRY_KEY"'"
REGISTRY_DUMP="'"$REGISTRY_DUMP"'"

# Load dump of registry keys
if [ -e "$REGISTRY_DUMP" ]; then
	wine regedit.exe "$REGISTRY_DUMP"
fi

# Do not exit on game failure state
# This should avoid loss of progress due to a game crash
set +o errexit'
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'

# Restore exit on failure
set -o errexit

# Dump registry keys
wine regedit.exe -E "$REGISTRY_DUMP" "$REGISTRY_KEY"

# Exclude volume settings from the dump
# These seem to always be reset to 0
dos2unix --quiet "$REGISTRY_DUMP"
expression='\''/^"_MUSIC_VOLUME__/d'\''
expression="$expression"'\'';/^"_SFX_VOLUME__/d'\''
sed --in-place --expression="$expression" "$REGISTRY_DUMP"
unix2dos --quiet "$REGISTRY_DUMP"'

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