#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2017-2020, Phil Morrell
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
# Anno 1404: Gold Edition
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200514.1

# Set game-specific variables

GAME_ID='anno-1404'
GAME_NAME='Anno 1404'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR ARCHIVE_GOG_MULTI_OLD1 ARCHIVE_GOG_MULTI_OLD0'

ARCHIVE_GOG_EN='setup_anno_1404_2.01_v2_(30326).exe'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/anno_1404_gold_edition'
ARCHIVE_GOG_EN_MD5='5b92b95ddd3a60bff25afaca6531dab3'
ARCHIVE_GOG_EN_VERSION='2.01.5010-gog30326'
ARCHIVE_GOG_EN_SIZE='4100000'
ARCHIVE_GOG_EN_PART1='setup_anno_1404_2.01_v2_(30326)-1.bin'
ARCHIVE_GOG_EN_PART1_MD5='3bf8dd4469d43392617df7737cebad04'
ARCHIVE_GOG_EN_PART1_TYPE='innosetup'

ARCHIVE_GOG_FR='setup_anno_1404_2.01_v2_(french)_(30326).exe'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/anno_1404_gold_edition'
ARCHIVE_GOG_FR_MD5='24be40c2f1ce714dcc9c505ed62fcdb2'
ARCHIVE_GOG_FR_VERSION='2.01.5010-gog30326'
ARCHIVE_GOG_FR_SIZE='4000000'
ARCHIVE_GOG_FR_PART1='setup_anno_1404_2.01_v2_(french)_(30326)-1.bin'
ARCHIVE_GOG_FR_PART1_MD5='d2bbff77601562218b62b53901edd5e7'
ARCHIVE_GOG_FR_PART1_TYPE='innosetup'

ARCHIVE_GOG_MULTI_OLD1='setup_anno_1404_gold_edition_2.01.5010_(13111).exe'
ARCHIVE_GOG_MULTI_OLD1_MD5='b19333f57c1c15b788e29ff6751dac20'
ARCHIVE_GOG_MULTI_OLD1_VERSION='2.01.5010-gog13111'
ARCHIVE_GOG_MULTI_OLD1_SIZE='6200000'
ARCHIVE_GOG_MULTI_OLD1_PART1='setup_anno_1404_gold_edition_2.01.5010_(13111)-1.bin'
ARCHIVE_GOG_MULTI_OLD1_PART1_MD5='17933b44bdb2a26d8d82ffbfdc494210'
ARCHIVE_GOG_MULTI_OLD1_PART1_TYPE='innosetup'
ARCHIVE_GOG_MULTI_OLD1_PART2='setup_anno_1404_gold_edition_2.01.5010_(13111)-2.bin'
ARCHIVE_GOG_MULTI_OLD1_PART2_MD5='2f71f5378b5f27a84a41cc481a482bd6'
ARCHIVE_GOG_MULTI_OLD1_PART2_TYPE='innosetup'

ARCHIVE_GOG_MULTI_OLD0='setup_anno_1404_2.0.0.2.exe'
ARCHIVE_GOG_MULTI_OLD0_MD5='9c48c8159edaee14aaa6c7e7add60623'
ARCHIVE_GOG_MULTI_OLD0_VERSION='2.01.5010-gog2.0.0.2'
ARCHIVE_GOG_MULTI_OLD0_SIZE='6200000'
ARCHIVE_GOG_MULTI_OLD0_TYPE='rar'
ARCHIVE_GOG_MULTI_OLD0_GOGID='1440426004'
ARCHIVE_GOG_MULTI_OLD0_PART1='setup_anno_1404_2.0.0.2-1.bin'
ARCHIVE_GOG_MULTI_OLD0_PART1_MD5='b9ee29615dfcab8178608fecaa5d2e2b'
ARCHIVE_GOG_MULTI_OLD0_PART1_TYPE='rar'
ARCHIVE_GOG_MULTI_OLD0_PART2='setup_anno_1404_2.0.0.2-2.bin'
ARCHIVE_GOG_MULTI_OLD0_PART2_MD5='eb49c917d6218b58e738dd781e9c6751'
ARCHIVE_GOG_MULTI_OLD0_PART2_TYPE='rar'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.pdf'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_MULTI_OLD1='app'
ARCHIVE_DOC_DATA_PATH_GOG_MULTI_OLD0='game'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.exe *.dll bin tools'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_MULTI_OLD1='app'
ARCHIVE_GAME_BIN_PATH_GOG_MULTI_OLD0='game'

ARCHIVE_GAME_L10N_DE_PATH='.'
ARCHIVE_GAME_L10N_DE_FILES='addon/ger0.rda maindata/ger0.rda'
# Keep compatibility with old archives
ARCHIVE_GAME_L10N_DE_PATH_GOG_MULTI_OLD1='app'
ARCHIVE_GAME_L10N_DE_PATH_GOG_MULTI_OLD0='game'

