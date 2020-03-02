#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
# Copyright (c) 2020 Hoël Bézier
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
# Bastion
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200920.1

# Set game-specific variables

GAME_ID='bastion'
GAME_NAME='Bastion'

ARCHIVE_GOG='bastion_1_0_1747_initial_test_33876.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/bastion'
ARCHIVE_GOG_TYPE='mojosetup'
ARCHIVE_GOG_MD5='b4edf5e95e952a35bfde0c12959134ab'
ARCHIVE_GOG_SIZE='1300000'
ARCHIVE_GOG_VERSION='1.50436-gog33876'

ARCHIVE_GOG_OLD2='bastion_1_50436_29_08_2018_23317.sh'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'
ARCHIVE_GOG_OLD2_MD5='73c6b33c23232597bec30f211a46f73d'
ARCHIVE_GOG_OLD2_SIZE='1400000'
ARCHIVE_GOG_OLD2_VERSION='1.50436.20180829-gog23317'

ARCHIVE_GOG_OLD1='bastion_en_1_50436_23291.sh'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'
ARCHIVE_GOG_OLD1_MD5='59c2bbcf43cd9ba243d5fa1baa4a4b48'
ARCHIVE_GOG_OLD1_SIZE='1400000'
ARCHIVE_GOG_OLD1_VERSION='1.50436-gog23291'

ARCHIVE_GOG_OLD0='gog_bastion_2.0.0.1.sh'
ARCHIVE_GOG_OLD0_MD5='e5e6eefb4885b67abcfa201b1b3a9c48'
ARCHIVE_GOG_OLD0_SIZE='1300000'
ARCHIVE_GOG_OLD0_VERSION='1.2.20161020-gog2.0.0.1'

ARCHIVE_HUMBLE='bastion-10162016-bin'
ARCHIVE_HUMBLE_MD5='19fea173ff2da0f990f60bd5e7c3b237'
ARCHIVE_HUMBLE_SIZE='1300000'
ARCHIVE_HUMBLE_VERSION='1.2.20161020-humble161019'
ARCHIVE_HUMBLE_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC_DATA_PATH_HUMBLE='data'
ARCHIVE_DOC_DATA_FILES='Linux.README'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='data'
ARCHIVE_GAME_BIN32_FILES='lib/libfmodex.so lib/libmojoshader.so lib/libsteam_api.so lib/libSteamWrapper.so'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='data'
ARCHIVE_GAME_BIN64_FILES='lib64/libfmodex.so lib64/libmojoshader.so lib64/libsteam_api.so lib64/libSteamWrapper.so'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='data'
ARCHIVE_GAME_DATA_FILES='*.config *.txt Bastion.exe Bastion.bmp Content mono* FMOD.dll FNA.dll Lidgren.Network.dll MojoShader.dll MonoGame.Framework.Net.dll'

APP_MAIN_TYPE='mono'
APP_MAIN_LIBS_BIN32='lib'
APP_MAIN_LIBS_BIN64='lib64'
APP_MAIN_EXE='Bastion.exe'
APP_MAIN_ICON='Bastion.bmp'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID mono sdl2 glx libudev1"
PKG_BIN32_DEPS_DEB='libmono-posix4.0-cil'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"

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

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

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
