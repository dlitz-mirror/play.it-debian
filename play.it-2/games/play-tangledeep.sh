#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, BetaRays
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
# Tangledeep
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190521.4

# Set game-specific variables

GAME_ID='tangledeep'
GAME_NAME='Tangledeep'

ARCHIVE_HUMBLE='Tangledeep_124k_LinuxUniversal.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/tangledeep'
ARCHIVE_HUMBLE_MD5='b708a12e20816dba8e863290dc5580d0'
ARCHIVE_HUMBLE_VERSION='1.24k-humble190410'
ARCHIVE_HUMBLE_SIZE='730000'

ARCHIVE_HUMBLE_OLD0='tangledeep_linux.zip'
ARCHIVE_HUMBLE_OLD0_MD5='ce38aaab0bf4838697fd1f76e30722f1'
ARCHIVE_HUMBLE_OLD0_VERSION='1.23e-humble'
ARCHIVE_HUMBLE_OLD0_SIZE='690000'

ARCHIVE_GAME_BIN32_PATH_HUMBLE='linuxuniversal'
ARCHIVE_GAME_BIN32_FILES='Tangledeep.x86 Tangledeep_Data/*/x86'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN32_PATH_HUMBLE_OLD0='tangledeep_123e_linux'

ARCHIVE_GAME_BIN64_PATH_HUMBLE='linuxuniversal'
ARCHIVE_GAME_BIN64_FILES='Tangledeep.x86_64 Tangledeep_Data/*/x86_64'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN64_PATH_HUMBLE_OLD0='tangledeep_123e_linux'

ARCHIVE_GAME_DATA_PATH_HUMBLE='linuxuniversal'
ARCHIVE_GAME_DATA_FILES='Tangledeep_Data'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_HUMBLE_OLD0='tangledeep_123e_linux'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Tangledeep.x86'
APP_MAIN_EXE_BIN64='Tangledeep.x86_64'
APP_MAIN_ICON='Tangledeep_Data/Resources/UnityPlayer.png'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
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
