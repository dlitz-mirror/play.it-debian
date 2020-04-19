#!/bin/sh
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
# Terraria
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200420.2

# Set game-specific variables

GAME_ID='terraria'
GAME_NAME='Terraria'

ARCHIVE_GOG='terraria_en_1_3_5_3_14602.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/terraria'
ARCHIVE_GOG_MD5='c99fdc0ae15dbff1e8147b550db4e31a'
ARCHIVE_GOG_SIZE='490000'
ARCHIVE_GOG_VERSION='1.3.5.3-gog14602'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_terraria_2.17.0.21.sh'
ARCHIVE_GOG_OLD0_MD5='90ec196ec38a7f7a5002f5a8109493cc'
ARCHIVE_GOG_OLD0_SIZE='487864'
ARCHIVE_GOG_OLD0_VERSION='1.3.5.3-gog2.17.0.21'

ARCHIVE_DOC_DATA_PATH='data/noarch/game'
ARCHIVE_DOC_DATA_FILES='changelog.txt'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='Terraria.bin.x86 TerrariaServer.bin.x86 lib'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='Terraria.bin.x86_64 TerrariaServer.bin.x86_64 lib64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Content Terraria.png monoconfig monomachineconfig open-folder *.dll *.dll.config *.exe'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# Work around terminfo Mono bug
# cf. https://github.com/mono/mono/issues/6752
export TERM="${TERM%-256color}"'
APP_MAIN_EXE_BIN32='Terraria.bin.x86'
APP_MAIN_EXE_BIN64='Terraria.bin.x86_64'
APP_MAIN_ICON='Terraria.png'

APP_SERVER_ID="$GAME_ID-server"
APP_SERVER_NAME="$GAME_NAME Server"
APP_SERVER_TYPE='native'
APP_SERVER_PRERUN="$APP_MAIN_PRERUN"
APP_SERVER_EXE_BIN32='TerrariaServer.bin.x86'
APP_SERVER_EXE_BIN64='TerrariaServer.bin.x86_64'
APP_SERVER_ICON='Terraria.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glu xcursor libxrandr"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icons

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN' 'APP_SERVER'

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN' 'APP_SERVER'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

#print instructions

print_instructions

exit 0
