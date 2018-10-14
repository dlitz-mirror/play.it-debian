#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# Arcanum: Of Steamworks and Magick Obscura
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180819.4

# Set game-specific variables

SCRIPT_DEPS='upx'

GAME_ID='arcanum'
GAME_NAME='Arcanum: Of Steamworks and Magick Obscura'

ARCHIVE_GOG='setup_arcanum_-_of_steamworks_and_magick_obscura_1.0.7.4_(19476).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/arcanum_of_steamworks_and_magick_obscura'
ARCHIVE_GOG_MD5='298a3315baebf40f3cc6cee4acae9947'
ARCHIVE_GOG_TYPE='innosetup1.7'
ARCHIVE_GOG_SIZE='1200000'
ARCHIVE_GOG_VERSION='1.0.7.4-gog19476'

ARCHIVE_GOG_OLD0='setup_arcanum_2.0.0.15.exe'
ARCHIVE_GOG_OLD0_MD5='c09523c61edd18abb97da97463e07a88'
ARCHIVE_GOG_OLD0_SIZE='1200000'
ARCHIVE_GOG_OLD0_VERSION='1.0.7.4-gog2.0.0.15'

ARCHIVE_DOC0_DATA_PATH='.'
ARCHIVE_DOC0_DATA_FILES='./*.doc ./*.htm ./*.pdf ./*.txt ./documents'
# Keep compatibility with old archives
ARCHIVE_DOC0_DATA_PATH_GOG_OLD0='app'

ARCHIVE_DOC1_DATA_PATH='__support/app'
ARCHIVE_DOC1_DATA_FILES='./eula.*'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='./*.asi ./*.cfg ./*.exe ./*.inf ./binkw32.dll ./ddraw.dll ./mm_won.dll ./mss32.dll ./sierrapt.dll'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='./*.dat ./data ./modules'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_OLD0='app'

CONFIG_FILES='./*.cfg'
DATA_DIRS='./data ./modules/arcanum/maps ./modules/arcanum/saves'

APP_WINETRICKS="vd=\$(xrandr|grep '\*'|awk '{print \$1}')"

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='arcanum.exe'
APP_MAIN_OPTIONS='-no3d'
APP_MAIN_ICON='arcanum.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ID="$GAME_ID"
PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks xrandr"

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	for path in\
		'./'\
		"$XDG_DATA_HOME/play.it/"\
		"$XDG_DATA_HOME/play.it/play.it-2/lib/"\
		'/usr/local/share/games/play.it/'\
		'/usr/local/share/play.it/'\
		'/usr/share/games/play.it/'\
		'/usr/share/play.it/'
	do
		if [ -z "$PLAYIT_LIB2" ] && [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
	if [ -z "$PLAYIT_LIB2" ]; then
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Decompress UPX-packed executable

file="${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_EXE"
if upx -t "$file" >/dev/null 2>&1; then
	upx -d "$file" >/dev/null
fi

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
