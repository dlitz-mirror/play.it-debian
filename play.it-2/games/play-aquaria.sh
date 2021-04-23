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
# Aquaria
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210423.2

# Set game-specific variables

GAME_ID='aquaria'
GAME_NAME='Aquaria'

ARCHIVES_LIST='
ARCHIVE_GOG
ARCHIVE_GOG_OLD'

ARCHIVE_GOG='gog_aquaria_2.0.0.5.sh'
ARCHIVE_GOG_MD5='4235398debdf268f233881fade9e0530'
ARCHIVE_GOG_TYPE='mojosetup'
ARCHIVE_GOG_SIZE='240000'
ARCHIVE_GOG_VERSION='1.1.3-gog2.0.0.5'
ARCHIVE_GOG_URL='https://www.gog.com/game/aquaria'

ARCHIVE_GOG_OLD='gog_aquaria_2.0.0.4.sh'
ARCHIVE_GOG_OLD_MD5='1810de0d68028c6ec01d33181086180d'
ARCHIVE_GOG_OLD_TYPT='mojosetup'
ARCHIVE_GOG_OLD_SIZE='280000'
ARCHIVE_GOG_OLD_VERSION='1.1.3-gog2.0.0.4'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game'
ARCHIVE_DOC1_DATA_FILES='docs/* *.txt'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='aquaria config *.xml'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='aquaria.png data gfx _mods mus scripts sfx vox'

CONFIG_FILES='./*.xml ./config/*'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='aquaria'
APP_MAIN_ICON='aquaria.png'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS_DEB="$PKG_DATA_ID, libc6, libstdc++6, libgl1-mesa-glx | libgl1, libsdl1.2debian, libopenal1, xdg-utils"
PKG_BIN_DEPS_ARCH="${PKG_DATA_ID} lib32-glibc lib32-gcc-libs lib32-libgl lib32-sdl lib32-openal xdg-utils"

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

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

#print instructions

print_instructions

exit 0
