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
# Heroes Chronicles
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210418.5

# Set game-specific variables

GAME_ID_COMMON='heroes-chronicles'
GAME_NAME_COMMON='Heroes Chronicles'

GAME_ID="${GAME_ID_COMMON}-3"
GAME_NAME="${GAME_NAME_COMMON}: Chapter 3 - Masters of the Elements"

ARCHIVES_LIST='
ARCHIVE_BASE_0'

ARCHIVE_BASE_0='setup_heroes_chronicles_chapter3_2.1.0.41.exe'
ARCHIVE_BASE_0_MD5='cb21751572960d47a259efc17b92c88c'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_VERSION='1.0-gog2.1.0.41'
ARCHIVE_BASE_0_SIZE='490000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/heroes_chronicles_all_chapters'

ARCHIVE_DOC_DATA_PATH='app/masters of the elements'
ARCHIVE_DOC_DATA_FILES='*.pdf *.txt'

ARCHIVE_DOC_COMMON_PATH='tmp'
ARCHIVE_DOC_COMMON_FILES='*.txt'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*/*.asi */*.exe */*.dll'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='*/data */maps'

ARCHIVE_GAME_COMMON_PATH='app'
ARCHIVE_GAME_COMMON_FILES='data mp3'

DATA_DIRS='./masters?of?the?elements/games ./masters?of?the?elements/maps'
DATA_FILES='./data/*.lod ./masters?of?the?elements/data/*.lod'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='masters of the elements/elements.exe'
APP_MAIN_ICON='masters of the elements/elements.exe'

PACKAGES_LIST='PKG_COMMON PKG_DATA PKG_BIN'

PKG_COMMON_ID="${GAME_ID_COMMON}-common"
PKG_COMMON_DESCRIPTION='common files'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DEPS="$PKG_COMMON_ID"

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine"

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

# Set paths used for data shared between all Heroes Chronicles games

case "$OPTION_PACKAGE" in
	('arch'|'gentoo')
		PATH_DOC_COMMON="$OPTION_PREFIX/share/doc/$GAME_ID_COMMON"
		PATH_GAME_COMMON="$OPTION_PREFIX/share/$GAME_ID_COMMON"
	;;
	('deb')
		PATH_DOC_COMMON="$OPTION_PREFIX/share/doc/$GAME_ID_COMMON"
		PATH_GAME_COMMON="$OPTION_PREFIX/share/games/$GAME_ID_COMMON"
	;;
	(*)
		liberror 'OPTION_PACKAGE' "$0"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

PKG='PKG_COMMON'
organize_data 'DOC_COMMON'  "$PATH_DOC_COMMON"
organize_data 'GAME_COMMON' "$PATH_GAME_COMMON"

prepare_package_layout

# Get game icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Set up a WINE virtual desktop on first launch, using the current desktop resolution

APP_WINETRICKS="${APP_WINETRICKS} vd=\$(xrandr|awk '/\\*/ {print \$1}')"
PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks xrandr"

# Run the game binary from its parent directory

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Run the game binary from its parent directory
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'

# Create directories used for persistent user data storage

mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/masters of the elements/games"
mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/masters of the elements/maps"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Use a common directory and symbolic links to handle data shared between all Heroes Chronicles games

PKG_DATA_POSTINST_RUN="$PKG_DATA_POSTINST_RUN

# Link common files shared by the games series
for dir in data mp3; do
	if [ ! -e '${PATH_GAME}'/\$dir ]; then
		cp --force --recursive --symbolic-link --update '${PATH_GAME_COMMON}'/\$dir '${PATH_GAME}'
	fi
done"
PKG_DATA_PRERM_RUN="$PKG_DATA_PRERM_RUN

# Delete links to common files shared by the games series
for dir in data mp3; do
	if [ -e '${PATH_GAME}'/\$dir ]; then
		rm --force --recursive '${PATH_GAME}'/\$dir
	fi
done"

# Build package

write_metadata 'PKG_DATA' 'PKG_BIN'
(
	GAME_ID="$GAME_ID_COMMON"
	GAME_NAME="$GAME_NAME_COMMON"
	write_metadata 'PKG_COMMON'
)
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
