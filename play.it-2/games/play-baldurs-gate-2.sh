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
# Baldur’s Gate 2
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181028.1

# Set game-specific variables

SCRIPT_DEPS='unix2dos'

GAME_ID='baldurs-gate-2'
GAME_NAME='Baldur’s Gate II'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_EN_OLD0 ARCHIVE_GOG_FR ARCHIVE_GOG_FR_OLD0'

ARCHIVE_GOG_EN='baldur_s_gate_2_complete_gog_3_23651.sh'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/baldurs_gate_2_enhanced_edition'
ARCHIVE_GOG_EN_MD5='030a61ce961ac88cd9506f1fd42135d6'
ARCHIVE_GOG_EN_VERSION='2.5.26498-gog23651'
ARCHIVE_GOG_EN_SIZE='3400000'
ARCHIVE_GOG_EN_TYPE='mojosetup'

ARCHIVE_GOG_EN_OLD0='gog_baldur_s_gate_2_complete_2.1.0.7.sh'
ARCHIVE_GOG_EN_OLD0_MD5='e92161d7fc0a2eea234b2c93760c9cdb'
ARCHIVE_GOG_EN_OLD0_VERSION='2.5.26498-gog2.1.0.7'
ARCHIVE_GOG_EN_OLD0_SIZE='3000000'

ARCHIVE_GOG_FR='baldur_s_gate_2_complete_french_gog_3_23651.sh'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/baldurs_gate_2_enhanced_edition'
ARCHIVE_GOG_FR_MD5='c72eb1b9bae7109de6a7005b3dc44e2c'
ARCHIVE_GOG_FR_VERSION='2.5.26498-gog23651'
ARCHIVE_GOG_FR_SIZE='3400000'
ARCHIVE_GOG_FR_TYPE='mojosetup'

ARCHIVE_GOG_FR_OLD0='gog_baldur_s_gate_2_complete_french_2.1.0.7.sh'
ARCHIVE_GOG_FR_OLD0_MD5='6551bda3d8c7330b7ad66842ac1d4ed4'
ARCHIVE_GOG_FR_OLD0_VERSION='2.5.26498-gog2.1.0.7'
ARCHIVE_GOG_FR_OLD0_SIZE='3000000'

ARCHIVE_DOC_L10N_PATH_GOG_EN='data/noarch/docs/english'
ARCHIVE_DOC_L10N_PATH_GOG_FR='data/noarch/docs/french'
ARCHIVE_DOC_L10N_FILES='*'
# Keep compatibility with old archives
ARCHIVE_DOC_L10N_PATH_GOG_EN_OLD0='data/noarch/docs'
ARCHIVE_DOC_L10N_PATH_GOG_FR_OLD0='data/noarch/docs'

ARCHIVE_GAME_BIN_PATH_GOG_EN="data/noarch/prefix/drive_c/gog games/baldur's gate 2"
ARCHIVE_GAME_BIN_PATH_GOG_FR="data/noarch/prefix/drive_c/gog games/baldur's gate 2 (french)"
ARCHIVE_GAME_BIN_FILES='baldur.exe bg*test.exe bgmain.exe charview.exe keymap.ini script?compiler/*.exe script?compiler/*.bat'

ARCHIVE_GAME_L10N_PATH_GOG_EN="data/noarch/prefix/drive_c/gog games/baldur's gate 2"
ARCHIVE_GAME_L10N_PATH_GOG_FR="data/noarch/prefix/drive_c/gog games/baldur's gate 2 (french)"
ARCHIVE_GAME_L10N_FILES='*.tlk mplay* bgconfig.exe glsetup.exe autorun.ini baldur.ini lasnil32.dll chitin.key language.txt characters sounds override/*.wav override/ar0406.bcs override/baldur.bcs data/areas.bif data/chasound.bif data/cresound.bif data/desound.bif data/missound.bif data/movies/25movies.bif data/movies/movend.bif data/movies/movintro.bif data/npchd0so.bif data/*npcso* data/objanim.bif data/scripts.bif'

ARCHIVE_GAME0_DATA_PATH_GOG_EN="data/noarch/prefix/drive_c/gog games/baldur's gate 2/data"
ARCHIVE_GAME0_DATA_PATH_GOG_FR="data/noarch/prefix/drive_c/gog games/baldur's gate 2 (french)/data"
ARCHIVE_GAME0_DATA_FILES='data'

ARCHIVE_GAME1_DATA_PATH_GOG_EN="data/noarch/prefix/drive_c/gog games/baldur's gate 2"
ARCHIVE_GAME1_DATA_PATH_GOG_FR="data/noarch/prefix/drive_c/gog games/baldur's gate 2 (french)"
ARCHIVE_GAME1_DATA_FILES='*.ico *.mpi music scripts script?compiler override data'

CONFIG_FILES='./*.ini'
DATA_DIRS='./characters ./mpsave ./save'

APP_WINETRICKS="vd=\$(xrandr|grep '\*'|awk '{print \$1}')"

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='bgmain.exe'
APP_MAIN_ICON='baldur.exe'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_TYPE='wine'
APP_CONFIG_EXE='bgconfig.exe'
APP_CONFIG_ICON='bgconfig.exe'
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_CAT='Settings'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_L10N_ID $PKG_DATA_ID wine winetricks xrandr"

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
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
rm --force --recursive "$PLAYIT_WORKDIR"/gamedata/data/noarch/prefix/drive_c/GOG?Games/*/mpsave
rm --force --recursive "$PLAYIT_WORKDIR"/gamedata/data/noarch/prefix/drive_c/GOG?Games/*/temp
tolower "$PLAYIT_WORKDIR/gamedata/data/noarch/docs"
tolower "$PLAYIT_WORKDIR/gamedata/data/noarch/prefix/drive_c"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

PKG='PKG_L10N'
icons_get_from_package 'APP_CONFIG'
icons_move_to 'PKG_DATA'

# Tweak paths in baldur.ini

file="${PKG_L10N_PATH}${PATH_GAME}/baldur.ini"
pattern="s/\\(HD0:\\)=.\+/\\1=C:\\\\$GAME_ID\\\\/"
sed --in-place "$pattern" "$file"
for drive in 'CD1' 'CD2' 'CD3' 'CD4' 'CD5' 'CD6'; do
	pattern="s/\\($drive:\\)=.\+/\\1=C:\\\\$GAME_ID\\\\data\\\\/"
	sed --in-place "$pattern" "$file"
done
unix2dos "$file" > /dev/null 2>&1

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN' 'APP_CONFIG'

# Build package

cat > "$postinst" << EOF
if [ ! -e "$PATH_GAME/data/data" ]; then
	ln --symbolic ../data "$PATH_GAME/data/data"
fi
EOF
cat > "$prerm" << EOF
rm --force "$PATH_GAME/data/data"
EOF
write_metadata 'PKG_L10N' 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
