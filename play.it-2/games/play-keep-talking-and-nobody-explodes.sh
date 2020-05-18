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
# Keep Talking and Nobody Explodes
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190629.1

# Set game-specific variables

GAME_ID='keep-talking-and-nobody-explodes'
GAME_NAME='Keep Talking and Nobody Explodes'

ARCHIVE_HUMBLE='Keep_Talking_and_Nobody_Explodes_1.8.3_-_StandaloneLinuxUniversal_Default.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/keep-talking-and-nobody-explodes'
ARCHIVE_HUMBLE_MD5='212e7d380c7214f87b05aa405fa41662'
ARCHIVE_HUMBLE_VERSION='1.8.3-humble190307'
ARCHIVE_HUMBLE_SIZE='860000'

ARCHIVE_HUMBLE_OLD0='Keep_Talking_and_Nobody_Explodes_1.6.1_-_Linux.zip'
ARCHIVE_HUMBLE_OLD0_MD5='ac321144f9ed9dc6797d35a33bd0b0e7'
ARCHIVE_HUMBLE_OLD0_VERSION='1.6.1-humble171219'
ARCHIVE_HUMBLE_OLD0_SIZE='940000'

ARCHIVE_OPTIONAL_MANUAL='Bomb-Defusal-Manual_1.pdf'
ARCHIVE_OPTIONAL_MANUAL_URL='http://www.bombmanual.com/manual/1/pdf/Bomb-Defusal-Manual_1.pdf'
ARCHIVE_OPTIONAL_MANUAL_MD5='fde93a9ad8de6ab04bdff40359145e11'
ARCHIVE_OPTIONAL_MANUAL_TYPE='misc'

ARCHIVE_GAME_BIN32_PATH='Keep Talking and Nobody Explodes'
ARCHIVE_GAME_BIN32_FILES='ktane.x86 ktane_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH='Keep Talking and Nobody Explodes'
ARCHIVE_GAME_BIN64_FILES='ktane.x86_64 ktane_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='Keep Talking and Nobody Explodes'
ARCHIVE_GAME_DATA_FILES='ktane_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='ktane.x86'
APP_MAIN_EXE_BIN64='ktane.x86_64'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='ktane_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx gtk2"
PKG_BIN32_DEPS_ARCH='lib32-gdk-pixbuf2 lib32-glib2'
PKG_BIN32_DEPS_DEB='libgdk-pixbuf2.0-0, libglib2.0-0'
PKG_BIN32_DEPS_GENTOO='x11-libs/gdk-pixbuf[abi_x86_32] dev-libs/glib[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='gdk-pixbuf2 glib2'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/gdk-pixbuf dev-libs/glib'

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

# Check for optional archives

CURRENT_ARCHIVE="$ARCHIVE"
archive_set 'ARCHIVE_MANUAL' 'ARCHIVE_OPTIONAL_MANUAL'
ARCHIVE="$CURRENT_ARCHIVE"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include game manual

if [ "$ARCHIVE_MANUAL" ]; then
	path="${PKG_DATA_PATH}${PATH_DOC}"
	mkdir --parents "$path"
	cp "$ARCHIVE_MANUAL" "$path"
fi

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
