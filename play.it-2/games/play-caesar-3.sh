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
# Caesar 3
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210213.1

# Set game-specific variables

GAME_ID='caesar-3'
GAME_NAME='Cæsar Ⅲ'

ARCHIVE_GOG='setup_caesar3_2.0.0.9.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/caesar_3'
ARCHIVE_GOG_MD5='2ee16fab54493e1c2a69122fd2e56635'
ARCHIVE_GOG_SIZE='550000'
ARCHIVE_GOG_VERSION='1.1-gog2.0.0.9'

# Julius 1.6.0 release
ARCHIVE_OPTIONAL_JULIUS_4='julius-1.6.0-linux-x86_64.zip'
ARCHIVE_OPTIONAL_JULIUS_4_URL='https://github.com/bvschaik/julius/releases/tag/v1.6.0'
ARCHIVE_OPTIONAL_JULIUS_4_MD5='2ea82121f9752c0c7624b3a70bbf5bac'
ARCHIVE_OPTIONAL_JULIUS_4_SIZE=2400

# Julius 1.5.1 release
ARCHIVE_OPTIONAL_JULIUS_3='julius-1.5.1-linux-x86_64.zip'
ARCHIVE_OPTIONAL_JULIUS_3_URL='https://github.com/bvschaik/julius/releases/tag/v1.5.1'
ARCHIVE_OPTIONAL_JULIUS_3_MD5='ff01fea442f0d68de5f705411be84ae7'
ARCHIVE_OPTIONAL_JULIUS_3_SIZE=2300

# Julius 1.5.0 release
ARCHIVE_OPTIONAL_JULIUS_2='julius-1.5.0-linux-x86_64.zip'
ARCHIVE_OPTIONAL_JULIUS_2_URL='https://github.com/bvschaik/julius/releases/tag/v1.5.0'
ARCHIVE_OPTIONAL_JULIUS_2_MD5='57392aab52e820149a0416c31f02cd17'
ARCHIVE_OPTIONAL_JULIUS_2_SIZE=2300

# Julius 1.4.1 release
ARCHIVE_OPTIONAL_JULIUS_1='julius-1.4.1-linux-x86_64.zip'
ARCHIVE_OPTIONAL_JULIUS_1_URL='https://github.com/bvschaik/julius/releases/tag/v1.4.1'
ARCHIVE_OPTIONAL_JULIUS_1_MD5='6f09868205f502b8c006d88702d6455d'
ARCHIVE_OPTIONAL_JULIUS_1_SIZE=2300

# Julius 1.4.0 release
ARCHIVE_OPTIONAL_JULIUS_0='julius-1.4.0-linux-x86_64.zip'
ARCHIVE_OPTIONAL_JULIUS_0_URL='https://github.com/bvschaik/julius/releases/tag/v1.4.0'
ARCHIVE_OPTIONAL_JULIUS_0_MD5='a686cddb59e3b89d22baf3b73fdce9ef'
ARCHIVE_OPTIONAL_JULIUS_0_SIZE=2200

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='readme.txt *.pdf'

ARCHIVE_GAME_BIN_WINE_PATH='app'
ARCHIVE_GAME_BIN_WINE_FILES='*.dll *.exe *.inf *.ini'

ARCHIVE_GAME_BIN_JULIUS_PATH='.'
ARCHIVE_GAME_BIN_JULIUS_FILES='julius'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='555 smk wavs *.555 *.emp *.eng *.map *.sg2 c3_model.txt mission1.pak'

CONFIG_FILES='./*.ini'
DATA_FILES='./c3_model.txt ./status.txt ./*.sav'

APP_WINETRICKS="vd=\$(xrandr|awk '/\\*/ {print \$1}')"

APP_WINE_TYPE='wine'
APP_WINE_EXE='c3.exe'
APP_WINE_ICON='c3.exe'

APP_JULIUS_TYPE='native'
APP_JULIUS_EXE='julius'
APP_JULIUS_ICON='c3.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN_WINE'
# This expanded packages list should be used if a Julius binary hase been provided
PACKAGES_LIST_JULIUS="$PACKAGES_LIST PKG_BIN_JULIUS"

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ID="$GAME_ID"

PKG_BIN_WINE_ID="${PKG_BIN_ID}-wine"
PKG_BIN_WINE_PROVIDE="$PKG_BIN_ID"
PKG_BIN_WINE_ARCH='32'
PKG_BIN_WINE_DEPS="$PKG_DATA_ID wine winetricks xrandr"

PKG_BIN_JULIUS_ID="${PKG_BIN_ID}-julius"
PKG_BIN_JULIUS_PROVIDE="$PKG_BIN_ID"
PKG_BIN_JULIUS_ARCH='64'
PKG_BIN_JULIUS_DEPS="$PKG_DATA_ID glibc sdl2 sdl2_mixer"

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

# Use Julius engine archive if it is available
# cf. https://github.com/bvschaik/julius

###
# TODO
# Maybe we should display a warning if no Julius engine archive could be found
###
ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_JULIUS' \
	'ARCHIVE_OPTIONAL_JULIUS_4' \
	'ARCHIVE_OPTIONAL_JULIUS_3' \
	'ARCHIVE_OPTIONAL_JULIUS_2' \
	'ARCHIVE_OPTIONAL_JULIUS_1' \
	'ARCHIVE_OPTIONAL_JULIUS_0'
ARCHIVE="$ARCHIVE_MAIN"
if [ -n "$ARCHIVE_JULIUS" ]; then
	PACKAGES_LIST="$PACKAGES_LIST_JULIUS"
	# shellcheck disable=SC2086
	set_temp_directories $PACKAGES_LIST
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
if [ -n "$ARCHIVE_JULIUS" ]; then
	(
		ARCHIVE='ARCHIVE_JULIUS'
		extract_data_from "$ARCHIVE_JULIUS"
	)
	# Enforce minimal permissions on Julius binary
	chmod 755 "$PLAYIT_WORKDIR/gamedata/julius"
fi
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon

PKG='PKG_BIN_WINE'
icons_get_from_package 'APP_WINE'
if [ -n "$ARCHIVE_JULIUS" ]; then
	icons_get_from_package 'APP_JULIUS'
fi
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN_WINE'
launchers_write 'APP_WINE'
if [ -n "$ARCHIVE_JULIUS" ]; then
	PKG='PKG_BIN_JULIUS'
	launchers_write 'APP_JULIUS'
fi

# Build package

###
# TODO
# Julius binaries package should use the engine version number
###
write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

printf '\n'
printf 'Julius:'
print_instructions 'PKG_DATA' 'PKG_BIN_JULIUS'
printf 'WINE:'
print_instructions 'PKG_DATA' 'PKG_BIN_WINE'

exit 0
