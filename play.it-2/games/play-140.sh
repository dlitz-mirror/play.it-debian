#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
# Copyright (c) 2020-2021, Hoël Bézier
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
# 140
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210513.10

# Set game-specific variables

GAME_ID='140-game'
GAME_NAME='140'

ARCHIVE_BASE_GOG_3='140_1010_2019_33250.sh'
ARCHIVE_BASE_GOG_3_MD5='cbfdc455cf49c88aea3cb62d23fccb55'
ARCHIVE_BASE_GOG_3_TYPE='mojosetup'
ARCHIVE_BASE_GOG_3_SIZE='130000'
ARCHIVE_BASE_GOG_3_VERSION='2019.10.10.r473-gog33250'
ARCHIVE_BASE_GOG_3_URL='https://www.gog.com/game/140_game'

ARCHIVE_BASE_GOG_2='140_en_171409_r400_22641.sh'
ARCHIVE_BASE_GOG_2_MD5='69a67be9632ad2b7db02b3d11486d81b'
ARCHIVE_BASE_GOG_2_TYPE='mojosetup'
ARCHIVE_BASE_GOG_2_SIZE='130000'
ARCHIVE_BASE_GOG_2_VERSION='2017.09.14.r400-gog22641'

ARCHIVE_BASE_GOG_1='gog_140_2.2.0.3.sh'
ARCHIVE_BASE_GOG_1_MD5='03e760fa1b667059db7713a9e6c06b6d'
ARCHIVE_BASE_GOG_1_TYPE='mojosetup'
ARCHIVE_BASE_GOG_1_SIZE='130000'
ARCHIVE_BASE_GOG_1_VERSION='2017.07.19.r370-gog2.2.0.3'

ARCHIVE_BASE_GOG_0='gog_140_2.1.0.2.sh'
ARCHIVE_BASE_GOG_0_MD5='6139b77721657a919085aea9f13cf42b'
ARCHIVE_BASE_GOG_0_TYPE='mojosetup'
ARCHIVE_BASE_GOG_0_SIZE='130000'
ARCHIVE_BASE_GOG_0_VERSION='2017.06.19-gog2.1.0.2'

ARCHIVE_BASE_GOG_OLDNAME_0='gog_140_2.0.0.1.sh'
ARCHIVE_BASE_GOG_OLDNAME_0_MD5='49ec4cff5fa682517e640a2d0eb282c8'
ARCHIVE_BASE_GOG_OLDNAME_0_TYPE='mojosetup'
ARCHIVE_BASE_GOG_OLDNAME_0_SIZE='110000'
ARCHIVE_BASE_GOG_OLDNAME_0_VERSION='2.0-gog2.0.0.1'

ARCHIVE_BASE_HUMBLE_1='140-2019-09-10-145438-r473-linux-nodrm.zip'
ARCHIVE_BASE_HUMBLE_1_MD5='5b5e46c1c4c4dd31f8f29d8fa1207562'
ARCHIVE_BASE_HUMBLE_1_SIZE='130000'
ARCHIVE_BASE_HUMBLE_1_VERSION='2019.10.10.r473-humble.2019.10.11'
ARCHIVE_BASE_HUMBLE_1_URL='https://www.humblebundle.com/store/140'

ARCHIVE_BASE_HUMBLE_ALTPATH_0='140-nodrm-linux-2017-07-19-r370.zip'
ARCHIVE_BASE_HUMBLE_ALTPATH_0_MD5='2444ec7803c5d6dcf161b722705f0402'
ARCHIVE_BASE_HUMBLE_ALTPATH_0_SIZE='130000'
ARCHIVE_BASE_HUMBLE_ALTPATH_0_VERSION='2017.07.19.r370-humble.2017.08.04'

ARCHIVE_BASE_HUMBLE_0='140-nodrm-linux-2017-06-20.zip'
ARCHIVE_BASE_HUMBLE_0_MD5='5bbc48b203291ca9a0b141e3d07dacbe'
ARCHIVE_BASE_HUMBLE_0_SIZE='130000'
ARCHIVE_BASE_HUMBLE_0_VERSION='2017.06.19-humble.2017.06.20'

