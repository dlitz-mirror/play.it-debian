#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# Pillars of Eternity
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180919.2

# Set game-specific variables

GAME_ID='pillars-of-eternity'
GAME_NAME='Pillars of Eternity'

ARCHIVE_GOG='pillars_of_eternity_en_3_07_0_1318_17461.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/pillars_of_eternity_hero_edition'
ARCHIVE_GOG_MD5='57164ad0cbc53d188dde0b38e7491916'
ARCHIVE_GOG_SIZE='15000000'
ARCHIVE_GOG_VERSION='3.7.0.1318-gog17461'
ARCHIVE_GOG_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD2='pillars_of_eternity_en_3_07_16405.sh'
ARCHIVE_GOG_OLD2_MD5='e4271b5e72f1ecc9fbbc4d90937ede05'
ARCHIVE_GOG_OLD2_SIZE='15000000'
ARCHIVE_GOG_OLD2_VERSION='3.7.0.1284-gog16405'
ARCHIVE_GOG_OLD2_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD1='gog_pillars_of_eternity_2.16.0.20.sh'
ARCHIVE_GOG_OLD1_MD5='0d21cf95bda070bdbfbe3e79f8fc32d6'
ARCHIVE_GOG_OLD1_SIZE='15000000'
ARCHIVE_GOG_OLD1_VERSION='3.06.1254-gog2.16.0.20'
ARCHIVE_GOG_OLD1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD0='gog_pillars_of_eternity_2.15.0.19.sh'
ARCHIVE_GOG_OLD0_MD5='2000052541abb1ef8a644049734e8526'
ARCHIVE_GOG_OLD0_SIZE='15000000'
ARCHIVE_GOG_OLD0_VERSION='3.05.1186-gog2.15.0.19'
ARCHIVE_GOG_OLD0_TYPE='mojosetup_unzip'

ARCHIVE_GOG_DLC1='gog_pillars_of_eternity_kickstarter_item_dlc_2.0.0.2.sh'
ARCHIVE_GOG_DLC1_MD5='b4c29ae17c87956471f2d76d8931a4e5'

ARCHIVE_GOG_DLC2='gog_pillars_of_eternity_kickstarter_pet_dlc_2.0.0.2.sh'
ARCHIVE_GOG_DLC2_MD5='3653fc2a98ef578335f89b607f0b7968'

ARCHIVE_GOG_DLC3='gog_pillars_of_eternity_preorder_item_and_pet_dlc_2.0.0.2.sh'
ARCHIVE_GOG_DLC3_MD5='b86ad866acb62937d2127407e4beab19'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='PillarsOfEternity PillarsOfEternity_Data/Mono PillarsOfEternity_Data/Plugins'

ARCHIVE_GAME_AREAS_PATH='data/noarch/game'
ARCHIVE_GAME_AREAS_FILES='PillarsOfEternity_Data/assetbundles/st_ar_*'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='PillarsOfEternity.png PillarsOfEternity_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='PillarsOfEternity'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='PillarsOfEternity_Data/Resources/UnityPlayer.png'
# Keep compatibility with old archives
APP_MAIN_ICONS_LIST_OLD='APP_MAIN_ICON APP_MAIN_ICON_OLD'
APP_MAIN_ICON_OLD='PillarsOfEternity.png'

PACKAGES_LIST='PKG_AREAS PKG_BIN PKG_DATA'

PKG_AREAS_ID="${GAME_ID}-areas"
PKG_AREAS_DESCRIPTION='areas'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_AREAS_ID $PKG_DATA_ID glu xcursor libxrandr"

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	: ${XDG_DATA_HOME:="$HOME/.local/share"}
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
. "$PLAYIT_LIB2"

# Load extra archives (DLC)

ARCHIVE_MAIN="$ARCHIVE"
for dlc in 'DLC1' 'DLC2' 'DLC3'; do
	set_archive "ARCHIVE_$dlc" "ARCHIVE_GOG_$dlc"
done
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
(
	if [ "$ARCHIVE_DLC1" ]; then
		ARCHIVE='ARCHIVE_GOG_DLC1'
		extract_data_from "$ARCHIVE_DLC1"
	fi
	if [ "$ARCHIVE_DLC2" ]; then
		ARCHIVE='ARCHIVE_GOG_DLC2'
		extract_data_from "$ARCHIVE_DLC2"
	fi
	if [ "$ARCHIVE_DLC3" ]; then
		ARCHIVE='ARCHIVE_GOG_DLC3'
		extract_data_from "$ARCHIVE_DLC3"
	fi
)
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

case "$ARCHIVE" in
	('ARCHIVE_GOG_OLD0'|'ARCHIVE_GOG_OLD1')
		APP_MAIN_ICONS_LIST="$APP_MAIN_ICONS_LIST_OLD"
	;;
esac
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_AREAS' 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
