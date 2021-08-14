#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Into the Breach
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210227.1

# Set game-specific variables

GAME_ID='into-the-breach'
GAME_NAME='Into the Breach'

ARCHIVES_LIST='
ARCHIVE_HUMBLE_1
ARCHIVE_HUMBLE_0
ARCHIVE_GOG_1
'

ARCHIVE_HUMBLE_1='Into_the_Breach_Linux.1.2.23.zip'
ARCHIVE_HUMBLE_1_MD5='35cbc7ad39661ac97f41760f77f71fab'
ARCHIVE_HUMBLE_1_URL='https://www.humblebundle.com/store/into-the-breach'
ARCHIVE_HUMBLE_1_SIZE='320000'
ARCHIVE_HUMBLE_1_VERSION='1.2.23-humble200515'

ARCHIVE_HUMBLE_0='Into_the_Breach_Linux.1.2.20.zip'
ARCHIVE_HUMBLE_0_MD5='5a8b33e1ccbc2953c99aacf0ad38ca37'
ARCHIVE_HUMBLE_0_SIZE='320000'
ARCHIVE_HUMBLE_0_VERSION='1.2.20-humble200420'

ARCHIVE_GOG_1='into_the_breach_1_2_24_38624.sh'
ARCHIVE_GOG_1_MD5='dbc8142ec1da82284b7959a48b50d512'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/into_the_breach'
ARCHIVE_GOG_1_SIZE='320000'
ARCHIVE_GOG_1_VERSION='1.2.24-gog38624'
ARCHIVE_GOG_1_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='Into the Breach'
ARCHIVE_DOC_DATA_FILES='licenses'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_HUMBLE_0='Into the Breach Linux'
ARCHIVE_DOC_DATA_PATH_GOG='data/noarch/game'

ARCHIVE_GAME_BIN_PATH='Into the Breach'
ARCHIVE_GAME_BIN_FILES='Breach linux_x64/libfmod.so.10 linux_x64/libfmodstudio.so.10'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_HUMBLE_0='Into the Breach Linux'
ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'

ARCHIVE_GAME_DATA_PATH='Into the Breach'
ARCHIVE_GAME_DATA_FILES='data maps resources scripts shadersOGL'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_HUMBLE_0='Into the Breach Linux'
ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'

# Optional icons pack, downloadable from ./play.it server

ARCHIVE_OPTIONAL_ICONS='into-the-breach_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_MD5='ce72ae946c4708feabb324493dc197b1'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/games/into-the-breach/'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='*'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='linux_x64'
APP_MAIN_EXE='Breach'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ sdl2 glx"

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

# Load optional archives

###
# TODO
# Warning about missing optional archive should be handled by the library
###
ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
ARCHIVE="$ARCHIVE_MAIN"
if [ -z "$ARCHIVE_ICONS" ]; then
	case "${LANG%_*}" in
		('fr')
			message='Lʼarchive suivante nʼayant pas été fournie, le lanceur pour ce jeu nʼutilisera pas dʼicône spécifique : %s\n'
			message="$message"'Cette archive peut être téléchargée depuis %s\n'
		;;
		('en'|*)
			message='Due to the following archive missing, the game launcher will not use a specific icon: %s\n'
			message="$message"'This archive can be downloaded from %s\n'
		;;
	esac
	print_warning
	printf "$message" "$ARCHIVE_OPTIONAL_ICONS" "$ARCHIVE_OPTIONAL_ICONS_URL"
	printf '\n'
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include game icons

if [ -n "$ARCHIVE_ICONS" ]; then
	PKG='PKG_DATA'
	ARCHIVE_MAIN="$ARCHIVE"
	ARCHIVE='ARCHIVE_ICONS'
	extract_data_from "$ARCHIVE_ICONS"
	ARCHIVE="$ARCHIVE_MAIN"
	organize_data 'ICONS' "$PATH_ICON_BASE"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

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
