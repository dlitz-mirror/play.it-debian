#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec
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
# Giana Sisters Twisted Dreams
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200708.3

# Set game-specific variables

GAME_ID='giana-sisters-twisted-dreams'
GAME_NAME='Giana Sisters: Twisted Dreams'

ARCHIVES_LIST='
ARCHIVE_GOG_0
ARCHIVE_GOG_OLDTEMPLATE_0'

ARCHIVE_GOG_0='setup_giana_sisters_twisted_dreams_1.2.1_(19142).exe'
ARCHIVE_GOG_0_MD5='e5605f4890984375192bd37545e51ff8'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/giana_sisters_twisted_dreams'
ARCHIVE_GOG_0_VERSION='1.2.1-gog19142'
ARCHIVE_GOG_0_SIZE='2800000'

ARCHIVE_GOG_OLDTEMPLATE_0='setup_giana_sisters_twisted_dreams_2.2.0.16.exe'
ARCHIVE_GOG_OLDTEMPLATE_0_TYPE='innosetup'
ARCHIVE_GOG_OLDTEMPLATE_0_MD5='31b2a0431cfd764198834faec314f0b2'
ARCHIVE_GOG_OLDTEMPLATE_0_VERSION='1.0-gog2.2.0.16'
ARCHIVE_GOG_OLDTEMPLATE_0_SIZE='2900000'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.exe *.dll launcher'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_OLDTEMPLATE='app'

ARCHIVE_GAME0_DATA_PATH='.'
ARCHIVE_GAME0_DATA_FILES='bundles added_content data_common'
# Keep compatibility with old archives
ARCHIVE_GAME0_DATA_PATH_GOG_OLDTEMPLATE='app'

ARCHIVE_GAME1_DATA_PATH='__support/app'
ARCHIVE_GAME1_DATA_FILES='data_common'

DATA_DIRS='./userdata'

APP_WINETRICKS='xact wmp9'

APP_MAIN_TYPE='wine'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Store persistent user data outside of the game prefix
user_data_path="$WINEPREFIX/drive_c/users/$USER/My Documents/Giana Sisters - Twisted Dreams"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "$(dirname "$user_data_path")"
	mkdir --parents "$PATH_DATA/userdata"
	ln --symbolic "$PATH_DATA/userdata" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'
APP_MAIN_EXE='gsgameexe.exe'
APP_MAIN_ICON='gsgameexe.exe'

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

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary files

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
