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
# World of Goo
# build native Linux packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200413.17

# Set game-specific variables

GAME_ID='world-of-goo'
GAME_NAME='World of Goo'

ARCHIVES_LIST='ARCHIVE_GOG ARCHIVE_HUMBLE ARCHIVE_SDL1_GOG_OLD0 ARCHIVE_SDL1_HUMBLE_OLD0'

ARCHIVE_GOG='world_of_goo_1_51_29337.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/world_of_goo'
ARCHIVE_GOG_MD5='f3566d859e824862b4dc14f94b15cafa'
ARCHIVE_GOG_SIZE='200000'
ARCHIVE_GOG_VERSION='1.51-gog29337'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_HUMBLE='WorldOfGoo.Linux.1.53.sh'
ARCHIVE_HUMBLE_MD5='9049f4fccf98ba79ac238a8b414e053a'
ARCHIVE_HUMBLE_SIZE='210000'
ARCHIVE_HUMBLE_VERSION='1.53-humble'
ARCHIVE_HUMBLE_TYPE='mojosetup'

ARCHIVE_SDL1_GOG_OLD0='gog_world_of_goo_2.0.0.3.sh'
ARCHIVE_SDL1_GOG_OLD0_MD5='5359b8e7e9289fba4bcf74cf22856655'
ARCHIVE_SDL1_GOG_OLD0_SIZE='82000'
ARCHIVE_SDL1_GOG_OLD0_VERSION='1.41-gog2.0.0.3'

ARCHIVE_SDL1_HUMBLE_OLD0='WorldOfGooSetup.1.41.tar.gz'
ARCHIVE_SDL1_HUMBLE_OLD0_MD5='f5afa40893d0fbcc37885191404f6d8c'
ARCHIVE_SDL1_HUMBLE_OLD0_SIZE='81000'
ARCHIVE_SDL1_HUMBLE_OLD0_VERSION='1.41-humble'

# Only for GOG archives
ARCHIVE_DOC0_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES_GOG='*.html *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC0_DATA_PATH_SDL1_GOG='data/noarch/docs'

# Only for Humble archives
ARCHIVE_DOC0_DATA_PATH_HUMBLE='data'
ARCHIVE_DOC0_DATA_FILES_HUMBLE='*.txt'

ARCHIVE_DOC1_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC1_DATA_PATH_HUMBLE='data/noarch'
ARCHIVE_DOC1_DATA_FILES='*.html *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC1_DATA_PATH_SDL1_GOG='data/noarch/game'
ARCHIVE_DOC1_DATA_PATH_SDL1_HUMBLE='WorldOfGoo'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='data/x86'
ARCHIVE_GAME_BIN32_FILES='WorldOfGoo.bin.x86'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN32_PATH_SDL1_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_SDL1_HUMBLE='WorldOfGoo'
ARCHIVE_GAME_BIN32_FILES_SDL1='WorldOfGoo.bin32 res/*/*.binltl res/*/*/*.binltl'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='data/x86_64'
ARCHIVE_GAME_BIN64_FILES='WorldOfGoo.bin.x86_64'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN64_PATH_SDL1_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_SDL1_HUMBLE='WorldOfGoo'
ARCHIVE_GAME_BIN64_FILES_SDL1='WorldOfGoo.bin64 res/*/*.binltl64 res/*/*/*.binltl64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='data/noarch'
ARCHIVE_GAME_DATA_FILES='game'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_SDL1_GOG="$ARCHIVE_GAME_DATA_PATH_GOG"
ARCHIVE_GAME_DATA_PATH_SDL1_HUMBLE='WorldOfGoo'
ARCHIVE_GAME_DATA_FILES_SDL1='icons properties res'

# ./properties/config.txt seems to only be present in the “SDL1” version
CONFIG_FILES='./properties/config.txt'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='WorldOfGoo.bin.x86'
APP_MAIN_EXE_BIN64='WorldOfGoo.bin.x86_64'
APP_MAIN_ICON='game/gooicon.png'
# Keep compatibility with old archives
APP_MAIN_EXE_BIN32_SDL1='WorldOfGoo.bin32'
APP_MAIN_EXE_BIN64_SDL1='WorldOfGoo.bin64'
APP_MAIN_ICONS_LIST_SDL1='
APP_MAIN_SDL1_ICON16
APP_MAIN_SDL1_ICON22
APP_MAIN_SDL1_ICON32
APP_MAIN_SDL1_ICON48
APP_MAIN_SDL1_ICON64
APP_MAIN_SDL1_ICON128'
APP_MAIN_SDL1_ICON16='icons/16x16.png'
APP_MAIN_SDL1_ICON22='icons/22x22.png'
APP_MAIN_SDL1_ICON32='icons/32x32.png'
APP_MAIN_SDL1_ICON48='icons/48x48.png'
APP_MAIN_SDL1_ICON64='icons/64x64.png'
APP_MAIN_SDL1_ICON128='icons/128x128.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx sdl2 sdl2_mixer"
# Keep compatibility with old archives
PKG_BIN32_DEPS_SDL1="$PKG_DATA_ID glibc libstdc++ glx glu sdl1.2"
PKG_BIN32_DEPS_ARCH_SDL1='lib32-sdl_mixer'
PKG_BIN32_DEPS_DEB_SDL1='libsdl-mixer1.2'
PKG_BIN32_DEPS_GENTOO_SDL1='media-libs/sdl-mixer[vorbis,abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
# Keep compatibility with old archives
PKG_BIN64_DEPS_SDL1="$PKG_BIN32_DEPS_SDL1"
PKG_BIN64_DEPS_ARCH_SDL1='sdl_mixer'
PKG_BIN64_DEPS_DEB_SDL1="$PKG_BIN32_DEPS_DEB_SDL1"
PKG_BIN64_DEPS_GENTOO_SDL1='media-libs/sdl-mixer[vorbis]'

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

# Get game icons

PKG='PKG_DATA'
use_archive_specific_value 'APP_MAIN_ICONS_LIST'
icons_get_from_package 'APP_MAIN'
case "$ARCHIVE" in
	('ARCHIVE_SDL1'*)
		# SVG icon is only provided for archives coming with the SDL1.2 engine
		PATH_ICON="$PATH_ICON_BASE/scalable/apps"
		mkdir --parents "${PKG_DATA_PATH}/${PATH_ICON}"
		cp "${PKG_DATA_PATH}/${PATH_GAME}/icons/scalable.svg" "${PKG_DATA_PATH}/${PATH_ICON}/${GAME_ID}.svg"
	;;
esac

# Write launchers

use_archive_specific_value 'APP_MAIN_EXE_BIN32'
use_archive_specific_value 'APP_MAIN_EXE_BIN64'
for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
