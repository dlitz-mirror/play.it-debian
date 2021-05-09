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
# The Settlers 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210403.4

# Set game-specific variables

GAME_ID='the-settlers-2'
GAME_NAME='The Settlers Ⅱ'

ARCHIVES_LIST='
ARCHIVE_GOG_DE_1
ARCHIVE_GOG_DE_0
ARCHIVE_GOG_EN_1
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_1
ARCHIVE_GOG_FR_0'

# gog.com German installer

ARCHIVE_GOG_DE_1='setup_the_settlers_2_gold_1.5.1_(german)_(30319).exe'
ARCHIVE_GOG_DE_1_MD5='c360aaabd05e99b0f0752e52dd105107'
ARCHIVE_GOG_DE_1_TYPE='innosetup'
ARCHIVE_GOG_DE_1_VERSION='1.5.1-gog30319'
ARCHIVE_GOG_DE_1_SIZE='360000'
ARCHIVE_GOG_DE_1_URL='https://www.gog.com/game/the_settlers_2_gold_edition'

ARCHIVE_GOG_DE_0='setup_settlers2_gold_german_2.1.0.17.exe'
ARCHIVE_GOG_DE_0_MD5='f87a8fded6de455af4e6a284b3c4ed5e'
ARCHIVE_GOG_DE_0_TYPE='innosetup'
ARCHIVE_GOG_DE_0_VERSION='1.5.1-gog2.1.0.17'
ARCHIVE_GOG_DE_0_SIZE='370000'


# gog.com English installer

ARCHIVE_GOG_EN_1='setup_the_settlers_2_gold_1.5.1_(30319).exe'
ARCHIVE_GOG_EN_1_MD5='8381240ee580a298798b6afe863bac52'
ARCHIVE_GOG_EN_1_TYPE='innosetup'
ARCHIVE_GOG_EN_1_VERSION='1.5.1-gog30319'
ARCHIVE_GOG_EN_1_SIZE='370000'
ARCHIVE_GOG_EN_1_URL='https://www.gog.com/game/the_settlers_2_gold_edition'

ARCHIVE_GOG_EN_0='setup_settlers2_gold_2.0.0.14.exe'
ARCHIVE_GOG_EN_0_MD5='6f64b47b15f6ba5d43670504dd0bb229'
ARCHIVE_GOG_EN_0_TYPE='innosetup'
ARCHIVE_GOG_EN_0_VERSION='1.5.1-gog2.0.0.14'
ARCHIVE_GOG_EN_0_SIZE='370000'


# gog.com French installer

ARCHIVE_GOG_FR_1='setup_the_settlers_2_gold_1.5.1_(french)_(30319).exe'
ARCHIVE_GOG_FR_1_MD5='55a9d15f1260de5e711ea649120ece50'
ARCHIVE_GOG_FR_1_TYPE='innosetup'
ARCHIVE_GOG_FR_1_VERSION='1.5.1-gog30319'
ARCHIVE_GOG_FR_1_SIZE='400000'
ARCHIVE_GOG_FR_1_URL='https://www.gog.com/game/the_settlers_2_gold_edition'

ARCHIVE_GOG_FR_0='setup_settlers2_gold_french_2.1.0.16.exe'
ARCHIVE_GOG_FR_0_MD5='1eca72ca45d63e4390590d495657d213'
ARCHIVE_GOG_FR_0_TYPE='innosetup'
ARCHIVE_GOG_FR_0_VERSION='1.5.1-gog2.1.0.16'
ARCHIVE_GOG_FR_0_SIZE='410000'


ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='eula *.txt'

ARCHIVE_GAME0_MAIN_PATH='.'
ARCHIVE_GAME0_MAIN_FILES='*.exe *.ini *.scr s2edit.exe s2.exe setup.exe data/resource.idx data/io/*.idx data/maps* data/missions/mis_0100.rtx data/online data/txt* drivers/mdi.ini gfx/pics/setup000.lbm gfx/pics/setup010.lbm gfx/pics/setup011.lbm gfx/pics/setup012.lbm gfx/pics/setup014.lbm gfx/pics/setup897.lbm gfx/pics/setup898.lbm gfx/pics/setup900.lbm gfx/pics/setup901.lbm gfx/pics/setup996.lbm gfx/pics/setup997.lbm gfx/pics/setup998.lbm save/mission.dat video/*.smk'

