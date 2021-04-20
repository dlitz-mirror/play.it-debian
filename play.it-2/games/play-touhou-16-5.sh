#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2018-2021, BetaRays
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
# Touhou 16.5: Hifuu Nightmare Diary ~ Violet Detector
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210420.1

# Set game-specific variables

GAME_ID='touhou-16-5'
GAME_NAME='Touhou 16.5: Hifuu Nightmare Diary ~ Violet Detector'

SCRIPT_DEPS='iconv'

ARCHIVES_LIST='ARCHIVE_DISC ARCHIVE_DISC_RAW'

ARCHIVE_DISC='violet-detector.iso'
ARCHIVE_DISC_MD5='d6198341c3c92befbeb713fdccc189e7'
ARCHIVE_DISC_VERSION='1.00a-disc'
ARCHIVE_DISC_SIZE='370000'
ARCHIVE_DISC_TYPE='iso'

ARCHIVE_DISC_RAW='violet-detector-raw.iso'
ARCHIVE_DISC_RAW_MD5='7bbcf834290e33c0bb656a43a9d39ffe'
ARCHIVE_DISC_RAW_VERSION="$ARCHIVE_DISC_VERSION"
ARCHIVE_DISC_RAW_SIZE="$ARCHIVE_DISC_SIZE"
ARCHIVE_DISC_RAW_TYPE="$ARCHIVE_DISC_TYPE"

ARCHIVE_DOC_DATA_PATH='th165'
ARCHIVE_DOC_DATA_FILES='*.txt'

ARCHIVE_GAME_BIN_PATH='th165'
ARCHIVE_GAME_BIN_FILES='*.exe'

ARCHIVE_GAME_DATA_PATH='th165'
ARCHIVE_GAME_DATA_FILES='*.dat'

DATA_DIRS='./userdata'

APP_MAIN_TYPE='wine'
APP_MAIN_PRERUN='# Use Japanese locale to avoid issues with characters display
export LANG=ja_JP.UTF-8'
# shellcheck disable=SC2016
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store saved games and settings outside of WINE prefix
user_data_path="$WINEPREFIX/drive_c/users/$USER/Application Data/ShanghaiAlice/th165"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "$(dirname "$user_data_path")"
	mkdir --parents "$PATH_DATA/userdata"
	ln --symbolic "$PATH_DATA/userdata" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'
APP_MAIN_EXE='th165.exe'
APP_MAIN_ICON='th165.exe'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_TYPE='wine'
APP_CONFIG_PRERUN="$APP_MAIN_PRERUN"
APP_CONFIG_EXE='custom.exe'
APP_CONFIG_ICON='custom.exe'
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_CAT='Settings'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"
PKG_BIN_DEPS_DEB='fonts-wqy-microhei'
PKG_BIN_DEPS_ARCH='wqy-microhei'
PKG_BIN_DEPS_GENTOO='media-fonts/wqy-microhei'
PKG_BIN_POSTINST_WARN='You may need to generate the ja_JP.UTF-8 locale to play this game'

# Ensure easy upgrade from packages generated with pre-20210420.1 scripts

PKG_BIN_PROVIDE='touhou-hifuu-nightmare-diary-violet-detector'
PKG_DATA_PROVIDE='touhou-hifuu-nightmare-diary-violet-detector-data'

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

# Convert the text files to UTF-8 encoding

if [ $DRY_RUN -eq 0 ]; then
	find "${PKG_DATA_PATH}${PATH_DOC}" -name '*.txt' -exec \
		sh -c 'contents=$(iconv --from-code CP932 --to-code UTF-8 "$1"); printf "%s" "$contents" > "$1"' -- '{}' \;
fi

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_CONFIG'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_CONFIG'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
