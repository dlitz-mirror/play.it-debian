#!/bin/sh -e
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
# Duet
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190209.4

# Set game-specific variables

GAME_ID='duet'
GAME_NAME='Duet'

ARCHIVE_HUMBLE='Duet-Build1006023-Linux64.zip'
ARCHIVE_HUMBLE_MD5='b9c34c29da94c199ee75a5e71272a1eb'
ARCHIVE_HUMBLE_VERSION='1.0-humble1006023'
ARCHIVE_HUMBLE_SIZE='210000'
ARCHIVE_HUMBLE_TYPE='zip'

ARCHIVE_OPTIONAL_ICON='logo.png'
ARCHIVE_OPTIONAL_ICON_URL='http://www.kumobius.com/presskits/duet/images/logo.png'
ARCHIVE_OPTIONAL_ICON_MD5='e726e1be1b2be27394cafab9381ea82b'
ARCHIVE_OPTIONAL_ICON_TYPE='file'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='Duet *.so*'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='Media'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Duet'
APP_MAIN_LIBS='.'
APP_MAIN_ICON='logo.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS='glibc libstdc++ glx openal freetype vorbis alsa'
PKG_BIN_DEPS_ARCH='libogg flac libjpeg-turbo libudev0-shim libx11 libxcb'
PKG_BIN_DEPS_DEB='libxcb-randr0'
PKG_BIN_DEPS_GENTOO='media-libs/flac media-libs/libogg media-libs/jpeg:8 sys-libs/libudev-compat x11-libs/libX11 x11-libs/libxcb'

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

# Include shipped obsolete libraries for systems not providing them

case "$OPTION_PACKAGE" in
	('deb')
		ARCHIVE_GAME0_BIN_PATH='steam-runtime/amd64/lib/x86_64-linux-gnu'
		ARCHIVE_GAME0_BIN_FILES='libudev.so.0*'

		ARCHIVE_GAME1_BIN_PATH='steam-runtime/amd64/usr/lib/x86_64-linux-gnu'
		ARCHIVE_GAME1_BIN_FILES='libjpeg.so.8*'
	;;
esac

# Check for optional icon presence

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_ICON' 'ARCHIVE_OPTIONAL_ICON'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Include icon if provided

if [ "$ARCHIVE_ICON" ]; then
	cp "$ARCHIVE_ICON" "$PLAYIT_WORKDIR/gamedata"
	PKG='PKG_DATA'
	icons_get_from_workdir 'APP_MAIN'
fi
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launcher_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
