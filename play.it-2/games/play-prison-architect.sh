#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2019, BetaRays
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
# Prison Architect
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190929.1

# Set game-specific variables

GAME_ID='prison-architect'
GAME_NAME='Prison Architect'

ARCHIVE_GOG='prison_architect_clink_1_02_30664.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/prison_architect'
ARCHIVE_GOG_MD5='f261f6121e3fe9ae5023624098d3946d'
ARCHIVE_GOG_VERSION='1.02-gog30664'
ARCHIVE_GOG_SIZE='390000'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_HUMBLE='prisonarchitect-clink_1.02-linux.tar.gz'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/prison-architect'
ARCHIVE_HUMBLE_MD5='ecf4cf68e10069c3c2cb99bcc52ef417'
ARCHIVE_HUMBLE_VERSION='1.02-humble'
ARCHIVE_HUMBLE_SIZE='390000'
ARCHIVE_HUMBLE_TYPE='tar.gz'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*.txt'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='prisonarchitect-clink_1.0-linux'
ARCHIVE_GAME_BIN32_FILES='PrisonArchitect.i686 lib/libpops_api.so'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='prisonarchitect-clink_1.0-linux'
ARCHIVE_GAME_BIN64_FILES='PrisonArchitect.x86_64 lib64/libpops_api.so'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='prisonarchitect-clink_1.0-linux'
ARCHIVE_GAME_DATA_FILES='*.dat'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='export LANG=C'
APP_MAIN_EXE_BIN32='PrisonArchitect.i686'
APP_MAIN_EXE_BIN64='PrisonArchitect.x86_64'
APP_MAIN_ICON_GOG='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc glx glu sdl2 libstdc++"
PKG_BIN32_DEPS_DEB='libuuid1, zlib1g'
PKG_BIN32_DEPS_ARCH='libutil-linux zlib'
PKG_BIN32_DEPS_GENTOO='sys-apps/util-linux[abi_x86_32] sys-libs/zlib[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_ARCH='lib32-util-linux lib32-zlib'
PKG_BIN64_DEPS_GENTOO='sys-apps/util-linux sys-libs/zlib'

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

# Get game icon

PKG='PKG_DATA'
use_archive_specific_value 'APP_MAIN_ICON'
if [ -n "$APP_MAIN_ICON" ]; then
	icons_get_from_workdir 'APP_MAIN'
fi
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
