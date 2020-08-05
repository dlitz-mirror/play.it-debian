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
# Strike Suit Zero
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200709.4

# Set game-specific variables

GAME_ID='strike-suit-zero'
GAME_NAME='Strike Suit Zero'

ARCHIVES_LIST='
ARCHIVE_HUMBLE_0'

ARCHIVE_HUMBLE_0='StrikeSuitZero_linux_1389211698.zip'
ARCHIVE_HUMBLE_0_MD5='94b1c2907ae61deb27eb77fee3fb9c19'
ARCHIVE_HUMBLE_0_URL='https://www.humblebundle.com/store/strike-suit-zero'
ARCHIVE_HUMBLE_0_SIZE='2400000'
ARCHIVE_HUMBLE_0_VERSION='1.0-humble1'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='linux/main/binary/StrikeSuitZero linux/main/binary/libfmodevent.so linux/main/binary/libfmodeventnet.so linux/main/binary/libfmodex-4.44.12.so linux/main/binary/libfmodex.so linux/main/binary/libsteam_api.so'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='linux/main/art linux/main/audio linux/main/fonts linux/main/gui linux/main/level linux/main/levels linux/main/localisation linux/main/particles linux/main/scripts linux/main/shaders linux/main/system linux/main/textures linux/main/video linux/main/index.toc linux/main/index.toc.txt'

# Optional icons pack
ARCHIVE_OPTIONAL_ICONS='strike-suit-zero_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_MD5='3fe8bbad7ecca5c0e3afdbbfedb8945d'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/resources/strike-suit-zero/'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 32x32 48x48'

CONFIG_FILES='linux/main/binary/settings.sav'
DATA_FILES='linux/main/binary/Main.sav linux/main/binary/background.sav'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Run the game binary from its parent directory
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'
APP_MAIN_EXE='linux/main/binary/StrikeSuitZero'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx sdl2"

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

# Include optional icons pack

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
if [ -n "$ARCHIVE_ICONS" ]; then
	PKG='PKG_DATA'
	(
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
	organize_data 'ICONS' "$PATH_ICON_BASE"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Clean up temporary files

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