ARCHIVE_GAME1_MAIN_PATH='__support/save'
ARCHIVE_GAME1_MAIN_FILES='save/mission.dat'

ARCHIVE_GAME_COMMON_PATH='.'
ARCHIVE_GAME_COMMON_FILES='dos4gw.exe settler2.vmc settlers2.gog settlers2.ins settlers2.inst data/*.dat data/editres.idx data/animdat data/bobs data/cbob data/io/*.dat data/io/*.fnt data/*.lst data/masks data/mbob data/missions/mis_00*.rtx data/missions/mis_10*.rtx data/sounddat/sng data/sounddat/sound.lst data/textures drivers/*.ad drivers/*.dig drivers/dig.ini drivers/*.exe drivers/*.lst drivers/*.mdi drivers/*.opl gfx/palette gfx/pics2 gfx/pics/install.lbm gfx/pics/mission gfx/pics/setup013.lbm gfx/pics/setup015.lbm gfx/pics/setup666.lbm gfx/pics/setup667.lbm gfx/pics/setup801.lbm gfx/pics/setup802.lbm gfx/pics/setup803.lbm gfx/pics/setup804.lbm gfx/pics/setup805.lbm gfx/pics/setup806.lbm gfx/pics/setup810.lbm gfx/pics/setup811.lbm gfx/pics/setup895.lbm gfx/pics/setup896.lbm gfx/pics/setup899.lbm gfx/pics/setup990.lbm gfx/pics/world.lbm gfx/pics/worldmsk.lbm gfx/textures video/smackply.exe'

CONFIG_FILES='./SETUP.INI'
DATA_DIRS='./DATA ./GFX ./SAVE ./WORLDS'

GAME_IMAGE='SETTLERS2.INS'
GAME_IMAGE_TYPE='iso'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='S2.EXE'
APP_MAIN_ICON='app/goggame-1207658786.ico'

APP_EDITOR_TYPE='dosbox'
APP_EDITOR_ID="${GAME_ID}_edit"
APP_EDITOR_EXE='S2EDIT.EXE'
APP_EDITOR_NAME="$GAME_NAME - Editor"
APP_EDITOR_ICON="$APP_MAIN_ICON"

APP_SETUP_TYPE='dosbox'
APP_SETUP_ID="${GAME_ID}_setup"
APP_SETUP_EXE='SETUP.EXE'
APP_SETUP_NAME="$GAME_NAME - Setup"
APP_SETUP_CAT='Settings'
APP_SETUP_ICON="$APP_MAIN_ICON"

PACKAGES_LIST='PKG_COMMON PKG_MAIN'

PKG_COMMON_ID="${GAME_ID}-common"
PKG_COMMON_DESCRIPTION='common data'

# Main package - common properties
PKG_MAIN_ID="$GAME_ID"
PKG_MAIN_PROVIDE="$PKG_MAIN_ID"
PKG_MAIN_DEPS="$PKG_COMMON_ID dosbox"
# Main package - German version
PKG_MAIN_ID_GOG_DE="${GAME_ID}-de"
PKG_MAIN_DESCRIPTION_GOG_DE='German version'
# Main package - English version
PKG_MAIN_ID_GOG_EN="${GAME_ID}-en"
PKG_MAIN_DESCRIPTION_GOG_EN='English version'
# Main package - French version
PKG_MAIN_ID_GOG_FR="${GAME_ID}-fr"
PKG_MAIN_DESCRIPTION_GOG_FR='French version'

# Play the intro movie before starting the game

###
# TODO
# It might be better to play this movie with a native player instead of from DOSBox
###

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
@VIDEO\SMACKPLY VIDEO\INTRO.SMK'

