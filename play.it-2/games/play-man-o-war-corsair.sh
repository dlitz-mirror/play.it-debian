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
# Man Oʼ War: Corsair - Warhammer Naval Battles
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201103.6

# Set game-specific variables

GAME_ID='man-o-war-corsair'
GAME_NAME='Man Oʼ War: Corsair - Warhammer Naval Battles'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0'

ARCHIVE_GOG_1='setup_man_o_war_corsair_-_warhammer_naval_battles_1.4.4_(38991).exe'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/man_o_war_corsair'
ARCHIVE_GOG_1_MD5='c0b70c63edcc3ca8d8209a9ccb7c9d9e'
ARCHIVE_GOG_1_VERSION='1.4.4-gog38991'
ARCHIVE_GOG_1_SIZE='30000000'
ARCHIVE_GOG_1_PART1='setup_man_o_war_corsair_-_warhammer_naval_battles_1.4.4_(38991)-1.bin'
ARCHIVE_GOG_1_PART1_MD5='69c15c6e3b8238b585c8760327756ab7'
ARCHIVE_GOG_1_PART1_TYPE='innosetup'
ARCHIVE_GOG_1_PART2='setup_man_o_war_corsair_-_warhammer_naval_battles_1.4.4_(38991)-2.bin'
ARCHIVE_GOG_1_PART2_MD5='31aa85d6f8c39625e0dfac46b82928b5'
ARCHIVE_GOG_1_PART2_TYPE='innosetup'
ARCHIVE_GOG_1_PART3='setup_man_o_war_corsair_-_warhammer_naval_battles_1.4.4_(38991)-3.bin'
ARCHIVE_GOG_1_PART3_MD5='1676e6583b9331b9ba7ad029e4009a46'
ARCHIVE_GOG_1_PART3_TYPE='innosetup'
ARCHIVE_GOG_1_PART4='setup_man_o_war_corsair_-_warhammer_naval_battles_1.4.4_(38991)-4.bin'
ARCHIVE_GOG_1_PART4_MD5='9c0637c0277adea7705ef713e924a7ac'
ARCHIVE_GOG_1_PART4_TYPE='innosetup'

ARCHIVE_GOG_0='setup_man_o_war_corsair_-_warhammer_naval_battles_1.4.2_(29576).exe'
ARCHIVE_GOG_0_MD5='296429ab49c28df62ff38235564e36e8'
ARCHIVE_GOG_0_VERSION='1.4.2-gog29576'
ARCHIVE_GOG_0_SIZE='30000000'
ARCHIVE_GOG_0_PART1='setup_man_o_war_corsair_-_warhammer_naval_battles_1.4.2_(29576)-1.bin'
ARCHIVE_GOG_0_PART1_MD5='8c3b24d21c951f6ad9b7699eda024de1'
ARCHIVE_GOG_0_PART1_TYPE='innosetup'
ARCHIVE_GOG_0_PART2='setup_man_o_war_corsair_-_warhammer_naval_battles_1.4.2_(29576)-2.bin'
ARCHIVE_GOG_0_PART2_MD5='516a671f6a45d9c03e29f13d51271a78'
ARCHIVE_GOG_0_PART2_TYPE='innosetup'
ARCHIVE_GOG_0_PART3='setup_man_o_war_corsair_-_warhammer_naval_battles_1.4.2_(29576)-3.bin'
ARCHIVE_GOG_0_PART3_MD5='38c58a508879661063ca5e9bbea541ab'
ARCHIVE_GOG_0_PART3_TYPE='innosetup'
ARCHIVE_GOG_0_PART4='setup_man_o_war_corsair_-_warhammer_naval_battles_1.4.2_(29576)-4.bin'
ARCHIVE_GOG_0_PART4_MD5='1f02de3d92681a080808446636116c6c'
ARCHIVE_GOG_0_PART4_TYPE='innosetup'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='mono manowarcorsair_data/plugins *.dll *.exe'

