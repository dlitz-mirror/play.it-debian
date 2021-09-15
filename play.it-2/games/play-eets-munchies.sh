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
# Eets Munchies
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210716.5

# Set game-specific variables

GAME_ID='eets-munchies'
GAME_NAME='Eets Munchies'

ARCHIVE_BASE_32BIT_0='eets2-32x_linux_1394496804.tar'
ARCHIVE_BASE_32BIT_0_MD5='cdbae24ea2579ff9169f2b3d68be8a09'
ARCHIVE_BASE_32BIT_0_SIZE='740000'
ARCHIVE_BASE_32BIT_0_VERSION='1.0-humble.2014.03.10'
ARCHIVE_BASE_32BIT_0_URL='https://www.humblebundle.com/store/eets-munchies'

ARCHIVE_BASE_64BIT_0='eets2-64x_linux_1394496804.tar'
ARCHIVE_BASE_64BIT_0_MD5='ee7694ca24aabb4c3890123f8cb2474e'
ARCHIVE_BASE_64BIT_0_SIZE='740000'
ARCHIVE_BASE_64BIT_0_VERSION='1.0-humble.2014.03.10'
ARCHIVE_BASE_64BIT_0_URL='https://www.humblebundle.com/store/eets-munchies'

ARCHIVE_GAME_BIN_PATH='eets2'
ARCHIVE_GAME_BIN_FILES='bin/eets2-bin bin/lib/libfmodevent*-4.44.18.so bin/lib/libfmodex*-4.44.18.so'

ARCHIVE_GAME_DATA_PATH='eets2'
ARCHIVE_GAME_DATA_FILES='*.json *.kwad *.lua *.png *.xpm Data'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='bin/lib'
APP_MAIN_EXE='bin/eets2-bin'
APP_MAIN_ICON='eets2.xpm'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH_32BIT='32'
PKG_BIN_ARCH_64BIT='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx libSDL2-2.0.so.0"

# Divert saved games and settings to XDG-compliant paths
# This prevents the creation of a hidden directory at the top level in $HOME

CONFIG_FILES="$CONFIG_FILES ./settings.ini"
DATA_DIRS="$DATA_DIRS ./profiles"

# shellcheck disable=SC1004
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Divert saved games and settings to XDG-compliant paths
# This prevents the creation of a hidden directory at the top level in $HOME

# Skip this operation if the hidden directory already exists
if [ ! -e "${HOME}/.keli/eets2" ]; then
	FAKE_HOME="${PATH_PREFIX}/fake-home"
	mkdir --parents "${FAKE_HOME}/.local"
	ln --force --no-target-directory --symbolic \
		"${XDG_CACHE_HOME:=$HOME/.cache}" \
		"${FAKE_HOME}/.cache"
	ln --force --no-target-directory --symbolic \
		"${XDG_CONFIG_HOME:=$HOME/.config}" \
		"${FAKE_HOME}/.config"
	ln --force --no-target-directory --symbolic \
		"${XDG_DATA_HOME:=$HOME/.local/share}" \
		"${FAKE_HOME}/.local/share"
	HOME="$FAKE_HOME"
	export XDG_CACHE_HOME XDG_CONFIG_HOME XDG_DATA_HOME HOME

	# Migrate user data to the diverted paths
	divert_path() {
		# shellcheck disable=SC2039
		local path_original path_diverted
		path_original="$1"
		path_diverted="$2"
		if [ -e "$path_original" ] && [ ! -h "$path_original" ]; then
			mv --no-target-directory "$path_original" "$(realpath "$path_diverted")"
		fi
		if [ -e "$path_diverted" ]; then
			mkdir --parents "$(dirname "$path_original")"
			ln --force --no-target-directory --symbolic "$path_diverted" "$path_original"
		fi
		return 0
	}
	divert_path \
		"${HOME}/.klei/eets2/settings.ini" \
		"${PATH_PREFIX}/settings.ini"
	divert_path \
		"${HOME}/.klei/eets2/profiles" \
		"${PATH_PREFIX}/profiles"
fi'

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
prepare_package_layout

# Get game icon

PKG='PKG_DATA'
icon_path_xpm="$(package_get_path "$PKG")${PATH_GAME}/${APP_MAIN_ICON}"
icon_path_png=${icon_path_xpm%.xpm}.png
convert "$icon_path_xpm" "$icon_path_png"
APP_MAIN_ICON=${APP_MAIN_ICON%.xpm}.png
icons_get_from_package 'APP_MAIN'
rm "$icon_path_png"

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