# Keep compatibility with old archives

ARCHIVE_DOC_MAIN_PATH_GOG_DE_0='app'
ARCHIVE_DOC_MAIN_PATH_GOG_EN_0='app'
ARCHIVE_DOC_MAIN_PATH_GOG_FR_0='app'
ARCHIVE_GAME0_MAIN_PATH_GOG_DE_0='app'
ARCHIVE_GAME0_MAIN_PATH_GOG_EN_0='app'
ARCHIVE_GAME0_MAIN_PATH_GOG_FR_0='app'
ARCHIVE_GAME1_MAIN_PATH_GOG_DE_0='app/__support/save'
ARCHIVE_GAME1_MAIN_PATH_GOG_EN_0='app/__support/save'
ARCHIVE_GAME1_MAIN_PATH_GOG_FR_0='app/__support/save'
ARCHIVE_GAME_COMMON_PATH_GOG_DE_0='app'
ARCHIVE_GAME_COMMON_PATH_GOG_EN_0='app'
ARCHIVE_GAME_COMMON_PATH_GOG_FR_0='app'

GAME_IMAGE_GOG_DE_0='SETTLERS2.INST'
GAME_IMAGE_GOG_EN_0='SETTLERS2.INST'
GAME_IMAGE_GOG_FR_0='SETTLERS2.INST'

APP_MAIN_ICON_GOG_EN_0='app/gfw_high.ico'
APP_EDITOR_ICON_GOG_EN_0="$APP_MAIN_ICON_GOG_EN_0"
APP_SETUP_ICON_GOG_EN_0="$APP_MAIN_ICON_GOG_EN_0"

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
toupper "${PKG_COMMON_PATH}${PATH_GAME}"
toupper "${PKG_MAIN_PATH}${PATH_GAME}"

# Extract icons

PKG='PKG_COMMON'
icons_get_from_workdir 'APP_MAIN' 'APP_EDITOR' 'APP_SETUP'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Keep compatibility with pre-20200103.1 scripts

###
# TODO
# This should be replace by PREFIX_PREPARE and userdir_toupper_files once these are included in a stable release
# cf. https://forge.dotslashplay.it/play.it/scripts/-/merge_requests/775
###

launcher_write_script_dosbox_run() {
	# shellcheck disable=SC2039
	local application file
	application="$1"
	file="$2"
	cat >> "$file" <<- 'EOF'
	# Convert all paths to uppercase

	for path in "$PATH_CONFIG" "$PATH_DATA"; do
	    find "$path" -depth -mindepth 1 | while read -r file; do
	        newfile="$(dirname "$file")/$(basename "$file" | tr '[:lower:]' '[:upper:]')"
	        [ -e "$newfile" ] || mv "$file" "$newfile"
	    done
	done

	# Run the game

	cd "$PATH_PREFIX"
	"${PLAYIT_DOSBOX_BINARY:-dosbox}" -c "mount c .
	c:
	EOF
	cat >> "$file" <<- EOF
	imgmount d $GAME_IMAGE -t iso -fs iso
	EOF
	launcher_write_script_prerun "$application" "$file"
	cat >> "$file" <<- 'EOF'
	$APP_EXE $APP_OPTIONS $@
	EOF
	launcher_write_script_postrun "$application" "$file"
	cat >> "$file" <<- 'EOF'
	exit"

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# Ensure case consistency in disk image table of contents

use_archive_specific_value 'GAME_IMAGE'
DISK_IMAGE_TOC="${PKG_COMMON_PATH}${PATH_GAME}/${GAME_IMAGE}"
pattern='settlers2.gog'
replacement='SETTLERS2.GOG'
expression="s/${pattern}/${replacement}/i"
sed --in-place --expression="$expression" "$DISK_IMAGE_TOC"

# Write launchers

PKG='PKG_MAIN'
launchers_write 'APP_MAIN' 'APP_EDITOR' 'APP_SETUP'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
