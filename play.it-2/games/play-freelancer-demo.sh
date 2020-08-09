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
# Freelancer Demo
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200710.1

# Set game-specific variables

GAME_ID='freelancer-demo'
GAME_NAME='Freelancer Demo'

ARCHIVES_LIST='
ARCHIVE_MAIN_0
'

ARCHIVE_MAIN_0='freelancer_demo.exe'
ARCHIVE_MAIN_0_URL='https://archive.org/details/freelancer_demo'
ARCHIVE_MAIN_0_MD5='1af0a4cc730a64de9f6a6ecde30edc11'
ARCHIVE_MAIN_0_TYPE='cabinet'
ARCHIVE_MAIN_0_VERSION='1.0-archiveorg1'
ARCHIVE_MAIN_0_SIZE='450000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='eula.rtf readme.rtf'

ARCHIVE_GAME0_BIN_PATH='game'
ARCHIVE_GAME0_BIN_FILES='exe/freelancer.exe'

ARCHIVE_GAME1_BIN_PATH='cab1'
ARCHIVE_GAME1_BIN_FILES='dlls exe'

ARCHIVE_GAME0_DATA_PATH='.'
ARCHIVE_GAME0_DATA_FILES='fl.ico'

ARCHIVE_GAME1_DATA_PATH='cab1'
ARCHIVE_GAME1_DATA_FILES='data'

ARCHIVE_GAME2_DATA_PATH='cab2'
ARCHIVE_GAME2_DATA_FILES='data'

ARCHIVE_FONTS_PATH='fonts'
ARCHIVE_FONTS_FILES='*.ttf'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='exe/freelancer.exe'
APP_MAIN_ICON='fl.ico'

# Store saved games and settings in persistent paths
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Store saved games and settings in persistent paths
user_data_path="$WINEPREFIX/drive_c/users/$USER/My Documents/My Games/Freelancer Trial"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "$(dirname "$user_data_path")"
	mkdir --parents "$PATH_DATA/userdata"
	ln --symbolic "$PATH_DATA/userdata" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'

# Work around messed up desktop gamma values after leaving the game
APP_MAIN_PRERUN="$APP_MAIN_PRERUN
# Store gamma values to restore them after quitting the game
rgamma=\$(xgamma 2>&1|sed 's/->//'|cut -d',' -f1|awk '{print \$2}')
ggamma=\$(xgamma 2>&1|sed 's/->//'|cut -d',' -f2|awk '{print \$2}')
bgamma=\$(xgamma 2>&1|sed 's/->//'|cut -d',' -f3|awk '{print \$2}')"
# shellcheck disable=SC2016
APP_MAIN_POSTRUN='# Restore gamma values queried before starting the game
xgamma -rgamma $rgamma -ggamma $ggamma -bgamma $bgamma'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine xgamma"

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
(
	ARCHIVE='ARCHIVE_INNER'
	ARCHIVE_INNER_TYPE='cabinet'
	for ARCHIVE_INNER in \
		"$PLAYIT_WORKDIR/gamedata/cab1.cab" \
		"$PLAYIT_WORKDIR/gamedata/cab2.cab"
	do
		extract_data_from "$ARCHIVE_INNER"
		rm "$ARCHIVE_INNER"
	done
)

# Rename files with truncated names

(
	# Skip this step in dry-run mode
	test $DRY_RUN -eq 1 && exit 0

	cd "$PLAYIT_WORKDIR/gamedata"
	mv 'game/exe/freela_1.exe' 'game/exe/freelancer.exe'
)

# Get shipped fonts

PKG='PKG_DATA'
PATH_FONTS="$OPTION_PREFIX/share/fonts/truetype/$GAME_ID"
organize_data 'FONTS' "$PATH_FONTS"

# Get game data

prepare_package_layout

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build packages

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
