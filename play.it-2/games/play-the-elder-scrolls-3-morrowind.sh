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
# The Elder Scrolls 3: Morrowind
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20210504.2

# Set game-specific variables

GAME_ID='the-elder-scrolls-3-morrowind'
GAME_NAME='The Elder Scrolls Ⅲ: Morrowind'

ARCHIVES_LIST='
ARCHIVE_BASE_EN_0
ARCHIVE_BASE_FR_0'

ARCHIVE_BASE_EN_0='setup_tes_morrowind_goty_2.0.0.7.exe'
ARCHIVE_BASE_EN_0_MD5='3a027504a0e4599f8c6b5b5bcc87a5c6'
ARCHIVE_BASE_EN_0_TYPE='innosetup'
ARCHIVE_BASE_EN_0_VERSION='1.6.1820-gog2.0.0.7'
ARCHIVE_BASE_EN_0_SIZE='2300000'
ARCHIVE_BASE_EN_0_URL='https://www.gog.com/game/the_elder_scrolls_iii_morrowind_goty_edition'

ARCHIVE_BASE_FR_0='setup_tes_morrowind_goty_french_2.0.0.7.exe'
ARCHIVE_BASE_FR_0_MD5='2aee024e622786b2cb5454ff074faf9b'
ARCHIVE_BASE_FR_0_TYPE='innosetup'
ARCHIVE_BASE_FR_0_VERSION='1.6.1820-gog2.0.0.7'
ARCHIVE_BASE_FR_0_SIZE='2300000'
ARCHIVE_BASE_FR_0_URL='https://www.gog.com/game/the_elder_scrolls_iii_morrowind_goty_edition'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='*.pdf'

ARCHIVE_DOC_L10N_PATH='app'
ARCHIVE_DOC_L10N_FILES='*.txt'

ARCHIVE_GAME_BIN_WINE_PATH='app'
ARCHIVE_GAME_BIN_WINE_FILES='*.exe binkw32.dll tes?construction?set.cnt tes?construction?set.hlp'

ARCHIVE_GAME_L10N_PATH='app'
ARCHIVE_GAME_L10N_FILES='morrowind.ini data?files/*.bsa data?files/*.esm data?files/sound/vo data?files/splash data?files/video/bethesda?logo.bik data?files/video/bm_bearhunt?.bik data?files/video/bm_ceremony?.bik data?files/video/bm_endgame.bik data?files/video/bm_frostgiant?.bik data?files/video/mw_cavern.bik data?files/video/mw_credits.bik data?files/video/mw_end.bik data?files/video/mw_intro.bik data?files/video/mw_logo.bik'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='data?files/*.esp data?files/fonts data?files/music data?files/sound/cr data?files/sound/fx data?files/*.txt data?files/video/bm_were*.bik data?files/video/mw_menu.bik knife.ico'

ARCHIVE_GAME_DATAFILES_DATA_PATH='app/_officialplugins/_unpacked_files'
ARCHIVE_GAME_DATAFILES_DATA_FILES='*'

CONFIG_FILES='./*.ini'
DATA_DIRS='./saves'
DATA_FILES='./ProgramFlow.txt ./Warnings.txt ./Journal.htm'

APP_MAIN_TYPE_BIN_WINE='wine'
APP_MAIN_TYPE_BIN_OPENMW='native'
APP_MAIN_EXE='morrowind launcher.exe'
APP_MAIN_ICON='morrowind.exe'

## Packages

PACKAGES_LIST='PKG_BIN_WINE PKG_BIN_OPENMW PKG_L10N PKG_DATA'

# Localization — common properties

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"

# Localization — English version

PKG_L10N_ID_BASE_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_BASE_EN='English localization'

# Localization — French version

PKG_L10N_ID_BASE_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_BASE_FR='French localization'

# Static assets

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

# Binaries — common properties

PKG_BIN_ID="$GAME_ID"

# Binaries, WINE-powered — common properties

PKG_BIN_WINE_ID="${PKG_BIN_ID}-wine"
PKG_BIN_WINE_ARCH='32'
PKG_BIN_WINE_PROVIDE="$PKG_BIN_ID"
PKG_BIN_WINE_DEPS="${PKG_L10N_ID} ${PKG_DATA_ID} wine glx"
PKG_BIN_WINE_DEPS_ARCH='lib32-gst-plugins-good'
PKG_BIN_WINE_DEPS_DEB='gstreamer1.0-plugins-good'
PKG_BIN_WINE_DEPS_GENTOO='media-plugins/gst-plugins-mpg123[abi_x86_32]'

# Binaries, WINE-powered — English version

