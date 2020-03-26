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
# Heroes of Might and Magic Ⅴ
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200425.2

# Set game-specific variables

GAME_ID='heroes-of-might-and-magic-5'
GAME_NAME='Heroes of Might and Magic Ⅴ'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR ARCHIVE_GOG_EN_OLD1 ARCHIVE_GOG_FR_OLD1 ARCHIVE_GOG_RAR_EN_OLD0 ARCHIVE_GOG_RAR_FR_OLD0'

ARCHIVE_GOG_EN='setup_heroes_of_might_and_magic_v_2.1_v2_(28567).exe'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/heroes_of_might_and_magic_5_bundle'
ARCHIVE_GOG_EN_MD5='657775b4eb545150f5895e61e67eda73'
ARCHIVE_GOG_EN_TYPE='innosetup'
ARCHIVE_GOG_EN_SIZE='2600000'
ARCHIVE_GOG_EN_VERSION='2.1-gog28567'
ARCHIVE_GOG_EN_PART1='setup_heroes_of_might_and_magic_v_2.1_v2_(28567)-1.bin'
ARCHIVE_GOG_EN_PART1_MD5='bb4dd38f472fd94f82aa22cb256f4b9c'
ARCHIVE_GOG_EN_PART1_TYPE='innosetup'

ARCHIVE_GOG_FR='setup_heroes_of_might_and_magic_v_2.1_v2_(french)_(28567).exe'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/heroes_of_might_and_magic_5_bundle'
ARCHIVE_GOG_FR_MD5='78e860af17d9ce220d8c60c1e594cf40'
ARCHIVE_GOG_FR_TYPE='innosetup'
ARCHIVE_GOG_FR_SIZE='2600000'
ARCHIVE_GOG_FR_VERSION='2.1-gog28567'
ARCHIVE_GOG_FR_PART1='setup_heroes_of_might_and_magic_v_2.1_v2_(french)_(28567)-1.bin'
ARCHIVE_GOG_FR_PART1_MD5='9e8017cc5d84231bf8eb9c8c757631f8'
ARCHIVE_GOG_FR_PART1_TYPE='innosetup'

ARCHIVE_GOG_EN_OLD1='setup_heroes_of_might_and_magic_v_2.1_(25025).exe'
ARCHIVE_GOG_EN_OLD1_MD5='6e36b7fb9f1e8362326688d383e4bdb9'
ARCHIVE_GOG_EN_OLD1_TYPE='innosetup'
ARCHIVE_GOG_EN_OLD1_SIZE='2600000'
ARCHIVE_GOG_EN_OLD1_VERSION='2.1-gog25025'
ARCHIVE_GOG_EN_OLD1_PART1='setup_heroes_of_might_and_magic_v_2.1_(25025)-1.bin'
ARCHIVE_GOG_EN_OLD1_PART1_MD5='3e38f48f450f58833728cd73e9266d2d'
ARCHIVE_GOG_EN_OLD1_PART1_TYPE='innosetup'

ARCHIVE_GOG_FR_OLD1='setup_heroes_of_might_and_magic_v_2.1_(french)_(25025).exe'
ARCHIVE_GOG_FR_OLD1_MD5='b9e278ee60d574b89068479a4e6c84c1'
ARCHIVE_GOG_FR_OLD1_TYPE='innosetup'
ARCHIVE_GOG_FR_OLD1_SIZE='2600000'
ARCHIVE_GOG_FR_OLD1_VERSION='2.1-gog25025'
ARCHIVE_GOG_FR_OLD1_PART1='setup_heroes_of_might_and_magic_v_2.1_(french)_(25025)-1.bin'
ARCHIVE_GOG_FR_OLD1_PART1_MD5='57ca61178fca9ed2e50a5dc667f6d565'
ARCHIVE_GOG_FR_OLD1_PART1_TYPE='innosetup'

ARCHIVE_GOG_RAR_EN_OLD0='setup_homm5_2.1.0.22.exe'
ARCHIVE_GOG_RAR_EN_OLD0_MD5='74f32ce4fd9580842d6f4230034c04ba'
ARCHIVE_GOG_RAR_EN_OLD0_TYPE='rar'
ARCHIVE_GOG_RAR_EN_OLD0_SIZE='2500000'
ARCHIVE_GOG_RAR_EN_OLD0_VERSION='2.1-gog2.1.0.22'
ARCHIVE_GOG_RAR_EN_OLD0_PART1='setup_homm5_2.1.0.22.bin'
ARCHIVE_GOG_RAR_EN_OLD0_PART1_MD5='9a31aecfcd072f1a01ab4e810f57f894'
ARCHIVE_GOG_RAR_EN_OLD0_PART1_TYPE='rar'

ARCHIVE_GOG_RAR_FR_OLD0='setup_homm5_french_2.1.0.22.exe'
ARCHIVE_GOG_RAR_FR_OLD0_MD5='51766fd6456879ee261a2924464a1be0'
ARCHIVE_GOG_RAR_FR_OLD0_TYPE='rar'
ARCHIVE_GOG_RAR_FR_OLD0_SIZE='2500000'
ARCHIVE_GOG_RAR_FR_OLD0_VERSION='2.1-gog2.1.0.22'
ARCHIVE_GOG_RAR_FR_OLD0_PART1='setup_homm5_french_2.1.0.22.bin'
ARCHIVE_GOG_RAR_FR_OLD0_PART1_MD5='4d56a95f779c9583cdfdc451ca865927'
ARCHIVE_GOG_RAR_FR_OLD0_PART1_TYPE='rar'

