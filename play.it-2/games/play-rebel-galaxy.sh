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
# Rebel Galaxy
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210519.2

# Set game-specific variables

GAME_ID='rebel-galaxy'
GAME_NAME='Rebel Galaxy'

ARCHIVE_BASE_0='setup_rebel_galaxy_1.08(hotifx2)_(23097).exe'
ARCHIVE_BASE_0_MD5='9746494be23b83bc2a44d8da6cb6e311'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_PART1='setup_rebel_galaxy_1.08(hotifx2)_(23097)-1.bin'
ARCHIVE_BASE_0_PART1_MD5='e8e5d4450b5ad8f9cc757cc4153ba13c'
ARCHIVE_BASE_0_PART1_TYPE='innosetup'
ARCHIVE_BASE_0_VERSION='1.08-gog23097'
ARCHIVE_BASE_0_SIZE='2500000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/rebel_galaxy'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.cfg *.dll *.exe __redist/msvc2012/vcredist_x86.exe'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='media music paks video'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='rebelgalaxygog.exe'
APP_MAIN_ICON='rebelgalaxygog.exe'

APP_SETTINGS_ID="${GAME_ID}-settings"
APP_SETTINGS_NAME="${GAME_NAME} - Settings"
APP_SETTINGS_CAT='Settings'
APP_SETTINGS_TYPE='wine'
APP_SETTINGS_EXE='goglauncher.exe'
APP_SETTINGS_ICON='goglauncher.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine glx"

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

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_SETTINGS'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Use persistent storage for user data

APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"'
userdata:users/${USER}/My Documents/My Games/Double Damage Games/RebelGalaxy'
DATA_DIRS="${DATA_DIRS} ./userdata"

# Generate minimal settings file
# The game will crash on launch when trying to run it with Direct3D11

settings_file="$(package_get_path 'PKG_BIN')${PATH_GAME}/userdata/local_settings.txt"
mkdir --parents "$(dirname "$settings_file")"
cat > "$settings_file" << EOF
[SETTINGS]
	<INTEGER>OPENGL:1
	<INTEGER>DX11:0
[/SETTINGS]
EOF

# Microsoft Visual C++ 2012 Runtime is required by the settings window

APP_SETTINGS_PRERUN="$APP_SETTINGS_PRERUN"'

# Microsoft Visual C++ 2012 Runtime is required by the settings window
if [ ! -e vcrun2012_installed ]; then
	wine __redist/msvc2012/vcredist_x86.exe
	touch vcrun2012_installed
fi'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_SETTINGS'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
