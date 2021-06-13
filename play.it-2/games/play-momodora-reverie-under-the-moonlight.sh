#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
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
# Momodora: Reverie Under the Moonlight
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210613.2

# Set game-specific variables

GAME_ID='momodora-reverie-under-the-moonlight'
GAME_NAME='Momodora: Reverie Under the Moonlight'

ARCHIVE_BASE_1='momodora_reverie_under_the_moonlight_1_062_24682.sh'
ARCHIVE_BASE_1_MD5='9da233f084d0a86e4068ca90c89e4f05'
ARCHIVE_BASE_1_TYPE='mojosetup'
ARCHIVE_BASE_1_SIZE='330000'
ARCHIVE_BASE_1_VERSION='1.062-gog24682'
ARCHIVE_BASE_1_URL='https://www.gog.com/game/momodora_reverie_under_the_moonlight'

ARCHIVE_BASE_0='momodora_reverie_under_the_moonlight_en_20180418_20149.sh'
ARCHIVE_BASE_0_MD5='5ec0d0e8475ced69fbaf3881652d78c1'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='330000'
ARCHIVE_BASE_0_VERSION='1.02a-gog20149'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game'
ARCHIVE_DOC1_DATA_FILES='Installation?Notes.pdf Update.txt'

ARCHIVE_GAME_BIN_PATH='data/noarch/game/GameFiles'
ARCHIVE_GAME_BIN_FILES='MomodoraRUtM'

ARCHIVE_GAME_DATA_PATH='data/noarch/game/GameFiles'
ARCHIVE_GAME_DATA_FILES='assets'

CONFIG_FILES='assets/*.ini'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='export LANG=C'
APP_MAIN_EXE='MomodoraRUtM'
APP_MAIN_ICON='assets/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc libstdc++ glu openal libxrandr libcurl"

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

# Ensure availability of CURL_OPENSSL_3 symbol

PKG='PKG_BIN'
ARCHIVE_REQUIRED_LIBCURL3='libcurl3_7.60.0_32-bit.tar.gz'
ARCHIVE_REQUIRED_LIBCURL3_URL='https://downloads.dotslashplay.it/resources/libcurl/'
ARCHIVE_REQUIRED_LIBCURL3_MD5='7206100f065d52de5a4c0b49644aa052'
ARCHIVE_LIBCURL3_PATH='.'
ARCHIVE_LIBCURL3_FILES='libcrypto.so.1.0.2 libssl.so.1.0.2 libcurl.so.4.5.0'
archive_initialize_required \
	'ARCHIVE_LIBCURL3' \
	'ARCHIVE_REQUIRED_LIBCURL3'
(
	ARCHIVE='ARCHIVE_LIBCURL3'
	extract_data_from "${ARCHIVE_LIBCURL3}"
)
organize_data 'LIBCURL3' "${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
rm --recursive "$PLAYIT_WORKDIR/gamedata"
ln --symbolic \
	'libcurl.so.4.5.0' \
	"$(package_get_path "$PKG")${PATH_GAME}/${APP_MAIN_LIBS}/libcurl.so.4"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Include shipped SSL 1.0.0 libraries

PKG='PKG_BIN'
ARCHIVE_LIBSSL_PATH='data/noarch/game/GameFiles/runtime/i386/lib/i386-linux-gnu'
ARCHIVE_LIBSSL_FILES='libssl.so.1.0.0 libcrypto.so.1.0.0'
organize_data 'LIBSSL' "${PATH_GAME}/${APP_MAIN_LIBS:=libs}"

# Include game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
