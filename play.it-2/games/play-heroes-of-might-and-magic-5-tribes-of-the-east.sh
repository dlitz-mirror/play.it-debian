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

script_version=20200716.4

# Set game-specific variables

GAME_ID='heroes-of-might-and-magic-5-tribes-of-the-east'
GAME_NAME='Heroes of Might and Magic Ⅴ - Tribes of the East'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_1
ARCHIVE_GOG_FR_1
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0
ARCHIVE_GOG_RAR_EN_0
ARCHIVE_GOG_RAR_FR_0'

ARCHIVE_GOG_EN_1='setup_heroes_of_might_and_magic_v_-_tribes_of_the_east_3.1_v2_(28569).exe'
ARCHIVE_GOG_EN_1_MD5='9593ad538a39638bacb4d7ef45368ce2'
ARCHIVE_GOG_EN_1_TYPE='innosetup'
ARCHIVE_GOG_EN_1_URL='https://www.gog.com/game/heroes_of_might_and_magic_5_bundle'
ARCHIVE_GOG_EN_1_SIZE='2300000'
ARCHIVE_GOG_EN_1_VERSION='3.1-gog28569'
ARCHIVE_GOG_EN_1_PART1='setup_heroes_of_might_and_magic_v_-_tribes_of_the_east_3.1_v2_(28569)-1.bin'
ARCHIVE_GOG_EN_1_PART1_MD5='8e03271dc4aff5834110664b5d6eefde'
ARCHIVE_GOG_EN_1_PART1_TYPE='innosetup'

ARCHIVE_GOG_FR_1='setup_heroes_of_might_and_magic_v_-_tribes_of_the_east_3.1_v2_(french)_(28569).exe'
ARCHIVE_GOG_FR_1_MD5='6a1a915180d1cee32e78419f6917be87'
ARCHIVE_GOG_FR_1_TYPE='innosetup'
ARCHIVE_GOG_FR_1_URL='https://www.gog.com/game/heroes_of_might_and_magic_5_bundle'
ARCHIVE_GOG_FR_1_SIZE='2300000'
ARCHIVE_GOG_FR_1_VERSION='3.1-gog28569'
ARCHIVE_GOG_FR_1_PART1='setup_heroes_of_might_and_magic_v_-_tribes_of_the_east_3.1_v2_(french)_(28569)-1.bin'
ARCHIVE_GOG_FR_1_PART1_MD5='f48ed6725126696bf3e67ce327db6263'
ARCHIVE_GOG_FR_1_PART1_TYPE='innosetup'

ARCHIVE_GOG_EN_0='setup_heroes_of_might_and_magic_v_-_tribes_of_the_east_3.1_(25025).exe'
ARCHIVE_GOG_EN_0_MD5='3096f296d5d8b6cb0b4ab479fc06474b'
ARCHIVE_GOG_EN_0_TYPE='innosetup'
ARCHIVE_GOG_EN_0_SIZE='2300000'
ARCHIVE_GOG_EN_0_VERSION='3.1-gog25025'
ARCHIVE_GOG_EN_0_PART1='setup_heroes_of_might_and_magic_v_-_tribes_of_the_east_3.1_(25025)-1.bin'
ARCHIVE_GOG_EN_0_PART1_MD5='5f4840b0105bd6b4228ff9b707bc0434'
ARCHIVE_GOG_EN_0_PART1_TYPE='innosetup'

ARCHIVE_GOG_FR_0='setup_heroes_of_might_and_magic_v_-_tribes_of_the_east_3.1_(french)_(25025).exe'
ARCHIVE_GOG_FR_0_MD5='a2b5d18f34d3fa1a760de4fa63aa3819'
ARCHIVE_GOG_FR_0_TYPE='innosetup'
ARCHIVE_GOG_FR_0_SIZE='2300000'
ARCHIVE_GOG_FR_0_VERSION='3.1-gog25025'
ARCHIVE_GOG_FR_0_PART1='setup_heroes_of_might_and_magic_v_-_tribes_of_the_east_3.1_(french)_(25025)-1.bin'
ARCHIVE_GOG_FR_0_PART1_MD5='08a5ec9aaf674235db4d96072bf373fc'
ARCHIVE_GOG_FR_0_PART1_TYPE='innosetup'

ARCHIVE_GOG_RAR_EN_0='setup_homm5_tote_2.1.0.24.exe'
ARCHIVE_GOG_RAR_EN_0_MD5='80db7a846cb8a7052506db814cb2185e'
ARCHIVE_GOG_RAR_EN_0_TYPE='rar'
ARCHIVE_GOG_RAR_EN_0_SIZE='2300000'
ARCHIVE_GOG_RAR_EN_0_VERSION='3.1-gog2.1.0.24'
ARCHIVE_GOG_RAR_EN_0_PART1='setup_homm5_tote_2.1.0.24.bin'
ARCHIVE_GOG_RAR_EN_0_PART1_MD5='48a783c1f6d3e15a0439fc58d85c5b28'
ARCHIVE_GOG_RAR_EN_0_PART1_TYPE='rar'

