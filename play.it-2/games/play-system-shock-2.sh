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
# System Shock 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200207.2

# Set game-specific variables

GAME_ID='system-shock-2'
GAME_NAME='System Shock 2'

ARCHIVE_GOG='setup_system_shock_2_2.47_nd_(22087).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/system_shock_2'
ARCHIVE_GOG_MD5='cc2ff390b566364447dc5bd05757fe57'
ARCHIVE_GOG_SIZE='670000'
ARCHIVE_GOG_VERSION='2.47-gog22087'
ARCHIVE_GOG_TYPE='innosetup1.7'

ARCHIVE_GOG_OLD3='setup_system_shock_2_2.46_update_3_(19935).exe'
ARCHIVE_GOG_OLD3_MD5='cdafcdea01556eccab899f94503843df'
ARCHIVE_GOG_OLD3_SIZE='670000'
ARCHIVE_GOG_OLD3_VERSION='2.46.3-gog19935'
ARCHIVE_GOG_OLD3_TYPE='innosetup1.7'

ARCHIVE_GOG_OLD2='setup_system_shock_2_2.46_update_2_(18733).exe'
ARCHIVE_GOG_OLD2_MD5='39fab64451ace95966988bb90c7bb17e'
ARCHIVE_GOG_OLD2_SIZE='680000'
ARCHIVE_GOG_OLD2_VERSION='2.46.2-gog18733'

ARCHIVE_GOG_OLD1='setup_system_shock_2_2.46_update_(18248).exe'
ARCHIVE_GOG_OLD1_MD5='b76803e4a632b58527eada8993999143'
ARCHIVE_GOG_OLD1_SIZE='690000'
ARCHIVE_GOG_OLD1_VERSION='2.46.1-gog18248'

ARCHIVE_GOG_OLD0='setup_system_shock_2_2.46_nd_(11004).exe'
ARCHIVE_GOG_OLD0_MD5='98c3d01d53bb2b0dc25d7ed7093a67d3'
ARCHIVE_GOG_OLD0_SIZE='680000'
ARCHIVE_GOG_OLD0_VERSION='2.46-gog11004'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.pdf *.txt *.wri doc editor/*.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_OLD1='app'
ARCHIVE_DOC_DATA_PATH_GOG_OLD2='app'
ARCHIVE_DOC_DATA_PATH_GOG_OLD0='app'

ARCHIVE_GAME0_BIN_PATH='.'
ARCHIVE_GAME0_BIN_FILES='*.ax *.bnd *.cfg *.crt *.dll *.exe *.osm */*.cfg */*.dll */*.exe'
# Keep compatibility with old archives
ARCHIVE_GAME0_BIN_PATH_GOG_OLD1='app'
ARCHIVE_GAME0_BIN_PATH_GOG_OLD2='app'
ARCHIVE_GAME0_BIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME1_BIN_PATH='__support/app'
ARCHIVE_GAME1_BIN_FILES='*.cfg *.ini'
# Keep compatibility with old archives
ARCHIVE_GAME1_BIN_PATH_GOG_OLD1='app/__support/app'
ARCHIVE_GAME1_BIN_PATH_GOG_OLD2='app/__support/app'
ARCHIVE_GAME1_BIN_PATH_GOG_OLD0='app/__support/app'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='*.bin *.dif *.dml ilist.* patch* binds data sq_scripts'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_OLD1='app'
ARCHIVE_GAME_DATA_PATH_GOG_OLD2='app'
ARCHIVE_GAME_DATA_PATH_GOG_OLD0='app'

CONFIG_FILES='./*.bnd ./*.cfg ./*.ini'
DATA_DIRS='./current ./save_0 ./save_1 ./save_2 ./save_3 ./save_4 ./save_5 ./save_6 ./save_7 ./save_8 ./save_9 ./save_10 ./save_11 ./save_12 ./save_13 ./save_14'
DATA_FILES='./*.log'

# Set up a virtual WINE desktop on first launch, using current screen resolution
APP_WINETRICKS="vd=\$(xrandr|awk '/\\*/ {print \$1}')"

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='shock2.exe'
# shellcheck disable=SC2016
APP_MAIN_POSTRUN='# Work around issues with configuration persistence
for cfg in *.cfg; do
	if [ -f "$cfg" ] && [ ! -h "$cfg" ]; then
		mv "$PATH_CONFIG/$cfg" "$PATH_CONFIG/$cfg.old"
		mv "$cfg" "$PATH_CONFIG/$cfg"
		ln --symbolic "$PATH_CONFIG/$cfg" "$cfg"
	fi
done'
APP_MAIN_ICON='shock2.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks xrandr glx"

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