ARCHIVE_GAME_MODELS_LAND_PATH='.'
ARCHIVE_GAME_MODELS_LAND_FILES='mowdata/landmodels-*'

ARCHIVE_GAME_MODELS_PATH='.'
ARCHIVE_GAME_MODELS_FILES='mowdata/charactermodels-* mowdata/shipmodels-* mowdata/flyermodels* mowdata/seamonstermodels*'

ARCHIVE_GAME_TERRAIN1_PATH='.'
ARCHIVE_GAME_TERRAIN1_FILES='mowdata/terrain-top* mowdata/terrain-mid*'

ARCHIVE_GAME_TERRAIN2_PATH='.'
ARCHIVE_GAME_TERRAIN2_FILES='mowdata/terrain-bot* mowdata/terrainshaders*'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='manowarcorsair_data mowdata'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='manowarcorsair.exe'
APP_MAIN_OPTIONS='-force-opengl'
APP_MAIN_ICON='manowarcorsair.exe'

PACKAGES_LIST='PKG_MODELS_LAND PKG_MODELS PKG_TERRAIN1 PKG_TERRAIN2 PKG_DATA PKG_BIN'

PKG_MODELS_LAND_ID="${GAME_ID}-models-land"
PKG_MODELS_LAND_DESCRIPTION='land models'

PKG_MODELS_ID="${GAME_ID}-models"
PKG_MODELS_DESCRIPTION='models'
PKG_MODELS_DEPS="$PKG_MODELS_LAND_ID"

PKG_TERRAIN1_ID="${GAME_ID}-terrain-1"
PKG_TERRAIN1_DESCRIPTION='terrain, part 1'

PKG_TERRAIN2_ID="${GAME_ID}-terrain-2"
PKG_TERRAIN2_DESCRIPTION='terrain, part 2'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DEPS="$PKG_MODELS_ID $PKG_TERRAIN1_ID $PKG_TERRAIN2_ID"

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Common Unity3D tweaks

# Use a per-session dedicated file for logs
DATA_DIRS="$DATA_DIRS ./logs"
APP_MAIN_OPTIONS="$APP_MAIN_OPTIONS"' -logFile logs/$(date +%F-%R).log'

# Store saved games in a persistent path

DATA_DIRS="$DATA_DIRS ./saves"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store saved games in a persistent path
saves_path_prefix="$WINEPREFIX/drive_c/users/$USER/Local Settings/Application Data/EvilTwinArtworks/ManOWarCorsair/Saves"
saves_path_persistent="$PATH_PREFIX/saves"
if [ ! -h "$saves_path_prefix" ]; then
	if [ -d "$saves_path_prefix" ]; then
		# Migrate existing saved games to the persistent path
		mv "$saves_path_prefix"/* "$saves_path_persistent"
		rmdir "$saves_path_prefix"
	fi
	# Create link from prefix to persistent path
	mkdir --parents "$(dirname "$saves_path_prefix")"
	ln --symbolic "$saves_path_persistent" "$saves_path_prefix"
fi'

# Store settings in a persistent path

REGISTRY_KEY="HKEY_CURRENT_USER\\Software\\Evil Twin Artworks\\Man O' War: Corsair"
REGISTRY_DUMP='registry-dumps/settings.reg'

CONFIG_DIRS="$CONFIG_DIRS ./$(dirname "$REGISTRY_DUMP")"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN
# Set path for persistent dump of registry keys
REGISTRY_KEY=\"$REGISTRY_KEY\"
REGISTRY_DUMP='$REGISTRY_DUMP'"
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'
# Dump registry keys
regedit -E "$REGISTRY_DUMP" "$REGISTRY_KEY"'
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Load dump of registry keys
if [ -e "$REGISTRY_DUMP" ]; then
	wine regedit.exe "$REGISTRY_DUMP"
fi'

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
