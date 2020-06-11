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
# Fallout: New Vegas
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210508.12

# Set game-specific variables

GAME_ID='fallout-new-vegas'
GAME_NAME='Fallout: New Vegas'

ARCHIVE_BASE_EN_0='setup_fallout_new_vegas_1.4.0.525_(12010).exe'
ARCHIVE_BASE_EN_0_MD5='be32894fe423302d299fa532e5641079'
ARCHIVE_BASE_EN_0_TYPE='innosetup'
ARCHIVE_BASE_EN_0_PART1='setup_fallout_new_vegas_1.4.0.525_(12010)-1.bin'
ARCHIVE_BASE_EN_0_PART1_MD5='245661b2e1435c530763ae281ccecd9f'
ARCHIVE_BASE_EN_0_PART1_TYPE='innosetup'
ARCHIVE_BASE_EN_0_PART2='setup_fallout_new_vegas_1.4.0.525_(12010)-2.bin'
ARCHIVE_BASE_EN_0_PART2_MD5='705e7097b9c18836118c2e9eb42b19ed'
ARCHIVE_BASE_EN_0_PART2_TYPE='innosetup'
ARCHIVE_BASE_EN_0_VERSION='1.4.0.525-gog12010'
ARCHIVE_BASE_EN_0_SIZE='11000000'
ARCHIVE_BASE_EN_0_URL='https://www.gog.com/game/fallout_new_vegas_ultimate_edition'

ARCHIVE_BASE_FR_0='setup_fallout_new_vegas_french_1.4.0.525_(12010).exe'
ARCHIVE_BASE_FR_0_MD5='da79e8756efb16b211a76756cd8865b3'
ARCHIVE_BASE_FR_0_TYPE='innosetup'
ARCHIVE_BASE_FR_0_PART1='setup_fallout_new_vegas_french_1.4.0.525_(12010)-1.bin'
ARCHIVE_BASE_FR_0_PART1_MD5='245661b2e1435c530763ae281ccecd9f'
ARCHIVE_BASE_FR_0_PART1_TYPE='innosetup'
ARCHIVE_BASE_FR_0_PART2='setup_fallout_new_vegas_french_1.4.0.525_(12010)-2.bin'
ARCHIVE_BASE_FR_0_PART2_MD5='e148a49b1bbcfa4b2662e45691ae606e'
ARCHIVE_BASE_FR_0_PART2_TYPE='innosetup'
ARCHIVE_BASE_FR_0_VERSION='1.4.0.525-gog12010'
ARCHIVE_BASE_FR_0_SIZE='11000000'
ARCHIVE_BASE_FR_0_URL='https://www.gog.com/game/fallout_new_vegas_ultimate_edition'

ARCHIVE_DOC_L10N_PATH='app'
ARCHIVE_DOC_L10N_FILES='*.txt'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.dll falloutnv.exe geck.exe low.ini medium.ini high.ini veryhigh.ini'

ARCHIVE_GAME_L10N_PATH='app'
ARCHIVE_GAME_L10N_FILES='falloutnvlauncher.exe fallout_default.ini data/credits.txt data/creditswacky.txt data/falloutnv.esm data/fallout?-?voices1.bsa data/video/fnvintro.bik'

ARCHIVE_GAME_DLC1_PATH='app'
ARCHIVE_GAME_DLC1_FILES='data/deadmoney*'

ARCHIVE_GAME_DLC2_PATH='app'
ARCHIVE_GAME_DLC2_FILES='data/honesthearts*'

ARCHIVE_GAME_DLC3_PATH='app'
ARCHIVE_GAME_DLC3_FILES='data/oldworldblues*'

ARCHIVE_GAME_DLC4_PATH='app'
ARCHIVE_GAME_DLC4_FILES='data/lonesomeroad*'

ARCHIVE_GAME_DLC5_PATH='app'
ARCHIVE_GAME_DLC5_FILES='data/gunrunnersarsenal*'

ARCHIVE_GAME_DLC6_PATH='app'
ARCHIVE_GAME_DLC6_FILES='data/caravanpack*'

ARCHIVE_GAME_DLC7_PATH='app'
ARCHIVE_GAME_DLC7_FILES='data/classicpack*'

ARCHIVE_GAME_DLC8_PATH='app'
ARCHIVE_GAME_DLC8_FILES='data/mercenarypack*'

