#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2020, macaron
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
# Monkey Island 4: Escape from Monkey Island
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200710.2

# Set game-specific variables

GAME_ID='monkey-island-4'
GAME_NAME='Monkey Island 4: Escape from Monkey Island'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0'

ARCHIVE_GOG_EN_0='setup_escape_from_monkey_islandtm_1.1_(20987).exe'
ARCHIVE_GOG_EN_0_MD5='54978965b60294d5c1639b71c0a8159a'
ARCHIVE_GOG_EN_0_URL='https://www.gog.com/game/escape_from_monkey_island'
ARCHIVE_GOG_EN_0_VERSION='1.1-gog20987'
ARCHIVE_GOG_EN_0_SIZE='1300000'
ARCHIVE_GOG_EN_0_PART1='setup_escape_from_monkey_islandtm_1.1_(20987)-1.bin'
ARCHIVE_GOG_EN_0_PART1_MD5='21bc4e362f73b76e6808649167ee9d20'
ARCHIVE_GOG_EN_0_PART1_TYPE='innosetup'

ARCHIVE_GOG_FR_0='setup_escape_from_monkey_islandtm_1.1_(french)_(20987).exe'
ARCHIVE_GOG_FR_0_MD5='5ca039d42d53ad7fe206b289abe15deb'
ARCHIVE_GOG_FR_0_URL='https://www.gog.com/game/escape_from_monkey_island'
ARCHIVE_GOG_FR_0_VERSION='1.1-gog20987'
ARCHIVE_GOG_FR_0_SIZE='1300000'
ARCHIVE_GOG_FR_0_PART1='setup_escape_from_monkey_islandtm_1.1_(french)_(20987)-1.bin'
ARCHIVE_GOG_FR_0_PART1_MD5='c5bf233f09cca2a8e33d78d25cf58329'
ARCHIVE_GOG_FR_0_PART1_TYPE='innosetup'

ARCHIVE_DOC_L10N_PATH='.'
ARCHIVE_DOC_L10N_FILES='*.pdf *.txt'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.asi *.dll *.exe *.flt'

ARCHIVE_GAME_L10N_PATH='.'
ARCHIVE_GAME_L10N_FILES='movies art???.m4b i9n.m4b lip.m4b voice???.m4b'

ARCHIVE_GAME0_DATA_PATH='.'
ARCHIVE_GAME0_DATA_FILES='textures local.m4b patch.m4b sfx.m4b'

ARCHIVE_GAME1_DATA_PATH='__support/save'
ARCHIVE_GAME1_DATA_FILES='saves'

CONFIG_FILES='saves/efmi.cfg'
DATA_FILES='saves/efmi*.gsv'

APP_REGEDIT='install.reg'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='monkey4.exe'
APP_MAIN_ICON='monkey4.exe'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

# architecture-independent common data package
PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

# localization package — common properties
PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"

# localization package — English version
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'

# localization package — French version
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

# binaries package — common properties
PKG_BIN_ID="$GAME_ID"
PKG_BIN_PROVIDE="$PKG_BIN_ID"
PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID $PKG_L10N_ID wine"

# binaries package — English version
PKG_BIN_ID_GOG_EN="${PKG_BIN_ID}-en"
PKG_BIN_DESCRIPTION_GOG_EN='English version'

# binaries package — French version
PKG_BIN_ID_GOG_FR="${PKG_BIN_ID}-fr"
PKG_BIN_DESCRIPTION_GOG_FR='French version'

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

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Register install path

cat > "${PKG_BIN_PATH}${PATH_GAME}/install.reg" << EOF
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\\Software\\LucasArts Entertainment Company LLC\\Monkey4\\Retail]
"Install Path"="C:\\\\$GAME_ID"
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