ARCHIVE_GAME_L10N_EN_PATH='.'
ARCHIVE_GAME_L10N_EN_FILES='addon/eng0.rda maindata/eng0.rda'
# Keep compatibility with old archives
ARCHIVE_GAME_L10N_EN_PATH_GOG_MULTI_OLD1='app'
ARCHIVE_GAME_L10N_EN_PATH_GOG_MULTI_OLD0='game'

ARCHIVE_GAME_L10N_ES_PATH='.'
ARCHIVE_GAME_L10N_ES_FILES='addon/esp0.rda maindata/esp0.rda'
# Keep compatibility with old archives
ARCHIVE_GAME_L10N_ES_PATH_GOG_MULTI_OLD1='app'
ARCHIVE_GAME_L10N_ES_PATH_GOG_MULTI_OLD0='game'

ARCHIVE_GAME_L10N_FR_PATH='.'
ARCHIVE_GAME_L10N_FR_FILES='addon/fra0.rda maindata/fra0.rda'
# Keep compatibility with old archives
ARCHIVE_GAME_L10N_FR_PATH_GOG_MULTI_OLD1='app'
ARCHIVE_GAME_L10N_FR_PATH_GOG_MULTI_OLD0='game'

ARCHIVE_GAME_L10N_IT_PATH='.'
ARCHIVE_GAME_L10N_IT_FILES='addon/ita0.rda maindata/ita0.rda'
# Keep compatibility with old archives
ARCHIVE_GAME_L10N_IT_PATH_GOG_MULTI_OLD1='app'
ARCHIVE_GAME_L10N_IT_PATH_GOG_MULTI_OLD0='game'

ARCHIVE_GAME0_DATA_PATH='.'
ARCHIVE_GAME0_DATA_FILES='addon data maindata resources'
# Keep compatibility with old archives
ARCHIVE_GAME0_DATA_PATH_GOG_MULTI_OLD1='app'
ARCHIVE_GAME0_DATA_PATH_GOG_MULTI_OLD0='game'

ARCHIVE_GAME1_DATA_PATH='__support/add'
ARCHIVE_GAME1_DATA_FILES='engine.ini'
# Keep compatibility with old archives
ARCHIVE_GAME1_DATA_PATH_GOG_MULTI_OLD1='app/__support/add'
ARCHIVE_GAME1_DATA_PATH_GOG_MULTI_OLD0='game'

ARCHIVE_REDIST_PATH='tmp'
ARCHIVE_REDIST_FILES='directx_jun2010_redist.exe'

DATA_DIRS='./userdata'

# For old multi-languages GOG installers, the winetricks call is handled in pre-run
APP_WINETRICKS='d3dx9'

APP_MAIN_TYPE='wine'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Store user data outside of WINE prefix
user_data_path="$WINEPREFIX/drive_c/users/$(whoami)/Application Data/Ubisoft/Anno1404"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "${user_data_path%/*}"
	mkdir --parents "$PATH_DATA/userdata"
	ln --symbolic "$PATH_DATA/userdata" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'
# The DirectX installer expected by winetricks is only included in the old multi-languages installers
# shellcheck disable=SC2016
APP_MAIN_PRERUN_GOG_MULTI="$APP_MAIN_PRERUN"'
# Install d3dx9 through winetricks, using the shipped installer if required
if [ ! -e d3dx9_installed ]; then
	cached_installer="${XDG_CACHE_HOME:="$HOME/.cache"}/winetricks/directx9/directx_Jun2010_redist.exe"
	if [ ! -e "$cached_installer" ]; then
		mkdir --parents "$(dirname "$cached_installer")"
		cp directx/directx_jun2010_redist.exe "$cached_installer"
	fi
	winetricks d3dx9
	touch d3dx9_installed
fi'
APP_MAIN_EXE='anno4.exe'
APP_MAIN_ICON='anno4.exe'

APP_VENICE_ID="${GAME_ID}_venice"
APP_VENICE_TYPE='wine'
APP_VENICE_PRERUN="$APP_MAIN_PRERUN"
APP_VENICE_PRERUN_GOG_MULTI="$APP_MAIN_PRERUN_GOG_MULTI"
APP_VENICE_EXE='addon.exe'
APP_VENICE_ICON='addon.exe'
APP_VENICE_NAME="$GAME_NAME - Venice"

PACKAGES_LIST_GOG_EN='PKG_L10N_EN PKG_DATA PKG_BIN'
PACKAGES_LIST_GOG_FR='PKG_L10N_FR PKG_DATA PKG_BIN'
PACKAGES_LIST_GOG_MULTI='PKG_L10N_DE PKG_L10N_EN PKG_L10N_ES PKG_L10N_FR PKG_L10N_IT PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_DESCRIPTION='localization'

