#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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
# Lo-Fi Room
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201006.4

# Set game-specific variables

GAME_ID='lo-fi-room'
GAME_NAME='Lo-Fi Room'

ARCHIVES_LIST='
ARCHIVE_ITCH_0'

ARCHIVE_ITCH_0='lofiroom.tar.xz'
ARCHIVE_ITCH_0_URL='https://bearmask.itch.io/lofi-room'
ARCHIVE_ITCH_0_MD5='c9f0f9d43e7ca81ec372784692a60432'
ARCHIVE_ITCH_0_SIZE='140000'
ARCHIVE_ITCH_0_VERSION='1.0-itch'
ARCHIVE_ITCH_0_TYPE='tar'

ARCHIVE_GAME_BIN_PATH='linux'
ARCHIVE_GAME_BIN_FILES='lofi_room_linux.x86_64 lofi_room_linux_Data/MonoBleedingEdge/x86_64 lofi_room_linux_Data/Managed lofi_room_linux_Data/Plugins'

ARCHIVE_GAME_DATA_PATH='linux'
ARCHIVE_GAME_DATA_FILES='lofi_room_linux_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# Work around Unity3D poor support for non-US locales
export LANG=C'
APP_MAIN_EXE='lofi_room_linux.x86_64'
APP_MAIN_ICON='lofi_room_linux_Data/Resources/UnityPlayer.png'
# Use a per-session dedicated file for logs
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++"

# Find the keyboard layout and changes it to qwerty if it needs to be

PKG_MAIN_DEPS_ARCH="$PKG_MAIN_DEPS_ARCH xorg-setxkbmap"
PKG_MAIN_DEPS_DEB="$PKG_MAIN_DEPS_DEB, x11-xkb-utils"
PKG_MAIN_DEPS_GENTOO="$PKG_MAIN_DEPS_GENTOO x11-apps/setxkbmap"

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Find the keyboard layout and changes it to qwerty if it needs to be
KEYBOARD_LAYOUT=$(LANG=C setxkbmap -query | sed --silent "s/^layout: *\\([^ ]\\+\\)$/\\1/p")
RESTORE_KEYMAP=0
if [ $KEYBOARD_LAYOUT = fr ]; then
	KEYBOARD_VARIANT=$(LANG=C setxkbmap -query | sed --silent "s/^variant: *\\([^ ]\\+\\)$/\\1/p")
	setxkbmap us
	RESTORE_KEYMAP=1
fi'
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'
# Restore the keyboard layout if it has been changed earlier
if [ $RESTORE_KEYMAP -eq 1 ]; then
	setxkbmap $KEYBOARD_LAYOUT -variant $KEYBOARD_VARIANT
fi'

# Load common functions

target_version='2.12'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary directories

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
