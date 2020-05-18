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
# State of Mind
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200205.3

# Set game-specific variables

GAME_ID='state-of-mind'
GAME_NAME='State of Mind'

ARCHIVE_GOG='state_of_mind_1_2_24280_24687.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/state_of_mind'
ARCHIVE_GOG_MD5='e27071ec1041dc7e529f5fe590783f72'
ARCHIVE_GOG_SIZE='21000000'
ARCHIVE_GOG_VERSION='1.2.24280-gog24687'
ARCHIVE_GOG_TYPE='mojosetup_unzip'

ARCHIVE_DOC_DATA_PATH='data/noarch/game'
ARCHIVE_DOC_DATA_FILES='LICENSE.txt version.txt'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='Engine StateOfMind/Binaries StateOfMind.cfg'

ARCHIVE_GAME_PAKS1_PATH='data/noarch/game'
ARCHIVE_GAME_PAKS1_FILES='StateOfMind/Content/Paks/pakchunk0-LinuxNoEditor.pak StateOfMind/Content/Paks/pakchunk1-LinuxNoEditor.pak StateOfMind/Content/Paks/pakchunk2-LinuxNoEditor.pak'

ARCHIVE_GAME_PAKS2_PATH='data/noarch/game'
ARCHIVE_GAME_PAKS2_FILES='StateOfMind/Content/Paks/pakchunk3-LinuxNoEditor.pak StateOfMind/Content/Paks/pakchunk4-LinuxNoEditor.pak StateOfMind/Content/Paks/pakchunk5-LinuxNoEditor.pak'

ARCHIVE_GAME_PAKS3_PATH='data/noarch/game'
ARCHIVE_GAME_PAKS3_FILES='StateOfMind/Content/Paks/pakchunk6-LinuxNoEditor.pak StateOfMind/Content/Paks/pakchunk7-LinuxNoEditor.pak'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='StateOfMind/Content StateOfMind.png StateOfMind.desktop'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='StateOfMind/Binaries/Linux/StateOfMind-Linux-Shipping'
APP_MAIN_OPTIONS='StateOfMind'
APP_MAIN_ICON='StateOfMind.png'

PACKAGES_LIST='PKG_BIN PKG_PAKS1 PKG_PAKS2 PKG_PAKS3 PKG_DATA'

PKG_PAKS1_ID="${GAME_ID}-paks-1"
PKG_PAKS1_DESCRIPTION='data paks - 1'

PKG_PAKS2_ID="${GAME_ID}-paks-2"
PKG_PAKS2_DESCRIPTION='data paks - 2'

PKG_PAKS3_ID="${GAME_ID}-paks-3"
PKG_PAKS3_DESCRIPTION='data paks - 3'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DEPS="$PKG_PAKS1_ID $PKG_PAKS2_ID $PKG_PAKS3_ID"

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ openal"

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

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
