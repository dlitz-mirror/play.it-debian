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
# Planescape: Torment
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181017.5

# Set game-specific variables

SCRIPT_DEPS='unix2dos'

GAME_ID='planescape-torment'
GAME_NAME='Planescape: Torment'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_EN_OLD0 ARCHIVE_GOG_FR ARCHIVE_GOG_FR_OLD0 ARCHIVE_GOG_RU ARCHIVE_GOG_RU_OLD0'

ARCHIVE_GOG_EN='planescape_torment_gog_3_23483.sh'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/planescape_torment_enhanced_edition'
ARCHIVE_GOG_EN_MD5='3eb98c2c34d628b7da6e4e914ac8e622'
ARCHIVE_GOG_EN_VERSION='1.1-gog23483'
ARCHIVE_GOG_EN_SIZE='2700000'
ARCHIVE_GOG_EN_TYPE='mojosetup'

ARCHIVE_GOG_EN_OLD0='gog_planescape_torment_2.1.0.9.sh'
ARCHIVE_GOG_EN_OLD0_MD5='a48bb772f60da3b5b2cac804b6e92670'
ARCHIVE_GOG_EN_OLD0_VERSION='1.1-gog2.1.0.9'
ARCHIVE_GOG_EN_OLD0_SIZE='2400000'

ARCHIVE_GOG_FR='planescape_torment_french_gog_3_23483.sh'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/planescape_torment_enhanced_edition'
ARCHIVE_GOG_FR_MD5='3374385ab6c5ca8aa489ee8de6161637'
ARCHIVE_GOG_FR_VERSION='1.1-gog23483'
ARCHIVE_GOG_FR_SIZE='2700000'
ARCHIVE_GOG_FR_TYPE='mojosetup'

ARCHIVE_GOG_FR_OLD0='gog_planescape_torment_french_2.1.0.9.sh'
ARCHIVE_GOG_FR_OLD0_MD5='c3af554300a90297d4fca0b591d9c3fd'
ARCHIVE_GOG_FR_OLD0_VERSION='1.1-gog2.1.0.9'
ARCHIVE_GOG_FR_OLD0_SIZE='2400000'

ARCHIVE_GOG_RU='planescape_torment_russian_gog_3_23483.sh'
ARCHIVE_GOG_RU_URL='https://www.gog.com/game/planescape_torment_enhanced_edition'
ARCHIVE_GOG_RU_MD5='6f6744e90691126c884dccf925423e2d'
ARCHIVE_GOG_RU_VERSION='1.1-gog23483'
ARCHIVE_GOG_RU_SIZE='2700000'
ARCHIVE_GOG_RU_TYPE='mojosetup'

ARCHIVE_GOG_RU_OLD0='gog_planescape_torment_russian_2.2.0.10.sh'
ARCHIVE_GOG_RU_OLD0_MD5='d6fd52fe9946bcc067eed441945127f1'
ARCHIVE_GOG_RU_OLD0_VERSION='1.1-gog2.2.0.10'
ARCHIVE_GOG_RU_OLD0_SIZE='2400000'

ARCHIVE_DOC0_L10N_PATH_GOG_EN='data/noarch/docs/english'
ARCHIVE_DOC0_L10N_PATH_GOG_FR='data/noarch/docs/french'
ARCHIVE_DOC0_L10N_PATH_GOG_RU='data/noarch/docs/russian'
ARCHIVE_DOC0_L10N_FILES='*'
# Keep compatibility with old archives
ARCHIVE_DOC0_L10N_PATH_GOG_EN_OLD0='data/noarch/docs'
ARCHIVE_DOC0_L10N_PATH_GOG_FR_OLD0='data/noarch/docs'
ARCHIVE_DOC0_L10N_PATH_GOG_RU_OLD0='data/noarch/docs'

ARCHIVE_DOC1_L10N_PATH_GOG_RU='data/noarch/prefix/drive_c/gog games/planescape torment (russian)'
ARCHIVE_DOC1_L10N_FILES_GOG_RU='readme*.txt'

ARCHIVE_GAME_BIN_PATH_GOG_EN='data/noarch/prefix/drive_c/gog games/planescape torment'
ARCHIVE_GAME_BIN_PATH_GOG_FR='data/noarch/prefix/drive_c/gog games/planescape torment (french)'
ARCHIVE_GAME_BIN_PATH_GOG_RU='data/noarch/prefix/drive_c/gog games/planescape torment (russian)'
ARCHIVE_GAME_BIN_FILES='torment.exe *.ini'

ARCHIVE_GAME_L10N_PATH_GOG_EN='data/noarch/prefix/drive_c/gog games/planescape torment'
ARCHIVE_GAME_L10N_PATH_GOG_FR='data/noarch/prefix/drive_c/gog games/planescape torment (french)'
ARCHIVE_GAME_L10N_PATH_GOG_RU='data/noarch/prefix/drive_c/gog games/planescape torment (russian)'
ARCHIVE_GAME_L10N_FILES='*.tlk chitin.key cachemos.bif crefiles.bif cs_0404.bif interface.bif sound.bif voice.bif data/genmova.bif data/movies2.bif data/movies4.bif override'

ARCHIVE_GAME_DATA_PATH_GOG_EN='data/noarch/prefix/drive_c/gog games/planescape torment'
ARCHIVE_GAME_DATA_PATH_GOG_FR='data/noarch/prefix/drive_c/gog games/planescape torment (french)'
ARCHIVE_GAME_DATA_PATH_GOG_RU='data/noarch/prefix/drive_c/gog games/planescape torment (russian)'
ARCHIVE_GAME_DATA_FILES='*.bif var.var data music'

CONFIG_FILES='./*.ini'
DATA_DIRS='./save'

APP_WINETRICKS="vd=\$(xrandr|grep '\*'|awk '{print \$1}')"

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='torment.exe'
APP_MAIN_ICON='torment.exe'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_ID_GOG_RU="${PKG_L10N_ID}-ru"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
PKG_L10N_DESCRIPTION_GOG_FR='French localization'
PKG_L10N_DESCRIPTION_GOG_RU='Russian localization'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID $PKG_L10N wine winetricks xrandr"

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
tolower "$PLAYIT_WORKDIR/gamedata/data/noarch/docs"
tolower "$PLAYIT_WORKDIR/gamedata/data/noarch/prefix/drive_c"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Tweak paths in torment.ini

file="${PKG_BIN_PATH}${PATH_GAME}/torment.ini"
pattern='s/^\(HD0:\)=.*/\1=C:\\'"$GAME_ID"'\\/'
pattern="$pattern"';s/^\(CD.:\)=.*/\1=C:\\'"$GAME_ID"'\\data\\/'
sed --in-place "$pattern" "$file"
unix2dos "$file" > /dev/null 2>&1

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
