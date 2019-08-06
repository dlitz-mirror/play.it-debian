#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Graveyard Keeper
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210513.5

# Set game-specific variables

GAME_ID='graveyard-keeper'
GAME_NAME='Graveyard Keeper'

ARCHIVE_BASE_9='graveyard_keeper_1_310_43140.sh'
ARCHIVE_BASE_9_MD5='f802e798769c343d2650d528c5fec77b'
ARCHIVE_BASE_9_TYPE='mojosetup'
ARCHIVE_BASE_9_SIZE='1700000'
ARCHIVE_BASE_9_VERSION='1.310-gog43140'
ARCHIVE_BASE_9_URL='https://www.gog.com/game/graveyard_keeper'

ARCHIVE_BASE_8='graveyard_keeper_1_309_42922.sh'
ARCHIVE_BASE_8_MD5='1100a2132d43e87a667d77a24c0b1f2f'
ARCHIVE_BASE_8_TYPE='mojosetup'
ARCHIVE_BASE_8_SIZE='1700000'
ARCHIVE_BASE_8_VERSION='1.309-gog42922'

ARCHIVE_BASE_7='graveyard_keeper_english_1_304_42468.sh'
ARCHIVE_BASE_7_MD5='0453a408697972de296a3d03de079c9a'
ARCHIVE_BASE_7_TYPE='mojosetup'
ARCHIVE_BASE_7_SIZE='1700000'
ARCHIVE_BASE_7_VERSION='1.304-gog42468'

ARCHIVE_BASE_6='graveyard_keeper_english_1_302_42323.sh'
ARCHIVE_BASE_6_MD5='029e1877be8d6dfae3ee2a880e213654'
ARCHIVE_BASE_6_TYPE='mojosetup'
ARCHIVE_BASE_6_SIZE='1700000'
ARCHIVE_BASE_6_VERSION='1.302-gog42323'

ARCHIVE_BASE_5='graveyard_keeper_1_206_35585.sh'
ARCHIVE_BASE_5_MD5='1312adee331b57bbf1ab97177c73d22c'
ARCHIVE_BASE_5_TYPE='mojosetup'
ARCHIVE_BASE_5_SIZE='1500000'
ARCHIVE_BASE_5_VERSION='1.206-gog35585'

ARCHIVE_BASE_4='graveyard_keeper_1_205_33760.sh'
ARCHIVE_BASE_4_MD5='adc36af20375c66709c907ff4bf61c62'
ARCHIVE_BASE_4_TYPE='mojosetup'
ARCHIVE_BASE_4_SIZE='1500000'
ARCHIVE_BASE_4_VERSION='1.205-gog33760'

ARCHIVE_BASE_3='graveyard_keeper_1_200_33444.sh'
ARCHIVE_BASE_3_MD5='b3ad034826ce31fa26214f64ac2dcf42'
ARCHIVE_BASE_3_TYPE='mojosetup'
ARCHIVE_BASE_3_SIZE='1500000'
ARCHIVE_BASE_3_VERSION='1.200-gog33444'

ARCHIVE_BASE_2='graveyard_keeper_1_124v2_30010.sh'
ARCHIVE_BASE_2_MD5='7d231af29281dcf9188508487dc2cbf4'
ARCHIVE_BASE_2_TYPE='mojosetup'
ARCHIVE_BASE_2_SIZE='920000'
ARCHIVE_BASE_2_VERSION='1.124.2-gog30010'

ARCHIVE_BASE_1='graveyard_keeper_1_123_29391.sh'
ARCHIVE_BASE_1_MD5='409540bb23b6c26ad42fd85d9f5440ec'
ARCHIVE_BASE_1_TYPE='mojosetup'
ARCHIVE_BASE_1_SIZE='940000'
ARCHIVE_BASE_1_VERSION='1.123-gog29391'

ARCHIVE_BASE_0='graveyard_keeper_1_122_25858.sh'
ARCHIVE_BASE_0_MD5='ad75b8ed2c4b74a763849918da672f5b'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='920000'
ARCHIVE_BASE_0_VERSION='1.122-gog25858'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='Graveyard?Keeper.x86 Graveyard?Keeper_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='Graveyard?Keeper.x86_64 Graveyard?Keeper_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Graveyard?Keeper_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Graveyard Keeper.x86'
APP_MAIN_EXE_BIN64='Graveyard Keeper.x86_64'
APP_MAIN_ICON='Graveyard Keeper_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc libstdc++ gtk2 glx libudev1"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

# Work around terminfo Mono bug
# cf. https://github.com/mono/mono/issues/6752

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Work around terminfo Mono bug
# cf. https://github.com/mono/mono/issues/6752
export TERM="${TERM%-256color}"'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