PKG_L10N_DE_ID="${PKG_L10N_ID}-de"
PKG_L10N_DE_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DE_DESCRIPTION="$PKG_L10N_DESCRIPTION - German"

PKG_L10N_EN_ID="${PKG_L10N_ID}-en"
PKG_L10N_EN_PROVIDE="$PKG_L10N_ID"
PKG_L10N_EN_DESCRIPTION="$PKG_L10N_DESCRIPTION - English"

PKG_L10N_ES_ID="${PKG_L10N_ID}-es"
PKG_L10N_ES_PROVIDE="$PKG_L10N_ID"
PKG_L10N_ES_DESCRIPTION="$PKG_L10N_DESCRIPTION - Spanish"

PKG_L10N_FR_ID="${PKG_L10N_ID}-fr"
PKG_L10N_FR_PROVIDE="$PKG_L10N_ID"
PKG_L10N_FR_DESCRIPTION="$PKG_L10N_DESCRIPTION - French"

PKG_L10N_IT_ID="${PKG_L10N_ID}-it"
PKG_L10N_IT_PROVIDE="$PKG_L10N_ID"
PKG_L10N_IT_DESCRIPTION="$PKG_L10N_DESCRIPTION - Italian"

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID $PKG_L10N_ID winetricks wine glx xcursor"

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

# Set packages list based on source archive

use_archive_specific_value 'PACKAGES_LIST'
# shellcheck disable=SC2086
set_temp_directories $PACKAGES_LIST

# Extract game data

case "$ARCHIVE" in
	('ARCHIVE_GOG_MULTI_OLD0')
		if [ $DRY_RUN -eq 0 ]; then
			ln --symbolic "$(readlink --canonicalize "$SOURCE_ARCHIVE_PART1")" "$PLAYIT_WORKDIR/$GAME_ID.r00"
			ln --symbolic "$(readlink --canonicalize "$SOURCE_ARCHIVE_PART2")" "$PLAYIT_WORKDIR/$GAME_ID.r01"
		fi
		extract_data_from "$PLAYIT_WORKDIR/$GAME_ID.r00"
		tolower "$PLAYIT_WORKDIR/gamedata"
	;;
	(*)
		extract_data_from "$SOURCE_ARCHIVE"
	;;
esac
prepare_package_layout

# Include DirectX shipped installer

PKG='PKG_BIN'
organize_data 'REDIST' "$PATH_GAME/directx"
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_VENICE'
icons_move_to 'PKG_DATA'

# Fix immediate crash

file="${PKG_DATA_PATH}${PATH_GAME}/engine.ini"
if [ -e "$file" ]; then
	pattern='2i<DirectXVersion>9</DirectXVersion>'
	if [ $DRY_RUN -eq 0 ]; then
		sed --in-place "$pattern" "$file"
	fi
else
	if [ $DRY_RUN -eq 0 ]; then
		cat > "$file" <<- 'EOF'
		<InitFile>
		<DirectXVersion>9</DirectXVersion>
		</InitFile>
		EOF
	fi
fi

# Write launchers

PKG='PKG_BIN'
case "$ARCHIVE" in
	('ARCHIVE_GOG_MULTI'*)
		unset 'APP_WINETRICKS'
		use_archive_specific_value 'APP_MAIN_PRERUN'
		use_archive_specific_value 'APP_VENICE_PRERUN'
	;;
esac
launchers_write 'APP_MAIN' 'APP_VENICE'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

case "$ARCHIVE" in
	('ARCHIVE_GOG_MULTI'*)
		case "${LANG%_*}" in
			('fr')
				lang_string='version %s :'
				lang_de='allemande'
				lang_en='anglaise'
				lang_es='espagnole'
				lang_fr='française'
				lang_it='italienne'
			;;
			('en'|*)
				lang_string='%s version:'
				lang_de='German'
				lang_en='English'
				lang_es='Spanish'
				lang_fr='French'
				lang_it='Italian'
			;;
		esac
		printf '\n'
		# shellcheck disable=SC2059
		printf "$lang_string" "$lang_de"
		print_instructions 'PKG_L10N_DE' 'PKG_DATA' 'PKG_BIN'
		# shellcheck disable=SC2059
		printf "$lang_string" "$lang_en"
		print_instructions 'PKG_L10N_EN' 'PKG_DATA' 'PKG_BIN'
		# shellcheck disable=SC2059
		printf "$lang_string" "$lang_es"
		print_instructions 'PKG_L10N_ES' 'PKG_DATA' 'PKG_BIN'
		# shellcheck disable=SC2059
		printf "$lang_string" "$lang_fr"
		print_instructions 'PKG_L10N_FR' 'PKG_DATA' 'PKG_BIN'
		# shellcheck disable=SC2059
		printf "$lang_string" "$lang_it"
		print_instructions 'PKG_L10N_IT' 'PKG_DATA' 'PKG_BIN'
	;;
	(*)
		print_instructions
	;;
esac

exit 0
