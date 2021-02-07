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
# Frostpunk
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210405.2

# Set game-specific variables

GAME_ID='frostpunk'
GAME_NAME='Frostpunk'

ARCHIVES_LIST='
ARCHIVE_GOG_7
ARCHIVE_GOG_6
ARCHIVE_GOG_5
ARCHIVE_GOG_4
ARCHIVE_GOG_3
ARCHIVE_GOG_2
ARCHIVE_GOG_1
ARCHIVE_GOG_0'

ARCHIVE_GOG_7='setup_frostpunk_1.6.1_51795_59550_(42925).exe'
ARCHIVE_GOG_7_MD5='77bc92a7242dea010d766cf83bbace36'
ARCHIVE_GOG_7_TYPE='innosetup'
ARCHIVE_GOG_7_PART1='setup_frostpunk_1.6.1_51795_59550_(42925)-1.bin'
ARCHIVE_GOG_7_PART1_MD5='cfdfccd316e3e1b82e285f9a54f3307a'
ARCHIVE_GOG_7_PART1_TYPE='innosetup'
ARCHIVE_GOG_7_PART2='setup_frostpunk_1.6.1_51795_59550_(42925)-2.bin'
ARCHIVE_GOG_7_PART2_MD5='ff9cc388079e949bd1ac0f888315282b'
ARCHIVE_GOG_7_PART2_TYPE='innosetup'
ARCHIVE_GOG_7_PART3='setup_frostpunk_1.6.1_51795_59550_(42925)-3.bin'
ARCHIVE_GOG_7_PART3_MD5='966cf1daaa31538c2dfa3b2125f86c34'
ARCHIVE_GOG_7_PART3_TYPE='innosetup'
ARCHIVE_GOG_7_VERSION='1.6.1-gog42925'
ARCHIVE_GOG_7_SIZE='9500000'
ARCHIVE_GOG_7_URL='https://www.gog.com/game/frostpunk'

ARCHIVE_GOG_6='setup_frostpunk_1.6.1_51791_59537_(42472).exe'
ARCHIVE_GOG_6_MD5='ec9795eb841cde30cb62d9983517aa68'
ARCHIVE_GOG_6_TYPE='innosetup'
ARCHIVE_GOG_6_PART1='setup_frostpunk_1.6.1_51791_59537_(42472)-1.bin'
ARCHIVE_GOG_6_PART1_MD5='cb3996ecfa56f3ee102317d21392c034'
ARCHIVE_GOG_6_PART1_TYPE='innosetup'
ARCHIVE_GOG_6_PART2='setup_frostpunk_1.6.1_51791_59537_(42472)-2.bin'
ARCHIVE_GOG_6_PART2_MD5='80af46c57e1e2d0fdb4fd97e4ba685f2'
ARCHIVE_GOG_6_PART2_TYPE='innosetup'
ARCHIVE_GOG_6_PART3='setup_frostpunk_1.6.1_51791_59537_(42472)-3.bin'
ARCHIVE_GOG_6_PART3_MD5='652fb81dda4ca761d6fa08eba603c268'
ARCHIVE_GOG_6_PART3_TYPE='innosetup'
ARCHIVE_GOG_6_VERSION='1.6.1-gog42472'
ARCHIVE_GOG_6_SIZE='9600000'

ARCHIVE_GOG_5='setup_frostpunk_1.6.0_hotfix_candidate_3_(40765).exe'
ARCHIVE_GOG_5_MD5='103d278de0b32670596d48fa0a3e1e7a'
ARCHIVE_GOG_5_TYPE='innosetup'
ARCHIVE_GOG_5_PART1='setup_frostpunk_1.6.0_hotfix_candidate_3_(40765)-1.bin'
ARCHIVE_GOG_5_PART1_MD5='fc12ac7dc545219d54c0d547f30f77be'
ARCHIVE_GOG_5_PART1_TYPE='innosetup'
ARCHIVE_GOG_5_PART2='setup_frostpunk_1.6.0_hotfix_candidate_3_(40765)-2.bin'
ARCHIVE_GOG_5_PART2_MD5='8393d7ff2b240fa894ad0523f6ffd3a0'
ARCHIVE_GOG_5_PART2_TYPE='innosetup'
ARCHIVE_GOG_5_PART3='setup_frostpunk_1.6.0_hotfix_candidate_3_(40765)-3.bin'
ARCHIVE_GOG_5_PART3_MD5='77e9e8c6cfa3953a33d82b5fa822f226'
ARCHIVE_GOG_5_PART3_TYPE='innosetup'
ARCHIVE_GOG_5_VERSION='1.6.0-gog40765'
ARCHIVE_GOG_5_SIZE='9800000'

