#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2020-2021, macaron
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
# Monkey Island 1 Special Edition: The Secret of Monkey Island
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210408.1

# Set game-specific variables

GAME_ID='monkey-island-1-special-edition'
GAME_NAME='Monkey Island 1 Special Edition: The Secret of Monkey Island'

ARCHIVE_GOG='setup_monkey_island_1_se_1.0_(18587).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_secret_of_monkey_island_special_edition'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_MD5='ff2eaa21af8f59371583b007b439b873'
ARCHIVE_GOG_SIZE='2600000'
ARCHIVE_GOG_VERSION='1.0-gog18587'
ARCHIVE_GOG_PART1='setup_monkey_island_1_se_1.0_(18587)-1.bin'
ARCHIVE_GOG_PART1_MD5='6a3ca78328b99ae0d9d0a3d7a4fb3cd9'
ARCHIVE_GOG_PART1_TYPE='innosetup'

ARCHIVE_DOC0_DATA_PATH='app'
ARCHIVE_DOC0_DATA_FILES='*.pdf'
ARCHIVE_DOC1_DATA_PATH='tmp'
ARCHIVE_DOC1_DATA_FILES='eula_*.txt'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='monkey1.pak audio localization'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='mise.exe language.exe'

APP_WINETRICKS='xact d3dx9'

APP_REGEDIT='install.reg'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='mise.exe'
APP_MAIN_ICON='mise.exe'

APP_LANGUAGE_TYPE='wine'
APP_LANGUAGE_EXE='language.exe'
APP_LANGUAGE_ID="${GAME_ID}_language"
APP_LANGUAGE_NAME="$GAME_NAME - Language setup"
APP_LANGUAGE_CAT='Settings'
APP_LANGUAGE_ICON='language.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Store user data in persistent paths

CONFIG_FILES="${CONFIG_FILES} userdata/Settings.ini"
DATA_FILES="${DATA_DILES} userdata/monkey1.bin userdata/savegame.*"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store user data in persistent paths
userdata_path_prefix="$WINEPREFIX/drive_c/users/$USER/Application Data/LucasArts/The Secret of Monkey Island Special Edition"
userdata_path_persistent="$PATH_PREFIX/userdata"
mkdir --parents "$PATH_PREFIX/userdata"
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
APP_LANGUAGE_PRERUN="$APP_MAIN_PRERUN"

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_LANGUAGE'
icons_move_to 'PKG_DATA'

# Register paths for APP_LANGUAGE

cat > "${PKG_BIN_PATH}${PATH_GAME}/install.reg" << EOF
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\\Software\\GOG.com\\Games\\1207666253]
"CONFIGPATH"="C:\\\\$GAME_ID\\\\userdata"
"PATH"="C:\\\\$GAME_ID"
"EXE"="C:\\\\$GAME_ID\\\\mise.exe"
EOF

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_LANGUAGE'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
