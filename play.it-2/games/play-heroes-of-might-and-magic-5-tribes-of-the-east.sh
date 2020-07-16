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
# Heroes of Might and Magic Ⅴ - Tribes of the East
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200716.1

# Set game-specific variables

GAME_ID='heroes-of-might-and-magic-5-tribes-of-the-east'
GAME_NAME='Heroes of Might and Magic Ⅴ - Tribes of the East'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0'

ARCHIVE_GOG_EN_0='setup_homm5_tote_2.1.0.24.exe'
ARCHIVE_GOG_EN_0_MD5='80db7a846cb8a7052506db814cb2185e'
ARCHIVE_GOG_EN_0_TYPE='rar'
ARCHIVE_GOG_EN_0_URL='https://www.gog.com/game/heroes_of_might_and_magic_5_bundle'
ARCHIVE_GOG_EN_0_SIZE='2300000'
ARCHIVE_GOG_EN_0_VERSION='3.1-gog2.1.0.24'
ARCHIVE_GOG_EN_0_PART1='setup_homm5_tote_2.1.0.24.bin'
ARCHIVE_GOG_EN_0_PART1_MD5='48a783c1f6d3e15a0439fc58d85c5b28'
ARCHIVE_GOG_EN_0_PART1_TYPE='rar'

ARCHIVE_GOG_FR_0='setup_homm5_tote_french_2.1.0.24.exe'
ARCHIVE_GOG_FR_0_MD5='67f1c9b8ddeae0707729ebfb8ec05e51'
ARCHIVE_GOG_FR_0_TYPE='rar'
ARCHIVE_GOG_FR_0_URL='https://www.gog.com/game/heroes_of_might_and_magic_5_bundle'
ARCHIVE_GOG_FR_0_SIZE='2300000'
ARCHIVE_GOG_FR_0_VERSION='3.1-gog2.1.0.24'
ARCHIVE_GOG_FR_0_PART1='setup_homm5_tote_french_2.1.0.24-1.bin'
ARCHIVE_GOG_FR_0_PART1_MD5='bfb583edb64c548cf60f074e4abc2043'
ARCHIVE_GOG_FR_0_PART1_TYPE='rar'

ARCHIVE_DOC_L10N_PATH='game'
ARCHIVE_DOC_L10N_FILES='*.pdf *.txt editor?documentation fandocuments/*.pdf fandocuments/*.txt'

ARCHIVE_GAME_BIN_PATH='game'
ARCHIVE_GAME_BIN_FILES='bin bindm'

ARCHIVE_GAME_L10N_PATH='game'
ARCHIVE_GAME_L10N_FILES='fandocuments/*.exe data/a2p1-texts.pak data/sound.pak data/texts.pak'

ARCHIVE_GAME_DATA_PATH='game'
ARCHIVE_GAME_DATA_FILES='*.bmp customcontentdm editor hwcursors music profiles video data/a2p1-data.pak data/data.pak data/soundsfx.pak'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='bin/h5_game.exe'
APP_MAIN_ICON='bin/h5_game.exe'
APP_MAIN_PRERUN='# Run the game binary from its parent directory
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'

APP_EDIT_ID="${GAME_ID}_map-editor"
APP_EDIT_NAME="$GAME_NAME - Map Editor"
APP_EDIT_TYPE='wine'
APP_EDIT_EXE='bin/h5_mapeditor.exe'
APP_EDIT_ICON='bin/h5_mapeditor.exe'
APP_EDIT_ICON_ID='128'
APP_EDIT_PRERUN="$APP_MAIN_PRERUN"

APP_DM_ID="${GAME_ID}_dark-messiah"
APP_DM_NAME="$GAME_NAME - Dark Messiah"
APP_DM_TYPE='wine'
APP_DM_EXE='bindm/h5_game.exe'
APP_DM_ICON='bindm/h5_game.exe'
APP_DM_ICON_ID='101'
APP_DM_PRERUN="$APP_MAIN_PRERUN"

APP_SKILLS_ID="${GAME_ID}_skill-wheel"
APP_SKILLS_NAME="$GAME_NAME - SkillWheel"
APP_SKILLS_TYPE='wine'
APP_SKILLS_EXE='fandocuments/skillwheel.exe'
APP_SKILLS_ICON='fandocuments/skillwheel.exe'
APP_SKILLS_ICON_ID='200'
APP_SKILLS_PRERUN="$APP_MAIN_PRERUN"

PACKAGES_LIST='PKG_L10N PKG_DATA PKG_BIN'

# Localization — common properties
PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
# Localization — English
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
# Localization — French
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID $PKG_L10N_ID wine glx"

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

extract_data_from "$SOURCE_ARCHIVE_PART1"
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get icons

###
# TODO
# icons_move_to fails if the destination is not empty
# see https://forge.dotslashplay.it/play.it/scripts/-/issues/233
###

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_EDIT' 'APP_DM'
icons_move_to 'PKG_L10N'

PKG='PKG_L10N'
icons_get_from_package 'APP_SKILLS'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_EDIT' 'APP_DM' 'APP_SKILLS'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
