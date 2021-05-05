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

script_version=20210505.1

# Set game-specific variables

GAME_ID_COMMON='heroes-chronicles'
GAME_NAME_COMMON='Heroes Chronicles'

GAME_ID="${GAME_ID_COMMON}-7"
GAME_NAME="${GAME_NAME_COMMON}: Chapter 7 - Revolt of the Beastmasters"

ARCHIVES_LIST='
ARCHIVE_BASE_0'

ARCHIVE_BASE_0='setup_heroes_chronicles_chapter7_2.1.0.42.exe'
ARCHIVE_BASE_0_MD5='07c189a731886b2d3891ac1c65581d40'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_VERSION='1.0-gog2.1.0.42'
ARCHIVE_BASE_0_SIZE='500000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/heroes_chronicles_all_chapters'

ARCHIVE_DOC_DATA_PATH='app/revolt of the beastmasters'
ARCHIVE_DOC_DATA_FILES='*.pdf *.txt'

ARCHIVE_DOC_COMMON_PATH='tmp'
ARCHIVE_DOC_COMMON_FILES='*.txt'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*/*.asi */*.exe */*.dll'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='*/data */maps'

ARCHIVE_GAME_COMMON_PATH='app'
ARCHIVE_GAME_COMMON_FILES='data mp3'

DATA_DIRS='./revolt?of?the?beastmasters/games ./revolt?of?the?beastmasters/maps'
DATA_FILES='./data/*.lod ./revolt?of?the?beastmasters/data/*.lod'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='revolt of the beastmasters/beastmaster.exe'
APP_MAIN_ICON='revolt of the beastmasters/beastmaster.exe'

PACKAGES_LIST='PKG_COMMON PKG_DATA PKG_BIN'

PKG_COMMON_ID="${GAME_ID_COMMON}-common"
PKG_COMMON_DESCRIPTION='common files'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DEPS="$PKG_COMMON_ID"

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine"

# iconv is used during .reg files generation

SCRIPT_DEPS="${SCRIPT_DEPS} iconv"

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

# Allow to skip intro video on first launch
# Sets default game settings

registry_file='registry-dumps/init.reg'
registry_file_path="${PKG_BIN_PATH}${PATH_GAME}/${registry_file}"

APP_REGEDIT="${APP_REGEDIT} ${registry_file}"

mkdir --parents "$(dirname "$registry_file_path")"
cat > "$registry_file_path" << EOF
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\\Software\\New World Computing\\Heroes Chronicles\\Beastmaster]
"Animate SpellBook"=dword:00000001
"AppPath"="C:\\\\${GAME_ID}\\\\revolt of the beastmasters\\\\"
"Autosave"=dword:00000001
"Bink Video"=dword:00000000
"Blackout Computer"=dword:00000000
"Combat Army Info Level"=dword:00000000
"Combat Auto Creatures"=dword:00000001
"Combat Auto Spells"=dword:00000001
"Combat Ballista"=dword:00000001
"Combat Catapult"=dword:00000001
"Combat First Aid Tent"=dword:00000001
"Combat Shade Level"=dword:00000000
"Combat Speed"=dword:00000000
"Computer Walk Speed"=dword:00000003
"First Time"=dword:00000000
"Last Music Volume"=dword:00000005
"Last Sound Volume"=dword:00000005
"Main Game Full Screen"=dword:00000001
"Main Game Show Menu"=dword:00000001
"Main Game X"=dword:0000000a
"Main Game Y"=dword:0000000a
"Move Reminder"=dword:00000001
"Music Volume"=dword:00000005
"Quick Combat"=dword:00000000
"Show Combat Grid"=dword:00000000
"Show Combat Mouse Hex"=dword:00000000
"Show Intro"=dword:00000001
"Show Route"=dword:00000001
"Sound Volume"=dword:00000005
"Test Blit"=dword:00000000
"Test Decomp"=dword:00000000
"Test Read"=dword:00000000
"Town Outlines"=dword:00000001
"Video Subtitles"=dword:00000001
"Walk Speed"=dword:00000002
"Window Scroll Speed"=dword:00000001
EOF

iconv --from-code=UTF-8 --to-code=UTF-16 --output="$registry_file_path" "$registry_file_path"

# Run the game binary from its parent directory

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Run the game binary from its parent directory
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'

# Create directories used for persistent user data storage

mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/revolt of the beastmasters/games"
mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/revolt of the beastmasters/maps"

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