ARCHIVE_GOG_4='setup_frostpunk_1.6.0_(40599).exe'
ARCHIVE_GOG_4_MD5='da7acf8c314c798743645d218567960d'
ARCHIVE_GOG_4_TYPE='innosetup'
ARCHIVE_GOG_4_PART1='setup_frostpunk_1.6.0_(40599)-1.bin'
ARCHIVE_GOG_4_PART1_MD5='9ad1b9c0fe5ca877bbda422b465f81fc'
ARCHIVE_GOG_4_PART1_TYPE='innosetup'
ARCHIVE_GOG_4_PART2='setup_frostpunk_1.6.0_(40599)-2.bin'
ARCHIVE_GOG_4_PART2_MD5='0aaed0691be9193110e8179e0468cd1c'
ARCHIVE_GOG_4_PART2_TYPE='innosetup'
ARCHIVE_GOG_4_PART3='setup_frostpunk_1.6.0_(40599)-3.bin'
ARCHIVE_GOG_4_PART3_MD5='097ab0962232b97bb568350208e84dae'
ARCHIVE_GOG_4_PART3_TYPE='innosetup'
ARCHIVE_GOG_4_VERSION='1.6.0-gog40599'
ARCHIVE_GOG_4_SIZE='9800000'

ARCHIVE_GOG_3='setup_frostpunk_1.5.0.51146.56648_(2020-02-14_17-22)_(36204).exe'
ARCHIVE_GOG_3_MD5='cc9bd3aba061dacd4f83e79e6a13d4e8'
ARCHIVE_GOG_3_TYPE='innosetup'
ARCHIVE_GOG_3_PART1='setup_frostpunk_1.5.0.51146.56648_(2020-02-14_17-22)_(36204)-1.bin'
ARCHIVE_GOG_3_PART1_MD5='ba31654b9f3b1d24b22df3999e5ff78e'
ARCHIVE_GOG_3_PART1_TYPE='innosetup'
ARCHIVE_GOG_3_PART2='setup_frostpunk_1.5.0.51146.56648_(2020-02-14_17-22)_(36204)-2.bin'
ARCHIVE_GOG_3_PART2_MD5='fc560cb127691e6fdcd9e1a82f0e7b26'
ARCHIVE_GOG_3_PART2_TYPE='innosetup'
ARCHIVE_GOG_3_PART3='setup_frostpunk_1.5.0.51146.56648_(2020-02-14_17-22)_(36204)-3.bin'
ARCHIVE_GOG_3_PART3_MD5='b82e3dc7bd981c8a30b8da51813acbf6'
ARCHIVE_GOG_3_PART3_TYPE='innosetup'
ARCHIVE_GOG_3_VERSION='1.5.0-gog36204'
ARCHIVE_GOG_3_SIZE='8700000'

ARCHIVE_GOG_2='setup_frostpunk_1.5.0.51029.56354_(2020-01-21_1545)_(35558).exe'
ARCHIVE_GOG_2_MD5='c31ecb7aa2497bc12bf83324d52b413f'
ARCHIVE_GOG_2_TYPE='innosetup'
ARCHIVE_GOG_2_PART1='setup_frostpunk_1.5.0.51029.56354_(2020-01-21_1545)_(35558)-1.bin'
ARCHIVE_GOG_2_PART1_MD5='92cc54cc6c91f8435c3e7bc80fb22a20'
ARCHIVE_GOG_2_PART1_TYPE='innosetup'
ARCHIVE_GOG_2_PART2='setup_frostpunk_1.5.0.51029.56354_(2020-01-21_1545)_(35558)-2.bin'
ARCHIVE_GOG_2_PART2_MD5='22489f0c14736cd5c473a3e091dfed51'
ARCHIVE_GOG_2_PART2_TYPE='innosetup'
ARCHIVE_GOG_2_PART3='setup_frostpunk_1.5.0.51029.56354_(2020-01-21_1545)_(35558)-3.bin'
ARCHIVE_GOG_2_PART3_MD5='24013bb92bf78991e110463579685461'
ARCHIVE_GOG_2_PART3_TYPE='innosetup'
ARCHIVE_GOG_2_VERSION='1.5.0-gog35558'
ARCHIVE_GOG_2_SIZE='8700000'

