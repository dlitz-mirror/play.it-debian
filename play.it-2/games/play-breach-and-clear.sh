#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c)      2020, HS-157
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
# Breach & Clear
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200725.1

# Set game-specific variables

GAME_ID='breach-and-clear'
GAME_NAME="Breach & Clear"

ARCHIVE_GOG='gog_breach_clear_2.0.0.3.sh'
ARCHIVE_GOG_TYPE='mojosetup'
ARCHIVE_GOG_URL='https://www.gog.com/game/breach_and_clear'
ARCHIVE_GOG_MD5='e7f6b59d8ce97c9ab850b47608941b7d'
ARCHIVE_GOG_VERSION='2.1.1-gog2.0.0.3'
ARCHIVE_GOG_SIZE='2500000'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='Bnc_Nix.x86'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Bnc_Nix_Data'

APP_MAIN_TYPE='native'
APP_MAIN_ICON='./Bnc_Nix_Data/Resources/UnityPlayer.png'
APP_MAIN_EXE_BIN='Bnc_Nix.x86'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc glu xcursor libstdc++ glx"
PKG_BIN_DEPS_ARCH='lib32-libx11'
PKG_BIN_DEPS_DEB='libx11-6'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11[abi_x86_32]'


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
