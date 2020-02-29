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
# Retro City Rampage
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190220.2

# Set game-specific variables

GAME_ID='retro-city-rampage'
GAME_NAME='Retro City Rampage'

ARCHIVES_LIST='ARCHIVE_HUMBLE_64 ARCHIVE_HUMBLE_32'

ARCHIVE_HUMBLE_32='retrocityrampage-1.0-linux.i386.bin'
ARCHIVE_HUMBLE_32_URL='https://www.humblebundle.com/store/retro-city-rampage-dx'
ARCHIVE_HUMBLE_32_MD5='35c776fa33af850158b0d6a886dfe2a0'
ARCHIVE_HUMBLE_32_VERSION='1.53-humble1'
ARCHIVE_HUMBLE_32_SIZE='17000'
ARCHIVE_HUMBLE_32_TYPE='mojosetup'

ARCHIVE_HUMBLE_64='retrocityrampage-1.0-linux.x86_64.bin'
ARCHIVE_HUMBLE_64_URL='https://www.humblebundle.com/store/retro-city-rampage-dx'
ARCHIVE_HUMBLE_64_MD5='4fc25ab742d5bd389bd4a76eb6ec987f'
ARCHIVE_HUMBLE_64_VERSION='1.53-humble1'
ARCHIVE_HUMBLE_64_SIZE='17000'
ARCHIVE_HUMBLE_64_TYPE='mojosetup'

ARCHIVE_GAME_BIN_PATH='data'
ARCHIVE_GAME_BIN_FILES='retrocityrampage'

ARCHIVE_GAME_DATA_PATH='data'
ARCHIVE_GAME_DATA_FILES='audio_music_Linux.bap audio_sfx_Linux.bap gamedata_sdl.bfp icon.png'

CONFIG_FILES='./rcr_sdl.cfg'
DATA_FILES='./*.rsv'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='retrocityrampage'
APP_MAIN_ICON='icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH_HUMBLE_32='32'
PKG_BIN_ARCH_HUMBLE_64='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx alsa xcursor libxrandr"

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

PKG='PKG_BIN'
launcher_write 'APP_MAIN'

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