ARCHIVE_GAME_DLC9_PATH='app'
ARCHIVE_GAME_DLC9_FILES='data/tribalpack*'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='maintitle.wav geckicon.ico data falloutnv.ico'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='falloutnvlauncher.exe'
APP_MAIN_ICON='falloutnv.ico'

APP_EDITOR_ID="${GAME_ID}_editor"
APP_EDITOR_NAME="${GAME_NAME} - Editor"
APP_EDITOR_TYPE='wine'
APP_EDITOR_EXE='geck.exe'
APP_EDITOR_ICON='geckicon.ico'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DLC1 PKG_DLC2 PKG_DLC3 PKG_DLC4 PKG_DLC5 PKG_DLC6 PKG_DLC7 PKG_DLC8 PKG_DLC9 PKG_DATA'

# Data package

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

# Localization package - common properties

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"

# Localization package - English version

PKG_L10N_ID_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_EN='English localization'

# Localization package - French version

PKG_L10N_ID_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_FR='French localization'

# Binaries package

PKG_BIN_ID="$GAME_ID"
PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_L10N_ID} ${PKG_DATA_ID} wine glx libasound_module_conf_pulse.so"

# Expansion packages

PKG_DLC1_ID="${GAME_ID}-dlc-dead-money"
PKG_DLC1_DESCRIPTION='Dead Money'
PKG_DLC1_PROVIDE="$PKG_DLC1_ID"
PKG_DLC1_DEPS="$PKG_BIN_ID"
PKG_DLC1_ID_EN="${PKG_DLC1_ID}-en"
PKG_DLC1_ID_FR="${PKG_DLC1_ID}-fr"
PKG_DLC1_DESCRIPTION_EN="${PKG_DLC1_DESCRIPTION} - English version"
PKG_DLC1_DESCRIPTION_FR="${PKG_DLC1_DESCRIPTION} - French version"

PKG_DLC2_ID="${GAME_ID}-dlc-honest-hearts"
PKG_DLC2_DESCRIPTION='Honest Hearts'
PKG_DLC2_PROVIDE="$PKG_DLC2_ID"
PKG_DLC2_DEPS="$PKG_BIN_ID"
PKG_DLC2_ID_EN="${PKG_DLC2_ID}-en"
PKG_DLC2_ID_FR="${PKG_DLC2_ID}-fr"
PKG_DLC2_DESCRIPTION_EN="${PKG_DLC2_DESCRIPTION} - English version"
PKG_DLC2_DESCRIPTION_FR="${PKG_DLC2_DESCRIPTION} - French version"

PKG_DLC3_ID="${GAME_ID}-dlc-old-world-blues"
PKG_DLC3_DESCRIPTION='Old World Blues'
PKG_DLC3_PROVIDE="$PKG_DLC3_ID"
PKG_DLC3_DEPS="$PKG_BIN_ID"
PKG_DLC3_ID_EN="${PKG_DLC3_ID}-en"
PKG_DLC3_ID_FR="${PKG_DLC3_ID}-fr"
PKG_DLC3_DESCRIPTION_EN="${PKG_DLC3_DESCRIPTION} - English version"
PKG_DLC3_DESCRIPTION_FR="${PKG_DLC3_DESCRIPTION} - French version"

PKG_DLC4_ID="${GAME_ID}-dlc-lonesome-road"
PKG_DLC4_DESCRIPTION='Lonesome Road'
PKG_DLC4_PROVIDE="$PKG_DLC4_ID"
PKG_DLC4_DEPS="$PKG_BIN_ID"
PKG_DLC4_ID_EN="${PKG_DLC4_ID}-en"
PKG_DLC4_ID_FR="${PKG_DLC4_ID}-fr"
PKG_DLC4_DESCRIPTION_EN="${PKG_DLC4_DESCRIPTION} - English version"
PKG_DLC4_DESCRIPTION_FR="${PKG_DLC4_DESCRIPTION} - French version"

PKG_DLC5_ID="${GAME_ID}-dlc-gun-runners-arsenal"
PKG_DLC5_DESCRIPTION='Gun Runnersʼ Arsenal'
PKG_DLC5_PROVIDE="$PKG_DLC5_ID"
PKG_DLC5_DEPS="$PKG_BIN_ID"
PKG_DLC5_ID_EN="${PKG_DLC5_ID}-en"
PKG_DLC5_ID_FR="${PKG_DLC5_ID}-fr"
PKG_DLC5_DESCRIPTION_EN="${PKG_DLC5_DESCRIPTION} - English version"
PKG_DLC5_DESCRIPTION_FR="${PKG_DLC5_DESCRIPTION} - French version"

