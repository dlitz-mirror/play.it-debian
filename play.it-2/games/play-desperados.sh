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
# Desperados: Wanted Dead or Alive
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200616.1

# Set game-specific variables

GAME_ID='desperados'
GAME_NAME='Desperados: Wanted Dead or Alive'

ARCHIVES_LIST='
ARCHIVE_NATIVE_GOG_1
ARCHIVE_NATIVE_GOG_0
ARCHIVE_WINDOWS_GOG_0
'

ARCHIVE_NATIVE_GOG_1='desperados_wanted_dead_or_alive_en_1_0_2_thqn_22430.sh'
ARCHIVE_NATIVE_GOG_1_URL='https://www.gog.com/game/desperados_wanted_dead_or_alive'
ARCHIVE_NATIVE_GOG_1_TYPE='mojosetup'
ARCHIVE_NATIVE_GOG_1_MD5='c4338cd7526dc01eef347408368f6bf4'
ARCHIVE_NATIVE_GOG_1_VERSION='1.0.2-gog22430'
ARCHIVE_NATIVE_GOG_1_SIZE='2000000'

ARCHIVE_NATIVE_GOG_0='desperados_wanted_dead_or_alive_en_gog_1_22137.sh'
ARCHIVE_NATIVE_GOG_0_TYPE='mojosetup'
ARCHIVE_NATIVE_GOG_0_MD5='72e623355b7ca5ccdef0c549d0a77192'
ARCHIVE_NATIVE_GOG_0_VERSION='1.0-gog22137'
ARCHIVE_NATIVE_GOG_0_SIZE='2000000'

ARCHIVE_WINDOWS_GOG_0='setup_desperados_wanted_dead_or_alive_2.0.0.6.exe'
ARCHIVE_WINDOWS_GOG_0_MD5='8e2f4e2ade9e641fdd35a9dd36d55d00'
ARCHIVE_WINDOWS_GOG_0_VERSION='1.01-gog2.0.0.6'
ARCHIVE_WINDOWS_GOG_0_SIZE='810000'

# native Linux engine
ARCHIVE_DOC0_DATA_PATH_NATIVE='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES_NATIVE='*'
ARCHIVE_DOC1_DATA_PATH_NATIVE='data/noarch/game'
ARCHIVE_DOC1_DATA_FILES_NATIVE='readme.txt'

ARCHIVE_GAME_BIN_PATH_NATIVE='data/noarch/game'
ARCHIVE_GAME_BIN_FILES_NATIVE='desperados32 libdbus-1.so.3'

ARCHIVE_GAME_DATA_PATH_NATIVE='data/noarch/game'
ARCHIVE_GAME_DATA_FILES_NATIVE='bootmenu data demo localisation localisation_demo shaders'

# Windows engine
ARCHIVE_DOC_DATA_PATH_WINDOWS='app'
ARCHIVE_DOC_DATA_FILES_WINDOWS='manual.pdf readme.txt'

ARCHIVE_GAME_BIN_PATH_WINDOWS='app/game'
ARCHIVE_GAME_BIN_FILES_WINDOWS='*.dll *.exe'

ARCHIVE_GAME_DATA_PATH_WINDOWS='app/game'
ARCHIVE_GAME_DATA_FILES_WINDOWS='data'

# User files diversion is only required by the Windows version
CONFIG_DIRS_WINDOWS='./data/configuration'
DATA_DIRS_WINDOWS='./data/savegame ./data/levels/briefing/Restart'

APP_NATIVE_TYPE='native'
APP_NATIVE_LIBS='.'
APP_NATIVE_EXE='desperados32'
APP_NATIVE_ICON='data/noarch/support/icon.png'

APP_WINE_TYPE='wine'
APP_WINE_EXE='game.exe'
APP_WINE_ICON='game.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

# binaries package using native Linux engine
PKG_BIN_ARCH_NATIVE='32'
PKG_BIN_DEPS_NATIVE="$PKG_DATA_ID glibc libstdc++ glx sdl2"
PKG_BIN_DEPS_ARCH_NATIVE='lib32-dbus'
PKG_BIN_DEPS_DEB_NATIVE='libdbus-1-3'
PKG_BIN_DEPS_GENTOO_NATIVE='' # TODO

# binaries package using Windows engine
PKG_BIN_ARCH_WINDOWS='32'
PKG_BIN_DEPS_WINDOWS="$PKG_DATA_ID wine"

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

# Extract icons

case "$ARCHIVE" in
	('ARCHIVE_WINDOWS'*)
		PKG='PKG_BIN'
		icons_get_from_package 'APP_WINE'
		icons_move_to 'PKG_DATA'
	;;
	('ARCHIVE_NATIVE_'*)
		PKG='PKG_DATA'
		icons_get_from_workdir 'APP_NATIVE'
	;;
esac
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
case "$ARCHIVE" in
	('ARCHIVE_WINDOWS_'*)
		use_archive_specific_value 'CONFIG_DIRS'
		use_archive_specific_value 'DATA_DIRS'
		APPLICATION='APP_WINE'
	;;
	('ARCHIVE_NATIVE_'*)
		unset CONFIG_DIRS
		unset DATA_DIRS
		APPLICATION='APP_NATIVE'
	;;
esac
launchers_write "$APPLICATION"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
