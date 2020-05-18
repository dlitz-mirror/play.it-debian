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
# Convoy
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190611.3

# Set game-specific variables

GAME_ID='convoy'
GAME_NAME='Convoy'

ARCHIVE_GOG='convoy_1_1_54_27852.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/convoy'
ARCHIVE_GOG_MD5='2f7dd6c597e07638650cc01883e0367f'
ARCHIVE_GOG_SIZE='860000'
ARCHIVE_GOG_VERSION='1.1.54-gog27852'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='convoy_1_1_53_27205.sh'
ARCHIVE_GOG_OLD2_MD5='cda02a99f12adc608a0193f75fc9d7d3'
ARCHIVE_GOG_OLD2_SIZE='860000'
ARCHIVE_GOG_OLD2_VERSION='1.1.53-gog27205'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='convoy_1_1_52_26363.sh'
ARCHIVE_GOG_OLD1_MD5='99b331906d75443f08c4f787bc83a7ef'
ARCHIVE_GOG_OLD1_SIZE='860000'
ARCHIVE_GOG_OLD1_VERSION='1.1.52-gog26363'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_convoy_2.4.0.7.sh'
ARCHIVE_GOG_OLD0_MD5='2d66599173990eb202a43dbc547c80f5'
ARCHIVE_GOG_OLD0_SIZE='860000'
ARCHIVE_GOG_OLD0_VERSION='1.1.51-gog2.4.0.7'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='Convoy.x86 Convoy_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='Convoy.x86_64 Convoy_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Convoy_Data'

CONFIG_FILES='./*.ini'
DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='export TERM="${TERM%-256color}"'
APP_MAIN_EXE_BIN32='Convoy.x86'
APP_MAIN_EXE_BIN64='Convoy.x86_64'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='Convoy_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ gtk2 glx"
PKG_BIN32_DEPS_ARCH='lib32-gdk-pixbuf2 lib32-glib2'
PKG_BIN32_DEPS_DEB='libgdk-pixbuf2.0-0, libglib2.0-0'
PKG_BIN32_DEPS_GENTOO='x11-libs/gdk-pixbuf[abi_x86_32] dev-libs/glib[abi_x86_32]'
# Keep compatibility with old archives
PKG_BIN32_DEPS_GOG_OLD0="$PKG_DATA_ID glibc libstdc++ glu glx xcursor"
PKG_BIN32_DEPS_ARCH_GOG_OLD0='lib32-libx11'
PKG_BIN32_DEPS_DEB_GOG_OLD0='libx11-6'
PKG_BIN32_DEPS_GENTOO_GOG_OLD0='x11-libs/libX11[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='gdk-pixbuf2 glib2'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/gdk-pixbuf dev-libs/glib'
# Keep compatibility with old archives
PKG_BIN64_DEPS_GOG_OLD0="$PKG_BIN32_DEPS_GOG_OLD0"
PKG_BIN64_DEPS_ARCH_GOG_OLD0='libx11'
PKG_BIN64_DEPS_DEB_GOG_OLD0="$PKG_BIN32_DEPS_DEB_GOG_OLD0"
PKG_BIN64_DEPS_GENTOO_GOG_OLD0='x11-libs/libX11'

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

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
