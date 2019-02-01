#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, Solène Huault
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
# Out There: Ω Edition
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181001.5

# Set game-specific variables

GAME_ID='out-there-omega-edition'
GAME_NAME='Out There: Ω Edition'

ARCHIVES_LIST='ARCHIVE_HUMBLE_LINUX ARCHIVE_HUMBLE_WINDOWS'

ARCHIVE_HUMBLE_LINUX='OutThere2-4-2Linux.zip'
ARCHIVE_HUMBLE_LINUX_URL='https://www.humblebundle.com/store/out-there-edition'
ARCHIVE_HUMBLE_LINUX_MD5='8ea51a42c9ad221e3d258e404c7106b0'
ARCHIVE_HUMBLE_LINUX_SIZE='340000'
ARCHIVE_HUMBLE_LINUX_VERSION='2.4.2-humble170213'

ARCHIVE_HUMBLE_WINDOWS='OutThere2-4-2.zip'
ARCHIVE_HUMBLE_WINDOWS_URL='https://www.humblebundle.com/store/out-there-edition'
ARCHIVE_HUMBLE_WINDOWS_MD5='8b23dde3778ade4db73a3ed76c4134cd'
ARCHIVE_HUMBLE_WINDOWS_SIZE='300000'
ARCHIVE_HUMBLE_WINDOWS_VERSION='2.4.2-humble170213'

ARCHIVE_GAME_WINDOWS_BIN_PATH='.'
ARCHIVE_GAME_WINDOWS_BIN_FILES='outthereomega.exe *_Data/Plugins *_Data/Managed *_Data/Mono'

ARCHIVE_GAME_LINUX_BIN32_PATH='.'
ARCHIVE_GAME_LINUX_BIN32_FILES='*.x86 *_Data/*/x86'

ARCHIVE_GAME_LINUX_BIN64_PATH='.'
ARCHIVE_GAME_LINUX_BIN64_FILES='*.x86_64 *_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='*_Data'

DATA_DIRS='./logs ./userdata'

APP_MAIN_TYPE_HUMBLE_LINUX='native'
APP_MAIN_TYPE_HUMBLE_WINDOWS='wine'
APP_MAIN_EXE_LINUX_BIN32='OutThereOmega.x86'
APP_MAIN_EXE_LINUX_BIN64='OutThereOmega.x86_64'
APP_MAIN_EXE_WINDOWS_BIN='outthereomega.exe'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON_HUMBLE_LINUX='OutThereOmega_Data/Resources/UnityPlayer.png'
APP_MAIN_ICON_HUMBLE_WINDOWS='outthereomega.exe'

PACKAGES_LIST_HUMBLE_LINUX='PKG_DATA PKG_LINUX_BIN32 PKG_LINUX_BIN64'
PACKAGES_LIST_HUMBLE_WINDOWS='PKG_DATA PKG_WINDOWS_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_ID_HUMBLE_LINUX="${PKG_DATA_ID}-linux"
PKG_DATA_ID_HUMBLE_WINDOWS="${PKG_DATA_ID}-windows"
PKG_DATA_PROVIDE="$PKG_DATA_ID"
PKG_DATA_DESCRIPTION='data'

PKG_LINUX_BIN32_ID="${GAME_ID}-linux"
PKG_LINUX_BIN32_ARCH='32'
PKG_LINUX_BIN32_DEPS="$PKG_DATA_ID glx xcursor libxrandr libudev1"
PKG_LINUX_BIN32_PROVIDE="$GAME_ID"

PKG_LINUX_BIN64_ID="$PKG_LINUX_BIN32_ID"
PKG_LINUX_BIN64_ARCH='64'
PKG_LINUX_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_LINUX_BIN64_PROVIDE="$GAME_ID"

PKG_WINDOWS_BIN_ID="${GAME_ID}-windows"
PKG_WINDOWS_BIN_ARCH='32'
PKG_WINDOWS_BIN_DEPS="$PKG_DATA_ID wine"
PKG_WINDOWS_BIN_PROVIDE="$GAME_ID"

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	: ${XDG_DATA_HOME:="$HOME/.local/share"}
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
. "$PLAYIT_LIB2"

# Set archive-specific variables

use_archive_specific_value 'APP_MAIN_ICON'
use_archive_specific_value 'APP_MAIN_TYPE'
use_archive_specific_value 'PACKAGES_LIST'
use_archive_specific_value 'PKG_DATA_ID'
set_temp_directories $PACKAGES_LIST

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icon

case "$ARCHIVE" in
	('ARCHIVE_HUMBLE_WINDOWS')
		PKG='PKG_WINDOWS_BIN'
		icons_get_from_package 'APP_MAIN'
		icons_move_to 'PKG_DATA'
	;;
esac

# Write launchers

case "$ARCHIVE" in
	('ARCHIVE_HUMBLE_LINUX')
		for PKG in 'PKG_LINUX_BIN32' 'PKG_LINUX_BIN64'; do
			write_launcher 'APP_MAIN'
		done
	;;
	('ARCHIVE_HUMBLE_WINDOWS')
		PKG='PKG_WINDOWS_BIN'
		write_launcher 'APP_MAIN'
	;;
esac

# Store saved games outside of WINE prefix

case "$ARCHIVE" in
	('ARCHIVE_HUMBLE_WINDOWS')
		saves_path='$WINEPREFIX/drive_c/users/$(whoami)/Local Settings/Application Data/MiClos Studio/OutThereOmegaEdition'
		pattern='s#init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"#&'
		pattern="$pattern\\nif [ ! -e \"$saves_path\" ]; then"
		pattern="$pattern\\n\\tmkdir --parents \"${saves_path%/*}\""
		pattern="$pattern\\n\\tln --symbolic \"\$PATH_DATA/userdata\" \"$saves_path\""
		pattern="$pattern\\nfi#"
		sed --in-place "$pattern" "${PKG_WINDOWS_BIN_PATH}${PATH_BIN}"/*
	;;
esac

# Build package

case "$ARCHIVE" in
	('ARCHIVE_HUMBLE_LINUX')
		PKG='PKG_DATA'
		icons_linking_postinst 'APP_MAIN'
		write_metadata 'PKG_DATA'
		write_metadata 'PKG_LINUX_BIN32' 'PKG_LINUX_BIN64'
	;;
	('ARCHIVE_HUMBLE_WINDOWS')
		write_metadata
	;;
esac
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