ARCHIVE_BASE_HUMBLE_OLDNAME_0='140_Linux.zip'
ARCHIVE_BASE_HUMBLE_OLDNAME_0_MD5='0829eb743010653633571b3da20502a8'
ARCHIVE_BASE_HUMBLE_OLDNAME_0_SIZE='110000'
ARCHIVE_BASE_HUMBLE_OLDNAME_0_VERSION='2.0-humble.2016.09.14'

ARCHIVE_DOC0_PATH='data/noarch/support'
ARCHIVE_DOC0_FILES='*.txt'

ARCHIVE_DOC1_PATH='data/noarch/doc'
ARCHIVE_DOC1_FILES='*'

ARCHIVE_GAME_BIN32_PATH_BASE_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_BASE_HUMBLE='linux'
ARCHIVE_GAME_BIN32_PATH_BASE_HUMBLE_ALTPATH='.'
ARCHIVE_GAME_BIN32_FILES='*.x86 *_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH_BASE_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_BASE_HUMBLE='linux'
ARCHIVE_GAME_BIN64_PATH_BASE_HUMBLE_ALTPATH='.'
ARCHIVE_GAME_BIN64_FILES='*.x86_64 *_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH_BASE_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_BASE_HUMBLE='linux'
ARCHIVE_GAME_DATA_PATH_BASE_HUMBLE_ALTPATH='.'
ARCHIVE_GAME_DATA_FILES='*_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='140Linux.x86'
APP_MAIN_EXE_BIN64='140Linux.x86_64'
APP_MAIN_ICON='140Linux_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc libstdc++ glx xcursor libxrandr gtk2 libgdk_pixbuf-2.0.so.0 libgobject-2.0.so.0 libglib-2.0.so.0"
PKG_BIN32_DEPS_ARCH='lib32-libx11'
PKG_BIN32_DEPS_DEB='libx11-6'
PKG_BIN32_DEPS_GENTOO='x11-libs/libX11[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libx11'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/libX11'

# Use persistent storage for game progress

DATA_FILES="${DATA_FILES} ./140.sav"

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

# Keep compatibility with old versions

APP_MAIN_EXE_BIN32_BASE_GOG_OLDNAME='140.x86'
APP_MAIN_EXE_BIN64_BASE_GOG_OLDNAME='140.x86_64'
APP_MAIN_ICON_BASE_GOG_OLDNAME='140_Data/Resources/UnityPlayer.png'

APP_MAIN_EXE_BIN32_BASE_HUMBLE_OLDNAME='140.x86'
APP_MAIN_EXE_BIN64_BASE_HUMBLE_OLDNAME='140.x86_64'
APP_MAIN_ICON_BASE_HUMBLE_OLDNAME='140_Data/Resources/UnityPlayer.png'
ARCHIVE_GAME_BIN32_PATH_BASE_HUMBLE_OLDNAME="$ARCHIVE_GAME_BIN32_PATH_BASE_HUMBLE_ALTPATH"
ARCHIVE_GAME_BIN64_PATH_BASE_HUMBLE_OLDNAME="$ARCHIVE_GAME_BIN64_PATH_BASE_HUMBLE_ALTPATH"
ARCHIVE_GAME_DATA_PATH_BASE_HUMBLE_OLDNAME="$ARCHIVE_GAME_DATA_PATH_BASE_HUMBLE_ALTPATH"

# Load common functions

target_version='2.13'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
		'/usr/share/play.it'
	do
		if [ -e "${path}/libplayit2.sh" ]; then
			PLAYIT_LIB2="${path}/libplayit2.sh"
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

# Extract icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

use_archive_specific_value 'APP_MAIN_EXE_BIN32'
use_archive_specific_value 'APP_MAIN_EXE_BIN64'
use_archive_specific_value 'APP_MAIN_ICON'

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
