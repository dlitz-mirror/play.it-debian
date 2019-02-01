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
# Momodora: Reverie Under the Moonlight
# build native Linux packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20181016.1

# Set game-specific variables

GAME_ID='momodora-reverie-under-the-moonlight'
GAME_NAME='Momodora: Reverie Under the Moonlight'

ARCHIVE_GOG='momodora_reverie_under_the_moonlight_en_20180418_20149.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/momodora_reverie_under_the_moonlight'
ARCHIVE_GOG_MD5='5ec0d0e8475ced69fbaf3881652d78c1'
ARCHIVE_GOG_SIZE='330000'
ARCHIVE_GOG_VERSION='1.02a-gog20149'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_OPTIONAL_LIBCURL='libcurl3_7.60.0_32-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBCURL_URL='https://www.dotslashplay.it/ressources/libcurl/'
ARCHIVE_OPTIONAL_LIBCURL_MD5='7206100f065d52de5a4c0b49644aa052'

ARCHIVE_DOC_PATH='data/noarch/docs'
ARCHIVE_DOC_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game/GameFiles'
ARCHIVE_GAME_BIN_FILES='MomodoraRUtM runtime/i386/lib/i386-linux-gnu/libssl.so.1.0.0 runtime/i386/lib/i386-linux-gnu/libcrypto.so.1.0.0'

ARCHIVE_GAME_DATA_PATH='data/noarch/game/GameFiles'
ARCHIVE_GAME_DATA_FILES='assets'

CONFIG_FILES='assets/*.ini'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='runtime/i386/lib/i386-linux-gnu'
APP_MAIN_PRERUN='export LANG=C'
APP_MAIN_EXE='MomodoraRUtM'
APP_MAIN_ICON='assets/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glu openal libxrandr libcurl"

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

# Use libcurl 3 32-bit archive

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_LIBCURL' 'ARCHIVE_OPTIONAL_LIBCURL'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include libcurl 3 32-bit

if [ "$ARCHIVE_LIBCURL" ]; then
	(
		ARCHIVE='ARCHIVE_LIBCURL'
		extract_data_from "$ARCHIVE_LIBCURL"
	)
	mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
	ln --symbolic 'libcurl.so.4.5.0' "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS/libcurl.so.4"
fi

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'
chmod +x "${PKG_BIN_PATH}${PATH_GAME}/MomodoraRUtM"

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
