#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# SteamWorld Dig
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200218.1

# Set game-specific variables

GAME_ID='steamworld-dig'
GAME_NAME='SteamWorld Dig'

ARCHIVE_GOG='gog_steamworld_dig_2.0.0.7.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/steamworld_dig'
ARCHIVE_GOG_MD5='2f2ed68e00f151ff3c4d0092d8d6b15b'
ARCHIVE_GOG_SIZE='79000'
ARCHIVE_GOG_VERSION='1.10-gog2.0.0.7'

ARCHIVE_HUMBLE='SteamWorldDig_linux_1393468453.tar.gz'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/steamworld-dig'
ARCHIVE_HUMBLE_MD5='de6ff6273c4e397413d852472d51e788'
ARCHIVE_HUMBLE_SIZE='77000'
ARCHIVE_HUMBLE_VERSION='1.10-humble140220'

ARCHIVE_DOC_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC_DATA_PATH_HUMBLE='SteamWorldDig'
ARCHIVE_DOC_DATA_FILES='readme.txt Licenses'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='SteamWorldDig'
ARCHIVE_GAME_BIN_FILES='SteamWorldDig'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='SteamWorldDig'
ARCHIVE_GAME_DATA_FILES='icon.* BundlePC'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='SteamWorldDig'
APP_MAIN_ICON='icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx openal"

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

#print instructions

print_instructions

exit 0
