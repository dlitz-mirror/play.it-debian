#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
# Copyright (c) 2020-2021, Igor Telmenko
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
# Syberia
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210716.3

# Set game-specific variables

GAME_ID='syberia'
GAME_NAME='Syberia'

ARCHIVE_BASE_RU_1='setup_syberia_russian_1.0.0_hotfix3_(18946).exe'
ARCHIVE_BASE_RU_1_MD5='cdf5ac1869d57d139495a20102d5ffb4'
ARCHIVE_BASE_RU_1_TYPE='innosetup'
ARCHIVE_BASE_RU_1_SIZE='1600000'
ARCHIVE_BASE_RU_1_VERSION='1.0.0.3-gog18946'
ARCHIVE_BASE_RU_1_URL='https://www.gog.com/game/syberia'

ARCHIVE_BASE_EN_1='setup_syberia_1.0.0_hotfix3_(18946).exe'
ARCHIVE_BASE_EN_1_MD5='53d91df35a154584812d31b9ee353cb8'
ARCHIVE_BASE_EN_1_TYPE='innosetup'
ARCHIVE_BASE_EN_1_SIZE='1600000'
ARCHIVE_BASE_EN_1_VERSION='1.0.0.3-gog18946'
ARCHIVE_BASE_EN_1_URL='https://www.gog.com/game/syberia'

ARCHIVE_BASE_FR_1='setup_syberia_french_1.0.0_hotfix3_(18946).exe'
ARCHIVE_BASE_FR_1_MD5='41881248eefd53929bbaa97c1905a7fe'
ARCHIVE_BASE_FR_1_TYPE='innosetup'
ARCHIVE_BASE_FR_1_SIZE='1600000'
ARCHIVE_BASE_FR_1_VERSION='1.0.0.3-gog18946'
ARCHIVE_BASE_FR_1_URL='https://www.gog.com/game/syberia'

ARCHIVE_BASE_EN_0='setup_syberia_1.0.0_hotfix2_(17897).exe'
ARCHIVE_BASE_EN_0_MD5='d52b7a776df7659d7fda9995715468a0'
ARCHIVE_BASE_EN_0_TYPE='innosetup'
ARCHIVE_BASE_EN_0_SIZE='1600000'
ARCHIVE_BASE_EN_0_VERSION='1.0.0.2-gog17897'

ARCHIVE_BASE_FR_0='setup_syberia_french_1.0.0_hotfix2_(17897).exe'
ARCHIVE_BASE_FR_0_MD5='d8a956a47c1b186a4364eff56c8cecb6'
ARCHIVE_BASE_FR_0_TYPE='innosetup'
ARCHIVE_BASE_FR_0_SIZE='1600000'
ARCHIVE_BASE_FR_0_VERSION='1.0.0.2-gog17897'

ARCHIVE_DOC_L10N_PATH='app'
ARCHIVE_DOC_L10N_FILES='*.pdf *.txt'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='dlls *.dll *.exe *.ini */*.ini'

ARCHIVE_GAME_L10N_PATH='app'
ARCHIVE_GAME_L10N_FILES='sounds splash cmo/citstation.cmo cmo/valreceptioninn.cmo data/font_syberia?.dat data/string.dat data/animations/momo/mo_tcheque.nmo video/an video/*_hansanna.syb video/*_hansannab.syb video/c1_intro.syb textures/ingame textures/valreceptioninn'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='cmo data textures video'

CONFIG_FILES='./*.ini ./*/*.ini'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='game.exe'
APP_MAIN_ICON='syberia.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ID="$GAME_ID"
PKG_BIN_ARCH='32'
PKG_BIN_PROVIDE="$PKG_BIN_ID"
PKG_BIN_DEPS="$PKG_DATA_ID wine glx"

# Localization

PACKAGES_LIST="PKG_L10N $PACKAGES_LIST"
PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
PKG_BIN_DEPS="$PKG_BIN_DEPS $PKG_L10N_ID"

## English

PKG_BIN_ID_EN="${PKG_BIN_ID}-en"
PKG_L10N_ID_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_EN='English localization'

## French

PKG_BIN_ID_FR="${PKG_BIN_ID}-fr"
PKG_L10N_ID_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_FR='French localization'

## Russian

PKG_BIN_ID_RU="${PKG_BIN_ID}-ru"
PKG_L10N_ID_RU="${PKG_L10N_ID}-ru"
PKG_L10N_DESCRIPTION_RU='Russian localization'

# Load common functions

target_version='2.13'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
		'/usr/share/play.it'
	do
		if [ -e "${path}/libplayit2.sh" ]; then
			PLAYIT_LIB2="${path}/libplayit2.sh"
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

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Create player.ini file if one is not already provided

PKG='PKG_BIN'
config_file="$(package_get_path "$PKG")${PATH_GAME}/player.ini"
if [ ! -e "$config_file" ]; then
	cat > "$config_file" <<- EOF
	800 600 16 0 BaseCMO.cmo
	EOF
fi

# Work around a crash on nvidia drivers
# cf. https://bugs.winehq.org/show_bug.cgi?id=43199
#     https://bugs.winehq.org/show_bug.cgi?id=44009

PKG='PKG_BIN'
registry_file="$(package_get_path "$PKG")${PATH_GAME}/${APP_REGEDIT:=no-xvidmode.reg}"
cat > "$registry_file" << 'EOF'
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Wine\X11 Driver]
"UseXVidMode"="N"
EOF

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
