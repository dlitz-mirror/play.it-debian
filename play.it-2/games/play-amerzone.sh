#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
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
# L’Amerzone
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210503.11

# Set game-specific variables

GAME_ID='amerzone'
GAME_NAME='LʼAmerzone'

ARCHIVES_LIST='
ARCHIVE_BASE_EN_0
ARCHIVE_BASE_FR_0'

ARCHIVE_BASE_EN_0='setup_amerzone_2.0.0.8.exe'
ARCHIVE_BASE_EN_0_MD5='f6be5dbae76289bfdb58eef01913f85e'
ARCHIVE_BASE_EN_0_TYPE='innosetup'
ARCHIVE_BASE_EN_0_VERSION='1.0-gog2.0.0.8'
ARCHIVE_BASE_EN_0_SIZE='2000000'
ARCHIVE_BASE_EN_0_URL='https://www.gog.com/game/amerzone_the_explorer_legacy'

ARCHIVE_BASE_FR_0='setup_amerzone_french_2.1.0.10.exe'
ARCHIVE_BASE_FR_0_MD5='00458580b95940b6d7257cfa6ba902b2'
ARCHIVE_BASE_FR_0_TYPE='innosetup'
ARCHIVE_BASE_FR_0_VERSION='1.0-gog2.1.0.10'
ARCHIVE_BASE_FR_0_SIZE='2000000'
ARCHIVE_BASE_FR_0_URL='https://www.gog.com/game/amerzone_the_explorer_legacy'

ARCHIVE_DOC_L10N_PATH='app'
ARCHIVE_DOC_L10N_FILES='*.pdf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe launch'

ARCHIVE_GAME_L10N_PATH='app'
ARCHIVE_GAME_L10N_FILES='splash ??vr_*/*.ifo ??vr_*/acces_base.vr ??vr_*/avion.vr ??vr_*/bark.vr ??vr_*/carnet.vr ??vr_*/changelevel.vr ??vr_*/chapter?.vr ??vr_*/chklist.vr ??vr_*/coordonnees.vr ??vr_*/credits.vr ??vr_*/disk?.vr ??vr_*/glisseur.vr ??vr_*/grappin.vr ??vr_*/helico.vr ??vr_*/interface.vr ??vr_*/inv_*.vr ??vr_*/inventaire*.vr ??vr_*/lettre*.vr ??vr_*/modes.vr ??vr_*/nocarbu*.vr ??vr_*/oeuf*.vr ??vr_*/options.vr ??vr_*/password.vr ??vr_*/quit.vr ??vr_*/ssmarin.vr ??vr_*/testament.vr ??vr_*/voilier.vr 01vr_phare/sc01_a.smk 01vr_phare/scene01.smk 01vr_phare/scene03.smk 02vr_ile/sc14.smk 02vr_ile/sc15.smk 02vr_ile/sc16.smk 03vr_pueblo/scene23.smk 03vr_pueblo/scene26.smk 03vr_pueblo/scene27.smk 05vr_villagemarais/sc41.smk 01vr_phare/warp214.vr 02vr_ile/warp321.vr 03vr_pueblo/warp404.vr 03vr_pueblo/warp410.vr 04vr_fleuve/warp518a.vr 04vr_fleuve/warp519a.vr 05vr_villagemarais/warp734.vr 01vr_phare/museum.wav 05vr_villagemarais/indian8.wav 05vr_villagemarais/indian9.wav 05vr_villagemarais/indian10.wav'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='*.dat *.ico *.pak *.smk *.tst *.vr ??vr_*'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='amerzone.exe'
APP_MAIN_ICON='amerzone.exe'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"

PKG_L10N_ID_BASE_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_BASE_EN='English localization'

PKG_L10N_ID_BASE_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_BASE_FR='French localization'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} ${PKG_L10N_ID} wine"

# Use persistent storage for saved games

DATA_FILES="${DATA_FILES} ./Saved_*.bin"

# Set up a WINE virtual desktop on first launch, using the current desktop resolution

APP_WINETRICKS="${APP_WINETRICKS} vd=\$(xrandr|awk '/\\*/ {print \$1}')"
PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks xrandr"

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
