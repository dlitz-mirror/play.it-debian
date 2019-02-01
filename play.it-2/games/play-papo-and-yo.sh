#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, Solène Huault
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
# Papo and Yo
# build native Linux packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20181024.1

# Set game-specific variables

GAME_ID='papo-and-yo'
GAME_NAME='Papo and Yo'

ARCHIVE_HUMBLE='PapoYo_linux_1389070953.sh'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/papo-yo'
ARCHIVE_HUMBLE_MD5='d8222b87222f4eb05025584bf923da41'
ARCHIVE_HUMBLE_SIZE='2000000'
ARCHIVE_HUMBLE_VERSION='2014010601-humble1'
ARCHIVE_HUMBLE_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data/noarch'
ARCHIVE_DOC_DATA_FILES='about.html BuildVersion.txt README.linux UpdateLog.txt'

ARCHIVE_GAME_BIN_PATH='data/x86'
ARCHIVE_GAME_BIN_FILES='Binaries/Linux/steam_appid.txt Binaries/Linux/PYGame-Linux Binaries/Linux/lib/libsteam_api.so Binaries/Linux/lib/libPhysXCooking.so Binaries/Linux/lib/libPhysXCore.so Binaries/Linux/lib/libtcmalloc.so.0'

ARCHIVE_GAME_DATA_PATH='data/noarch'
ARCHIVE_GAME_DATA_FILES='Engine PapoYoIcon.bmp PapoYoIcon.png PYGame'

APP_MAIN_LIBS='lib'
APP_MAIN_TYPE='native'
APP_MAIN_EXE='Binaries/Linux/PYGame-Linux'
APP_MAIN_ICON='PapoYoIcon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ sdl2 glx alsa libudev1"
PKG_BIN_DEPS_ARCH='lib32-libpulse'

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	: ${XDG_DATA_HOME:="$HOME/.local/share"}
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
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Set working directory to the directory containing the game binary before running it

pattern='s|^cd "$PATH_PREFIX"$|cd "$PATH_PREFIX/${APP_EXE%/*}"|'
pattern="$pattern"';s|^"\./$APP_EXE"|"./${APP_EXE##*/}"|'
file="${PKG_BIN_PATH}${PATH_BIN}/$GAME_ID"
sed --in-place "$pattern" "$file"

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
