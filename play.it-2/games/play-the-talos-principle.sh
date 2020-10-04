#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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
# The Talos Principle
# build native Linux packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201004.3

# Set game-specific variables

SCRIPT_DEPS='dos2unix'

GAME_ID='the-talos-principle'
GAME_NAME='The Talos Principle'

ARCHIVE_GOG='setup_the_talos_principle_1.0_(64bit)_(41435).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_talos_principle_gold_edition'
ARCHIVE_GOG_MD5='769f3ba085c913d2bc44e22726bdadc8'
ARCHIVE_GOG_SIZE='6900000'
ARCHIVE_GOG_VERSION='1.0-gog41435'
ARCHIVE_GOG_TYPE='innosetup_nolowercase'

ARCHIVE_GOG_PART1='setup_the_talos_principle_1.0_(64bit)_(41435)-1.bin'
ARCHIVE_GOG_PART1_MD5='4b94687328d0017b219e932ce73c44f5'
ARCHIVE_GOG_PART1_TYPE='innosetup'

ARCHIVE_GOG_PART2='setup_the_talos_principle_1.0_(64bit)_(41435)-2.bin'
ARCHIVE_GOG_PART2_MD5='4216d66194c80ef8cfbfb5eeff82a54a'
ARCHIVE_GOG_PART2_TYPE='innosetup'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='Bin'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='Content'

DATA_DIRS='./UserData'
CONFIG_FILES='./UserCfg.lua'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='Bin/x64/Talos.exe'
APP_MAIN_ICON='Bin/x64/Talos.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks"

# Set minimal configuration file

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Set minimal configuration file
CONF_FILE="UserData/Talos.ini"
if [ ! -e "$CONF_FILE" ] ; then
	cat > "$CONF_FILE" <<- EOF
	gfx_strAPI = "Vulkan";
	sfx_strAPI = "XAudio";
	sfx_strAudioDevice = "ID:0";
	EOF
fi'

# Load common functions

target_version='2.12'

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

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Work around broken graphics driver detection code

lua_file="${PKG_DATA_PATH}${PATH_GAME}/Content/Talos/Config/CheckDriver.lua"
cat > "$lua_file" << 'EOF'
-- assume no driver version detection
gfx_iReqDriverVersion = 0;
gfx_bWrongDriver = 0;
EOF
unix2dos "$lua_file" >/dev/null 2>&1

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
