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
# The Pedestrian
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200818.1

# Set game-specific variables

GAME_ID='the-pedestrian'
GAME_NAME='The Pedestrian'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='the_pedestrian_1_0_9_36404.sh'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/the_pedestrian'
ARCHIVE_GOG_0_MD5='8c57947cdd3e1384024bceb508ec36ac'
ARCHIVE_GOG_0_SIZE='2000000'
ARCHIVE_GOG_0_VERSION='1.0.9-gog36404'
ARCHIVE_GOG_0_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='ThePed_Linux_64.x86_64 ThePed_Linux_64_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='ThePed_Linux_64_Data UserData'

DATA_DIRS='./logs ./UserData'

APP_MAIN_TYPE='native'
# Work around screen resolution detection issues
# shellcheck disable=SC2016
APP_MAIN_PRERUN='config_file="$HOME/.config/unity3d/Skookum Arts/The Pedestrian/prefs"
if [ ! -e "$config_file" ]; then
	mkdir --parents "${config_file%/*}"
	resolution=$(xrandr | awk "/\*/ {print $1}")
	cat > "$config_file" <<- EOF
	<unity_prefs version_major="1" version_minor="1">
	        <pref name="Screenmanager Resolution Height" type="int">${resolution%x*}</pref>
	        <pref name="Screenmanager Resolution Width" type="int">${resolution#*x}</pref>
	</unity_prefs>
	EOF
fi'
APP_MAIN_PRERUN='export LANG=C'
APP_MAIN_EXE_BIN='ThePed_Linux_64.x86_64'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='ThePed_Linux_64_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx libxrandr alsa xrandr"
PKG_BIN_DEPS_ARCH='lib32-libx11 lib32-libxext'
PKG_BIN_DEPS_DEB='libx11-6, libxext6'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11[abi_x86_32] x11-libs/libXext[abi_x86_32]'

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