PKG_DLC6_ID="${GAME_ID}-dlc-caravan-pack"
PKG_DLC6_DESCRIPTION='Caravan Pack'
PKG_DLC6_PROVIDE="$PKG_DLC6_ID"
PKG_DLC6_DEPS="$PKG_BIN_ID"
PKG_DLC6_ID_EN="${PKG_DLC6_ID}-en"
PKG_DLC6_ID_FR="${PKG_DLC6_ID}-fr"
PKG_DLC6_DESCRIPTION_EN="${PKG_DLC6_DESCRIPTION} - English version"
PKG_DLC6_DESCRIPTION_FR="${PKG_DLC6_DESCRIPTION} - French version"

PKG_DLC7_ID="${GAME_ID}-dlc-classic-pack"
PKG_DLC7_DESCRIPTION='Classic Pack'
PKG_DLC7_PROVIDE="$PKG_DLC7_ID"
PKG_DLC7_DEPS="$PKG_BIN_ID"
PKG_DLC7_ID_EN="${PKG_DLC7_ID}-en"
PKG_DLC7_ID_FR="${PKG_DLC7_ID}-fr"
PKG_DLC7_DESCRIPTION_EN="${PKG_DLC7_DESCRIPTION} - English version"
PKG_DLC7_DESCRIPTION_FR="${PKG_DLC7_DESCRIPTION} - French version"

PKG_DLC8_ID="${GAME_ID}-dlc-mercenary-pack"
PKG_DLC8_DESCRIPTION='Mercenary Pack'
PKG_DLC8_PROVIDE="$PKG_DLC8_ID"
PKG_DLC8_DEPS="$PKG_BIN_ID"
PKG_DLC8_ID_EN="${PKG_DLC8_ID}-en"
PKG_DLC8_ID_FR="${PKG_DLC8_ID}-fr"
PKG_DLC8_DESCRIPTION_EN="${PKG_DLC8_DESCRIPTION} - English version"
PKG_DLC8_DESCRIPTION_FR="${PKG_DLC8_DESCRIPTION} - French version"

PKG_DLC9_ID="${GAME_ID}-dlc-tribal-pack"
PKG_DLC9_DESCRIPTION='Tribal Pack'
PKG_DLC9_PROVIDE="$PKG_DLC9_ID"
PKG_DLC9_DEPS="$PKG_BIN_ID"
PKG_DLC9_ID_EN="${PKG_DLC9_ID}-en"
PKG_DLC9_ID_FR="${PKG_DLC9_ID}-fr"
PKG_DLC9_DESCRIPTION_EN="${PKG_DLC9_DESCRIPTION} - English version"
PKG_DLC9_DESCRIPTION_FR="${PKG_DLC9_DESCRIPTION} - French version"

# Use persistent storage for saved games and settings

APP_WINE_LINK_DIRS='userdata:users/${USER}/My Documents/My Games/FalloutNV'
CONFIG_FILES='userdata/*.ini'
DATA_DIRS='userdata/Saves'

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

# Extract game icons

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN' 'APP_EDITOR'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Set required registry key

registry_file='registry-dumps/init.reg'
registry_file_path="$(package_get_path 'PKG_BIN')${PATH_GAME}/${registry_file}"

APP_REGEDIT="${APP_REGEDIT} ${registry_file}"

mkdir --parents "$(dirname "$registry_file_path")"
cat > "$registry_file_path" << EOF
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\\Software\\Bethesda Softworks\\FalloutNV]
"Installed Path"="C:\\\\${GAME_ID}/"
EOF

# Write launchers

PKG='PKG_BIN'
# Work around the binary presence check on the game launcher
# This binary is provided by the localization package
binary_file="$(package_get_path 'PKG_BIN')${PATH_GAME}/${APP_MAIN_EXE}"
binary_directory=$(dirname "$binary_file")
mkdir --parents "$binary_directory"
touch "$binary_file"
launchers_write 'APP_MAIN' 'APP_EDITOR'
rm "$binary_file"
rmdir --parents --ignore-fail-on-non-empty "$binary_directory"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
