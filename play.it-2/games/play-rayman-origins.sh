#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Rayman Origins
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200603.3

# Set game-specific variables

GAME_ID='rayman-origins'
GAME_NAME='Rayman Origins'

ARCHIVES_LIST='
ARCHIVE_GOG_0
'

ARCHIVE_GOG_0='setup_rayman_origins_1.0.32504_(18757).exe'
ARCHIVE_GOG_0_MD5='a1021275180a433cd26ccb708c03dde4'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/rayman_origins'
ARCHIVE_GOG_0_VERSION='1.0.32504-gog18757'
ARCHIVE_GOG_0_SIZE='2500000'
ARCHIVE_GOG_0_PART1='setup_rayman_origins_1.0.32504_(18757)-1.bin'
ARCHIVE_GOG_0_PART1_MD5='813c51f290371869157b62b26abad411'
ARCHIVE_GOG_0_PART1_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='app/support'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe *.ini'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='gamedata'

CONFIG_FILES='./*.ini'

# d3dcompiler_47 - Work around rendering issues making the game menu unusable
APP_WINETRICKS='d3dcompiler_47'

APP_MAIN_TYPE='wine'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Store user data outside of WINE prefix
user_data_path="$WINEPREFIX/drive_c/users/$USER/My Documents/My Games/Rayman Origins"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "$(dirname "$user_data_path")"
	mkdir --parents "$PATH_DATA/userdata"
	ln --symbolic "$PATH_DATA/userdata" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'
APP_MAIN_EXE='rayman origins.exe'
APP_MAIN_ICON='rayman origins.exe'

APP_L10N_ID="${GAME_ID}_language-setup"
APP_L10N_NAME="$GAME_NAME - Language setup"
APP_L10N_CAT='Settings'
APP_L10N_TYPE='wine'
APP_L10N_EXE='language_setup.exe'
APP_L10N_ICON='rayman origins.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks"

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_L10N'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_L10N'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
