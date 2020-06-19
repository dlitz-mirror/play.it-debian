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
# Reus
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200619.2

# Set game-specific variables

GAME_ID='reus'
GAME_NAME='Reus'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0
ARCHIVE_HUMBLE_1
ARCHIVE_HUMBLE_0
'

ARCHIVE_GOG_1='reus_en_1_6_5_20844.sh'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/reus'
ARCHIVE_GOG_1_MD5='a768dd2347ac7f6be16ffa9e3f0952c4'
ARCHIVE_GOG_1_SIZE='480000'
ARCHIVE_GOG_1_VERSION='1.6.5-gog20844'
ARCHIVE_GOG_1_TYPE='mojosetup'

ARCHIVE_GOG_0='gog_reus_2.0.0.2.sh'
ARCHIVE_GOG_0_MD5='25fe7ec93305e804558e4ef8a31fbbf8'
ARCHIVE_GOG_0_SIZE='480000'
ARCHIVE_GOG_0_VERSION='1.5.1-gog2.0.0.2'

ARCHIVE_HUMBLE_1='reus-linux-1.6.5.tar.gz'
ARCHIVE_HUMBLE_1_URL='https://www.humblebundle.com/store/reus'
ARCHIVE_HUMBLE_1_MD5='2b61251f7aa41542db03a1fe637b57dc'
ARCHIVE_HUMBLE_1_SIZE='480000'
ARCHIVE_HUMBLE_1_VERSION='1.6.5-humble180612'

ARCHIVE_HUMBLE_0='reus_linux_1389636757-bin'
ARCHIVE_HUMBLE_0_MD5='9914e7fcb5f3b761941169ae13ec205c'
ARCHIVE_HUMBLE_0_SIZE='380000'
ARCHIVE_HUMBLE_0_TYPE='mojosetup'
ARCHIVE_HUMBLE_0_VERSION='0.beta-humble140113'

ARCHIVE_DOC_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC_DATA_PATH_HUMBLE='data'
ARCHIVE_DOC_DATA_FILES='Linux.README'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='.'
ARCHIVE_GAME_BIN32_FILES='Reus.bin.x86 lib'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN32_PATH_HUMBLE_0='data'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='.'
ARCHIVE_GAME_BIN64_FILES='Reus.bin.x86_64 lib64'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN64_PATH_HUMBLE_0='data'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='.'
ARCHIVE_GAME_DATA_FILES='*.dll *.dll.config Audio Cursors Effects Fonts MainMenu mono monoconfig monomachineconfig Particles Reus.bmp Reus.exe Settings Skeletons Textures UI'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_HUMBLE_0='data'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# Work around terminfo Mono bug
# cf. https://github.com/mono/mono/issues/6752
export TERM="${TERM%-256color}"'
APP_MAIN_EXE_BIN32='Reus.bin.x86'
APP_MAIN_EXE_BIN64='Reus.bin.x86_64'
APP_MAIN_ICON='Reus.bmp'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ vorbis openal sdl2 freetype theora"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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