ARCHIVE_DOC_L10N_PATH='.'
ARCHIVE_DOC_L10N_FILES='*.txt *.pdf editor?documentation/homm5_combat_replay.pdf editor?documentation/homm5_dialogs_replay.pdf editor?documentation/homm5_preset_editor.pdf editor?documentation/homm5_spectator_mode.pdf editor?documentation/homm5_users_campaign_editor.pdf'
# Keep compatibility with old archives
ARCHIVE_DOC_L10N_PATH_GOG_RAR='game'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='editor?documentation'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_RAR='game'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='bin bina1'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_RAR='game'

ARCHIVE_GAME_L10N_PATH='.'
ARCHIVE_GAME_L10N_FILES='dataa1/a1p1-texts.pak dataa1/a1-sound.pak dataa1/a1-texts.pak dataa1/p3-texts.pak dataa1/texts.pak datals/p5-texts.pak datals/p6-texts.pak data/p3-texts.pak data/sound.pak data/texts.pak music/cs/death-berein.ogg music/cs/death-nico.ogg music/cs/heart-griffin.ogg music/cs/isabel-trap.ogg music/cs/nico-vampire.ogg music/cs/ritual-isabel.ogg video/intro.ogg video/outro.ogg'
# Keep compatibility with old archives
ARCHIVE_GAME_L10N_PATH_GOG_RAR='game'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='data dataa1 datals duelpresets editor hwcursors music profiles splasha1.bmp splash.bmp video'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_RAR='game'

DATA_DIRS='./profiles'
DATA_FILES='./*.log'

APP_MAIN_TYPE='wine'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Store user data outside of WINE prefix (base game)
user_data_path="$WINEPREFIX/drive_c/users/$USER/My Documents/My Games/Heroes of Might and Magic V/Profiles"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "$(dirname "$user_data_path")"
	mkdir --parents "$PATH_DATA/profiles"
	ln --symbolic "$PATH_DATA/profiles" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'
# shellcheck disable=SC2016
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store user data outside of WINE prefix (Hammer of Fate)
user_data_path="$WINEPREFIX/drive_c/users/$USER/My Documents/My Games/Heroes of Might and Magic V/Hammers of Fate/Profiles"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "$(dirname "$user_data_path")"
	mkdir --parents "$PATH_DATA/profiles"
	ln --symbolic "$PATH_DATA/profiles" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'
# shellcheck disable=SC2016
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Run the game binary from its parent directory
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'
APP_MAIN_EXE='bin/h5_game.exe'
APP_MAIN_ICON='bin/h5_game.exe'

APP_HOF_ID="${GAME_ID}_hof"
APP_HOF_TYPE='wine'
APP_HOF_PRERUN="$APP_MAIN_PRERUN"
APP_HOF_EXE='bina1/h5_game.exe'
APP_HOF_ICON='bina1/h5_game.exe'
APP_HOF_NAME="$GAME_NAME - Hammers of Fate"

APP_EDIT_ID="${GAME_ID}_edit"
APP_EDIT_TYPE='wine'
APP_EDIT_PRERUN="$APP_MAIN_PRERUN"
APP_EDIT_EXE='bin/h5_mapeditor.exe'
APP_EDIT_ICON='bin/h5_mapeditor.exe'
APP_EDIT_ICON_ID='128'
APP_EDIT_NAME="$GAME_NAME - Map Editor"

APP_HOFEDIT_ID="${GAME_ID}_hofedit"
APP_HOFEDIT_TYPE='wine'
APP_HOFEDIT_PRERUN="$APP_MAIN_PRERUN"
APP_HOFEDIT_EXE='bina1/h5_mapeditor.exe'
APP_HOFEDIT_ICON='bina1/h5_mapeditor.exe'
APP_HOFEDIT_ICON_ID='128'
APP_HOFEDIT_NAME="$GAME_NAME - Hammers of Fate - Map Editor"

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_ID_GOG_EN="${GAME_ID}-l10n-en"
PKG_L10N_ID_GOG_FR="${GAME_ID}-l10n-fr"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
PKG_L10N_DESCRIPTION_GOG_FR='French localization'
# Keep compatibility with old archives
PKG_L10N_ID_GOG_RAR_EN="$PKG_L10N_ID_GOG_EN"
PKG_L10N_ID_GOG_RAR_FR="$PKG_L10N_ID_GOG_FR"
PKG_L10N_DESCRIPTION_GOG_RAR_EN="$PKG_L10N_DESCRIPTION_GOG_EN"
PKG_L10N_DESCRIPTION_GOG_RAR_FR="$PKG_L10N_DESCRIPTION_GOG_FR"

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID $PKG_L10N_ID wine"

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

case "$ARCHIVE" in
	('ARCHIVE_GOG_RAR_'*)
		extract_data_from "$SOURCE_ARCHIVE_PART1"
		tolower "$PLAYIT_WORKDIR/gamedata"
	;;
	(*)
		extract_data_from "$SOURCE_ARCHIVE"
	;;
esac
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_HOF' 'APP_EDIT' 'APP_HOFEDIT'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_HOF' 'APP_EDIT' 'APP_HOFEDIT'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