PKG_BIN_WINE_ID_BASE_EN="${PKG_BIN_WINE_ID}-en"
PKG_BIN_WINE_DESCRIPTION_BASE_EN='English version'

# Binaries, WINE-powered — French version

PKG_BIN_WINE_ID_BASE_FR="${PKG_BIN_WINE_ID}-fr"
PKG_BIN_WINE_DESCRIPTION_BASE_FR='French version'

# Binaries, OpenMW-powered

PKG_BIN_OPENMW_ID="${PKG_BIN_ID}-openmw"
PKG_BIN_OPENMW_PROVIDE="$PKG_BIN_ID"
PKG_BIN_OPENMW_DEPS="${PKG_L10N_ID} ${PKG_DATA_ID}"
PKG_BIN_OPENMW_DEPS_ARCH='openmw'
PKG_BIN_OPENMW_DEPS_DEB='openmw, openmw-launcher'
PKG_BIN_OPENMW_DEPS_GENTOO='games-engines/openmw'

# Easier upgrade from packages generated with pre-20190204.1 scripts

PKG_DATA_PROVIDE='morrowind-data'

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
PKG='PKG_DATA'
organize_data 'GAME_DATAFILES_DATA' "$PATH_GAME/data files"

# Extract icons

PKG='PKG_BIN_WINE'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Fix .bsa/.esm dates on French version

case "$ARCHIVE" in
	('ARCHIVE_BASE_FR_0'*)
		touch --date='2002-06-21 17:31:46.000000000 +0200' \
			"${PKG_L10N_PATH}${PATH_GAME}/data files/morrowind.bsa"
		touch --date='2002-07-17 18:59:22.000000000 +0200' \
			"${PKG_L10N_PATH}${PATH_GAME}/data files/morrowind.esm"
		touch --date='2002-10-29 21:22:06.000000000 +0100' \
			"${PKG_L10N_PATH}${PATH_GAME}/data files/tribunal.bsa"
		touch --date='2003-06-26 20:05:06.000000000 +0200' \
			"${PKG_L10N_PATH}${PATH_GAME}/data files/tribunal.esm"
		touch --date='2003-05-01 13:37:30.000000000 +0200' \
			"${PKG_L10N_PATH}${PATH_GAME}/data files/bloodmoon.bsa"
		touch --date='2003-07-07 17:27:56.000000000 +0200' \
			"${PKG_L10N_PATH}${PATH_GAME}/data files/bloodmoon.esm"
	;;
esac

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

PKG='PKG_BIN_WINE'
use_package_specific_value 'APP_MAIN_TYPE'
launchers_write 'APP_MAIN'

PKG='PKG_BIN_OPENMW'
use_package_specific_value 'APP_MAIN_TYPE'
launcher_file="${PKG_BIN_OPENMW_PATH}${PATH_BIN}/${GAME_ID}"
mkdir --parents "$(dirname "$launcher_file")"
touch "$launcher_file"
chmod 755 "$launcher_file"
launcher_write_script_headers "$launcher_file"

# In the following here-document ShellCheck treats the inner "EOF" tokens as tokens for the outer here-document indented by error
# shellcheck disable=SC1039
cat >> "$launcher_file" << EOF
OPENMW_CONFIG_PATH="\${XDG_CONFIG_HOME:=\$HOME/.config}/openmw"
OPENMW_CONFIG_FILE="\${OPENMW_CONFIG_PATH}/openmw.cfg"
OPENMW_CONFIG_LAUNCHER_FILE="\${OPENMW_CONFIG_PATH}/launcher.cfg"

# Initialize OpenMW configuration on first launch
if [ ! -e "\$OPENMW_CONFIG_FILE" ]; then
	mkdir --parents "\$OPENMW_CONFIG_PATH"
	cat > "\$OPENMW_CONFIG_FILE" <<- EOF
	data="$PATH_GAME/data files"
	content=morrowind.esm
	EOF
	openmw-iniimporter --ini "$PATH_GAME/morrowind.ini" --cfg "\$OPENMW_CONFIG_FILE"
	if [ ! -e "\$OPENMW_CONFIG_LAUNCHER_FILE" ]; then
		cat > "\$OPENMW_CONFIG_LAUNCHER_FILE" <<- EOF
		[General]
		firstrun=false
		EOF
	fi
fi

openmw-launcher

exit 0
EOF

launcher_write_desktop 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

printf '\n'
printf 'OpenMW:'
print_instructions 'PKG_DATA' 'PKG_L10N' 'PKG_BIN_OPENMW'
printf 'WINE:'
print_instructions 'PKG_DATA' 'PKG_L10N' 'PKG_BIN_WINE'

exit 0