ARCHIVE_GOG_RAR_FR_0='setup_homm5_tote_french_2.1.0.24.exe'
ARCHIVE_GOG_RAR_FR_0_MD5='67f1c9b8ddeae0707729ebfb8ec05e51'
ARCHIVE_GOG_RAR_FR_0_TYPE='rar'
ARCHIVE_GOG_RAR_FR_0_SIZE='2300000'
ARCHIVE_GOG_RAR_FR_0_VERSION='3.1-gog2.1.0.24'
ARCHIVE_GOG_RAR_FR_0_PART1='setup_homm5_tote_french_2.1.0.24-1.bin'
ARCHIVE_GOG_RAR_FR_0_PART1_MD5='bfb583edb64c548cf60f074e4abc2043'
ARCHIVE_GOG_RAR_FR_0_PART1_TYPE='rar'

ARCHIVE_DOC_FANDOCS_PATH='.'
ARCHIVE_DOC_FANDOCS_FILES='fandocuments/*.pdf fandocuments/*.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_FANDOCS_PATH_GOG_RAR='game'

ARCHIVE_DOC_L10N_PATH='.'
ARCHIVE_DOC_L10N_FILES='*.pdf *.txt editor?documentation'
# Keep compatibility with old archives
ARCHIVE_DOC_L10N_PATH_GOG_RAR='game'

ARCHIVE_GAME_FANDOCS_PATH='.'
ARCHIVE_GAME_FANDOCS_FILES='fandocuments/*.exe'
# Keep compatibility with old archives
ARCHIVE_GAME_FANDOCS_PATH_GOG_RAR='game'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='bin bindm'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_RAR='game'

ARCHIVE_GAME_L10N_PATH='.'
ARCHIVE_GAME_L10N_FILES='data/a2p1-texts.pak data/sound.pak data/texts.pak'
# Keep compatibility with old archives
ARCHIVE_GAME_L10N_PATH_GOG_RAR='game'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='*.bmp customcontentdm editor hwcursors music profiles video data/a2p1-data.pak data/data.pak data/soundsfx.pak'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_RAR='game'

DATA_DIRS='./profiles'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='bin/h5_game.exe'
APP_MAIN_ICON='bin/h5_game.exe'
APP_MAIN_PRERUN='# Store user data in persistent directories
user_data_path="$WINEPREFIX/drive_c/users/$USER/My Documents/My Games/Heroes of Might and Magic V - Tribes of the East/Profiles"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "$(dirname "$user_data_path")"
	mkdir --parents "$PATH_DATA/profiles"
	ln --symbolic "$PATH_DATA/profiles" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Run the game binary from its parent directory
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

PACKAGES_LIST='PKG_FANDOCS PKG_L10N PKG_DATA PKG_BIN'

# Fan documents — common properties
PKG_FANDOCS_ARCH='32'
PKG_FANDOCS_ID="${GAME_ID}-fan-documents"
PKG_FANDOCS_PROVIDE="$PKG_FANDOCS_ID"
PKG_FANDOCS_DESCRIPTION='Fan documents'
PKG_FANDOCS_DEPS='wine'
# Fan documents — English
PKG_FANDOCS_ID_GOG_EN="${PKG_FANDOCS_ID}-en"
PKG_FANDOCS_DESCRIPTION_GOG_EN="${PKG_FANDOCS_DESCRIPTION} - English version"
# Fan documents — French
PKG_FANDOCS_ID_GOG_FR="${PKG_FANDOCS_ID}-fr"
PKG_FANDOCS_DESCRIPTION_GOG_FR="${PKG_FANDOCS_DESCRIPTION} - French version"
# Keep compatibility with old archives
PKG_FANDOCS_ID_GOG_RAR_EN="$PKG_FANDOCS_ID_GOG_EN"
PKG_FANDOCS_ID_GOG_RAR_FR="$PKG_FANDOCS_ID_GOG_FR"
PKG_FANDOCS_DESCRIPTION_GOG_RAR_EN="$PKG_FANDOCS_DESCRIPTION_GOG_EN"
PKG_FANDOCS_DESCRIPTION_GOG_RAR_FR="$PKG_FANDOCS_DESCRIPTION_GOG_FR"

# Localization — common properties
PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
# Localization — English
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
# Localization — French
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_GOG_FR='French localization'
# Keep compatibility with old archives
PKG_L10N_ID_GOG_RAR_EN="$PKG_L10N_ID_GOG_EN"
PKG_L10N_ID_GOG_RAR_FR="$PKG_L10N_ID_GOG_FR"
PKG_L10N_DESCRIPTION_GOG_RAR_EN="$PKG_L10N_DESCRIPTION_GOG_EN"
PKG_L10N_DESCRIPTION_GOG_RAR_FR="$PKG_L10N_DESCRIPTION_GOG_FR"

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

case "$ARCHIVE" in
	('ARCHIVE_GOG_RAR'*)
		extract_data_from "$SOURCE_ARCHIVE_PART1"
		tolower "$PLAYIT_WORKDIR/gamedata"
	;;
	(*)
		extract_data_from "$SOURCE_ARCHIVE"
	;;
esac
prepare_package_layout

# Get icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_EDIT' 'APP_DM'
icons_move_to 'PKG_DATA'

PKG='PKG_FANDOCS'
icons_get_from_package 'APP_SKILLS'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_EDIT' 'APP_DM'

PKG='PKG_FANDOCS'
(
	# Do not create a winecfg launcher, to avoid a file conflict with PKG_BIN
	launcher_write_script_wine_winecfg() { return 0 ; }
	desktop_file="${PKG_FANDOCS_PATH}${PATH_DESK}/${GAME_ID}_winecfg.desktop"
	mkdir --parents "$(dirname "$desktop_file")"
	touch "$desktop_file"
	launchers_write 'APP_SKILLS'
	rm "$desktop_file"
)

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