ARCHIVE_GOG_1='setup_frostpunk_1.4.1.50110.53938_(2019-11-05_1825)_(33713).exe'
ARCHIVE_GOG_1_MD5='99b71af138d5fdcb67418392b0a14d62'
ARCHIVE_GOG_1_TYPE='innosetup'
ARCHIVE_GOG_1_PART1='setup_frostpunk_1.4.1.50110.53938_(2019-11-05_1825)_(33713)-1.bin'
ARCHIVE_GOG_1_PART1_MD5='3fbe880a3c3acaf00ede07c998b13c92'
ARCHIVE_GOG_1_PART1_TYPE='innosetup'
ARCHIVE_GOG_1_PART2='setup_frostpunk_1.4.1.50110.53938_(2019-11-05_1825)_(33713)-2.bin'
ARCHIVE_GOG_1_PART2_MD5='86267bb5dc870db828c50ccaa45d6091'
ARCHIVE_GOG_1_PART2_TYPE='innosetup'
ARCHIVE_GOG_1_VERSION='1.4.1-gog33713'
ARCHIVE_GOG_1_SIZE='6500000'

ARCHIVE_GOG_0='setup_frostpunk_1.4.0.48534.51933_(2019-08-30_1543)_(32102).exe'
ARCHIVE_GOG_0_MD5='08e52207d9385bd5d3d66755facad69a'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_PART1='setup_frostpunk_1.4.0.48534.51933_(2019-08-30_1543)_(32102)-1.bin'
ARCHIVE_GOG_0_PART1_MD5='60245c2ede7e99f526fa5cb87a660ebe'
ARCHIVE_GOG_0_PART1_TYPE='innosetup'
ARCHIVE_GOG_0_PART2='setup_frostpunk_1.4.0.48534.51933_(2019-08-30_1543)_(32102)-2.bin'
ARCHIVE_GOG_0_PART2_MD5='48dcdc8acb8bfd93b5eab09b8695854e'
ARCHIVE_GOG_0_PART2_TYPE='innosetup'
ARCHIVE_GOG_0_VERSION='1.4.0-gog32102'
ARCHIVE_GOG_0_SIZE='6500000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.txt'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.exe *.dll *.ini'

ARCHIVE_GAME_TEXTURES_PATH='.'
ARCHIVE_GAME_TEXTURES_FILES='textures-s3.dat textures-s3.idx'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='*.dat *.idx *.str'

CONFIG_FILES='./gfxconfig.ini'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='frostpunk.exe'
APP_MAIN_ICON='frostpunk.exe'

PACKAGES_LIST='PKG_BIN PKG_TEXTURES PKG_DATA'

PKG_TEXTURES_ID="${GAME_ID}-textures"
PKG_TEXTURES_DESCRIPTION='textures'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DEPS="$PKG_TEXTURES_ID"

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Store saved games and settings in a persistent path

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store saved games and settings in a persistent path
user_data_path="$WINEPREFIX/drive_c/users/$(whoami)/Application Data/11bitstudios/Frostpunk"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "${user_data_path%/*}"
	mkdir --parents "$PATH_DATA/userdata"
	ln --symbolic "$PATH_DATA/userdata" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'

# Create some required empty files

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Create some required empty files
touch custom_localizations.dat voices.dat'

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

# Enable dxvk patches in the WINE prefix

case "$OPTION_PACKAGE" in
	('deb')
		APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
		# Install dxvk on first launch
		if [ ! -e dxvk_installed ]; then
			sleep 3s
			dxvk-setup install --development
			touch dxvk_installed
		fi'
		PKG_BIN_DEPS="$PKG_BIN_DEPS dxvk-wine64-development dxvk"
	;;
	('arch'|'gentoo')
		APP_WINETRICKS="$APP_WINETRICKS dxvk"
		PKG_BIN_DEPS="$PKG_BIN_DEPS winetricks"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
