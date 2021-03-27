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
# Assassin’s Creed
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210331.3

# Set game-specific variables

GAME_ID='assassins-creed-1'
GAME_NAME='Assassin’s Creed'

ARCHIVE_GOG='setup_assassins_creed_1.02_v2_(28524).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/assassins_creed_directors_cut'
ARCHIVE_GOG_MD5='b14aa9508ce9653597558a6d834e2766'
ARCHIVE_GOG_SIZE='7200000'
ARCHIVE_GOG_VERSION='1.02-gog28524'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_PART1='setup_assassins_creed_1.02_v2_(28524)-1.bin'
ARCHIVE_GOG_PART1_MD5='08f2ac5b1c558483ea27c921a7d7aad7'
ARCHIVE_GOG_PART1_TYPE='innosetup'
ARCHIVE_GOG_PART2='setup_assassins_creed_1.02_v2_(28524)-2.bin'
ARCHIVE_GOG_PART2_MD5='150870977feb60c9f344e35d220e1198'
ARCHIVE_GOG_PART2_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='eula manual readme'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='assassinscreed_dx10.exe assassinscreed_dx9.exe assassinscreed_game.exe binkw32.dll eax.dll'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='*.forge defaultbindings.map resources videos'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='assassinscreed_dx9.exe'
APP_MAIN_ICON='assassinscreed_game.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
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

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Store user data in a persistent path

DATA_DIRS="${DATA_DIRS} ./userdata"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Store user data in a persistent path
userdata_path_prefix="$WINEPREFIX/drive_c/users/$USER/Application Data/Ubisoft/Assassin'\''s Creed"
userdata_path_persistent="$PATH_PREFIX/userdata"
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

# Ensure ability fo fully control the camera with the mouse
# cf. https://appdb.winehq.org/objectManager.php?sClass=version&iId=28057#notes

APP_REGEDIT="${APP_REGEDIT} registry-keys/init.reg"
REGISTRY_FILE="${PKG_BIN_PATH}${PATH_GAME}/registry-keys/init.reg"
mkdir --parents "$(dirname "$REGISTRY_FILE")"
cat > "$REGISTRY_FILE" << 'EOF'
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Wine\X11 Driver]
"GrabFullscreen"="Y"
EOF

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
