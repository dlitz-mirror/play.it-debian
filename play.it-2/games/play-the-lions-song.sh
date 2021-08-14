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
# The Lion’s Song
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210413.5

# Set game-specific variables

GAME_ID='the-lions-song'
GAME_NAME='The Lionʼs Song'

ARCHIVES_LIST='
ARCHIVE_BASE_0'

ARCHIVE_BASE_0='the_lion_s_song_0_7_35794.sh'
ARCHIVE_BASE_0_MD5='bc86daa55b3afd2714bafce8e5bed230'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='360000'
ARCHIVE_BASE_0_VERSION='0.7-gog35794'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/the_lions_song'

ARCHIVE_GAME_BIN_PATH='data/noarch/game/GameData'
ARCHIVE_GAME_BIN_FILES='engine.cfg libsteam_api.so TLS'

ARCHIVE_GAME_DATA_PATH='data/noarch/game/GameData'
ARCHIVE_GAME_DATA_FILES='Assets *.base *.it *.en *.bundle *.es *.fr *.ru *.header *.universe *.world LZ4_license.txt Vollkorn_SILOpenFontLicensev1_10.txt'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='TLS'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

###
# TODO
# Add dependencies on the following libraries for Arch Linux and Gentoo:
# - libuuid.so.1
# - libX11.so.6
# - libXinerama.so.1
###
PKG_BIN_ARCH='64'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc libstdc++ libcurl libopenal.so.1 glx libz.so.1 libxrandr xcursor"
PKG_BIN_DEPS_DEB='libuuid1, libx11-6, libxinerama1'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
