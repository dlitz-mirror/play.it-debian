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
# The Pillars of the Earth
# build native packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20190522.3

# Set game-specific variables

GAME_ID='the-pillars-of-the-earth'
GAME_NAME='The Pillars of the Earth'

ARCHIVE_GOG='the_pillars_of_the_earth_en_1_1_703_19574.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/ken_folletts_the_pillars_of_the_earth_season_pass'
ARCHIVE_GOG_MD5='1976e6d4476e3d9867aef13176581f58'
ARCHIVE_GOG_SIZE='12000000'
ARCHIVE_GOG_VERSION='1.1.703-gog19574'
ARCHIVE_GOG_TYPE='mojosetup_unzip'

ARCHIVE_OPTIONAL_LIBPNG64='libpng_1.2_64-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBPNG64_URL='https://www.dotslashplay.it/ressources/libpng/'
ARCHIVE_OPTIONAL_LIBPNG64_MD5='c7d675c8df2aac9bcb8132b501a10439'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game/documents/licenses'
ARCHIVE_DOC1_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='pillars config.ini libs64 configtool'

ARCHIVE_GAME_SCENES_PATH='data/noarch/game'
ARCHIVE_GAME_SCENES_FILES='scenes'

ARCHIVE_GAME_VIDEO_PATH='data/noarch/game'
ARCHIVE_GAME_VIDEO_FILES='videos'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='characters data.vis lua'

CONFIG_FILES='./config.ini'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='pillars'
APP_MAIN_LIBS='libs64'
APP_MAIN_ICON='data/noarch/support/icon.png'

APP_CONFIG_TYPE='native'
APP_CONFIG_EXE='configtool/visconfig'
APP_CONFIG_LIBS='configtool/lib'
APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_CAT='Settings'
APP_CONFIG_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_SCENES PKG_VIDEO PKG_DATA PKG_BIN'

PKG_SCENES_ID="${GAME_ID}-scenes"
PKG_SCENES_DESCRIPTION='scenes'

PKG_VIDEO_ID="${GAME_ID}-videos"
PKG_VIDEO_DESCRIPTION='videos'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID $PKG_SCENES_ID $PKG_VIDEO_ID glibc libstdc++ glx xcursor libxrandr libudev1 openal"
PKG_BIN_DEPS_ARCH='libpng12'
PKG_BIN_DEPS_GENTOO='media-libs/libpng:1.2'

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

# Use libpng 1.2 archive for systems no longer providing it

case "$OPTION_PACKAGE" in
	('deb')
		ARCHIVE_MAIN="$ARCHIVE"
		set_archive 'ARCHIVE_LIBPNG64' 'ARCHIVE_OPTIONAL_LIBPNG64'
		ARCHIVE="$ARCHIVE_MAIN"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icons

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN' 'APP_CONFIG'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include libpng 1.2

if [ "$ARCHIVE_LIBPNG64" ]; then
	(
		ARCHIVE='ARCHIVE_LIBPNG64'
		extract_data_from "$ARCHIVE_LIBPNG64"
	)
	mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
	mv "$PLAYIT_WORKDIR/gamedata/libpng12.so.0.50.0" "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	ln --symbolic './libpng12.so.0.50.0' "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS/libpng12.so.0"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_CONFIG'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
