#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# Invisible Inc.
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180919.2

# Set game-specific variables

GAME_ID='invisible-inc'
GAME_NAME='Invisible Inc.'

ARCHIVE_GOG='invisible_inc_en_281021_22858.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/invisible_inc'
ARCHIVE_GOG_MD5='bfb1493931172a9f71c95a6861af97ee'
ARCHIVE_GOG_SIZE='1200000'
ARCHIVE_GOG_VERSION='281021-gog22858'
ARCHIVE_GOG_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD1='invisible_inc_en_8_07_2017_15873.sh'
ARCHIVE_GOG_OLD1_MD5='b3acb8f72cf01f71b0ddcb4355543a16'
ARCHIVE_GOG_OLD1_SIZE='1200000'
ARCHIVE_GOG_OLD1_VERSION='2017.07.08-gog15873'
ARCHIVE_GOG_OLD1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD0='gog_invisible_inc_2.6.0.11.sh'
ARCHIVE_GOG_OLD0_MD5='97e6efdc9237ec17deb02b5cf5185cf5'
ARCHIVE_GOG_OLD0_SIZE='1200000'
ARCHIVE_GOG_OLD0_VERSION='2016.04.13-gog2.6.0.11'

ARCHIVE_ICONS_PACK='invisible-inc_icons.tar.gz'
ARCHIVE_ICONS_PACK_MD5='37a62fed1dc4185e95db3e82e6695c1d'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game'
ARCHIVE_DOC1_DATA_FILES='LICENSE'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='InvisibleInc32 lib32'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='InvisibleInc64 lib64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='*.kwad *.lua hashes.dat scripts.zip'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 32x32 64x64 128x128 256x256'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS_BIN32='lib32'
APP_MAIN_LIBS_BIN64='lib64'
APP_MAIN_EXE_BIN32='InvisibleInc32'
APP_MAIN_EXE_BIN64='InvisibleInc64'
APP_MAIN_ICON_GOG='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ sdl2 glx"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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

# Try to load icons archive

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_ICONS' 'ARCHIVE_ICONS_PACK'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icons

PKG='PKG_DATA'
if [ "$ARCHIVE_ICONS" ]; then  
	(
		rm --recursive "$PLAYIT_WORKDIR/gamedata"
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
	organize_data 'ICONS' "$PATH_ICON_BASE"
else
	icons_get_from_workdir 'APP_MAIN'
fi
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
