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
# Forgotton Anne
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200709.4

# Set game-specific variables

GAME_ID='forgotton-anne'
GAME_NAME='Forgotton Anne'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='setup_forgotton_anne_5.5.3_(29552).exe'
ARCHIVE_GOG_0_MD5='2f6b17e78651f6ccc9070705b879a6ae'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/forgotton_anne'
ARCHIVE_GOG_0_VERSION='5.5.3-gog29552'
ARCHIVE_GOG_0_SIZE='9500000'
ARCHIVE_GOG_0_PART1='setup_forgotton_anne_5.5.3_(29552)-1.bin'
ARCHIVE_GOG_0_PART1_MD5='8f6e836ff3519e4759af8c51ed89655d'
ARCHIVE_GOG_0_PART1_TYPE='innosetup'
ARCHIVE_GOG_0_PART2='setup_forgotton_anne_5.5.3_(29552)-2.bin'
ARCHIVE_GOG_0_PART2_MD5='728970d510b82fc1d9d336c9e26fb8c3'
ARCHIVE_GOG_0_PART2_TYPE='innosetup'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.dll forgottonanne.exe forgottonanne_data/monobleedingedge forgottonanne_data/plugins'

ARCHIVE_GAME0_DATA_PATH='.'
ARCHIVE_GAME0_DATA_FILES='forgottonanne_data'

ARCHIVE_GAME1_DATA_PATH='app'
ARCHIVE_GAME1_DATA_FILES='forgottonanne_data'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='forgottonanne.exe'
APP_MAIN_ICON='forgottonanne.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine glx"
PKG_BIN_DEPS_ARCH='lib32-vulkan-icd-loader'
PKG_BIN_DEPS_DEB='libvulkan1'
PKG_BIN_DEPS_GENTOO='media-libs/vulkan-loader[abi_x86_32]'

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

# Enable dxvk patches in the WINE prefix

case "$OPTION_PACKAGE" in
	('deb')
		APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
		# Install dxvk on first launch
		if [ ! -e dxvk_installed ]; then
			sleep 3s
			dxvk-setup install --development
			touch dxvk_installed
		fi'
		PKG_BIN_DEPS="$PKG_BIN_DEPS dxvk-wine32-development dxvk"
	;;
	('arch'|'gentoo')
		APP_WINETRICKS="$APP_WINETRICKS dxvk"
		PKG_BIN_DEPS="$PKG_BIN_DEPS winetricks"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build packages

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
