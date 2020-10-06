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
# Untitled Cat Unboxing
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201006.1

# Set game-specific variables

GAME_ID='untitled-cat-unboxing'
GAME_NAME='Untitled Cat Unboxing'

ARCHIVES_LIST='
ARCHIVE_ITCH_0
'

ARCHIVE_ITCH_0='Untitled cat unboxing.x86_64'
ARCHIVE_ITCH_0_URL='https://reispfannenfresser.itch.io/untitled-cat-unboxing'
ARCHIVE_ITCH_0_MD5='96366d6a04c6f3081aee60ba9a167b65'
ARCHIVE_ITCH_0_SIZE='42000'
ARCHIVE_ITCH_0_VERSION='1.0-itch'
ARCHIVE_ITCH_0_TYPE='file'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Untitled cat unboxing.x86_64'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ARCH='64'
PKG_MAIN_DEPS="glibc glx xcursor libxrandr alsa"
PKG_MAIN_DEPS_ARCH='lib32-libx11 lib32-libxinerama lib32-libpulse'
PKG_MAIN_DEPS_DEB='libx11-6, libxinerama1, libpulse0, libxi6'
PKG_MAIN_DEPS_GENTOO='x11-libs/libX11[abi_x86_32] x11-libs/libXinerama[abi_x86_32] media-sound/pulseaudio[abi_x86_32]'

# Load common functions

target_version='2.12'

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

mkdir --parents "${PKG_MAIN_PATH}${PATH_GAME}"
cp "$SOURCE_ARCHIVE" "${PKG_MAIN_PATH}${PATH_GAME}/Untitled cat unboxing.x86_64"

# Write launchers

launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
