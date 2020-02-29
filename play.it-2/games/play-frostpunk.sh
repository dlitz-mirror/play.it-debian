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
# Frostpunk
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200202.4

# Set game-specific variables

GAME_ID='frostpunk'
GAME_NAME='Frostpunk'

ARCHIVE_GOG='setup_frostpunk_1.5.0.51029.56354_(2020-01-21_1545)_(35558).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/frostpunk'
ARCHIVE_GOG_MD5='c31ecb7aa2497bc12bf83324d52b413f'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_VERSION='1.5.0.51029.56354-gog35558'
ARCHIVE_GOG_SIZE='8700000'
ARCHIVE_GOG_PART1='setup_frostpunk_1.5.0.51029.56354_(2020-01-21_1545)_(35558)-1.bin'
ARCHIVE_GOG_PART1_MD5='92cc54cc6c91f8435c3e7bc80fb22a20'
ARCHIVE_GOG_PART1_TYPE='innosetup'
ARCHIVE_GOG_PART2='setup_frostpunk_1.5.0.51029.56354_(2020-01-21_1545)_(35558)-2.bin'
ARCHIVE_GOG_PART2_MD5='22489f0c14736cd5c473a3e091dfed51'
ARCHIVE_GOG_PART2_TYPE='innosetup'
ARCHIVE_GOG_PART3='setup_frostpunk_1.5.0.51029.56354_(2020-01-21_1545)_(35558)-3.bin'
ARCHIVE_GOG_PART3_MD5='24013bb92bf78991e110463579685461'
ARCHIVE_GOG_PART3_TYPE='innosetup'

ARCHIVE_GOG_OLD1='setup_frostpunk_1.4.1.50110.53938_(2019-11-05_1825)_(33713).exe'
ARCHIVE_GOG_OLD1_MD5='99b71af138d5fdcb67418392b0a14d62'
ARCHIVE_GOG_OLD1_TYPE='innosetup'
ARCHIVE_GOG_OLD1_VERSION='1.4.1.50110.53938-gog33713'
ARCHIVE_GOG_OLD1_SIZE='6500000'
ARCHIVE_GOG_OLD1_PART1='setup_frostpunk_1.4.1.50110.53938_(2019-11-05_1825)_(33713)-1.bin'
ARCHIVE_GOG_OLD1_PART1_MD5='3fbe880a3c3acaf00ede07c998b13c92'
ARCHIVE_GOG_OLD1_PART1_TYPE='innosetup'
ARCHIVE_GOG_OLD1_PART2='setup_frostpunk_1.4.1.50110.53938_(2019-11-05_1825)_(33713)-2.bin'
ARCHIVE_GOG_OLD1_PART2_MD5='86267bb5dc870db828c50ccaa45d6091'
ARCHIVE_GOG_OLD1_PART2_TYPE='innosetup'

ARCHIVE_GOG_OLD0='setup_frostpunk_1.4.0.48534.51933_(2019-08-30_1543)_(32102).exe'
ARCHIVE_GOG_OLD0_MD5='08e52207d9385bd5d3d66755facad69a'
ARCHIVE_GOG_OLD0_TYPE='innosetup'
ARCHIVE_GOG_OLD0_VERSION='1.4.0.48534.51933-gog32102'
ARCHIVE_GOG_OLD0_SIZE='6500000'
ARCHIVE_GOG_OLD0_PART1='setup_frostpunk_1.4.0.48534.51933_(2019-08-30_1543)_(32102)-1.bin'
ARCHIVE_GOG_OLD0_PART1_MD5='60245c2ede7e99f526fa5cb87a660ebe'
ARCHIVE_GOG_OLD0_PART1_TYPE='innosetup'
ARCHIVE_GOG_OLD0_PART2='setup_frostpunk_1.4.0.48534.51933_(2019-08-30_1543)_(32102)-2.bin'
ARCHIVE_GOG_OLD0_PART2_MD5='48dcdc8acb8bfd93b5eab09b8695854e'
ARCHIVE_GOG_OLD0_PART2_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.txt'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.exe *.dll *.ini'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='*.dat *.idx *.str'

CONFIG_FILES='./gfxconfig.ini'

APP_WINETRICKS='dxvk'

APP_MAIN_TYPE='wine'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Store saved games and settingd outside of WINE prefix
user_data_path="$WINEPREFIX/drive_c/users/$(whoami)/Application Data/11bitstudios/Frostpunk"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "${user_data_path%/*}"
	mkdir --parents "$PATH_DATA/userdata"
	ln --symbolic "$PATH_DATA/userdata" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi
touch custom_localizations.dat voices.dat'
APP_MAIN_PRERUN_DEB="$APP_MAIN_PRERUN"'
# Install dxvk on first launch
if [ ! -e dxvk_installed ]; then
	sleep 3s
	dxvk-setup install --development
	touch dxvk_installed
fi'
APP_MAIN_EXE='frostpunk.exe'
APP_MAIN_ICON='frostpunk.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine"
PKG_BIN_DEPS_ARCH='winetricks'
PKG_BIN_DEPS_DEB='dxvk'
PKG_BIN_DEPS_GENTOO='winetricks'

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

# Use repositories-provided dxvk on Debian
case "$OPTION_PACKAGE" in
	('deb')
		unset APP_WINETRICKS
		APP_MAIN_PRERUN="$APP_MAIN_PRERUN_DEB"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

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
