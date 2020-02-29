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
# Sunless Skies — Cyclopean Owl DLC
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190505.1

# Set game-specific variables

# copy game id from play-sunless-skies.sh
GAME_ID='sunless-skies'
GAME_NAME='Sunless Skies — Cyclopean Owl DLC'

ARCHIVE_GOG='sunless_skies_cyclopean_owl_dlc_1_2_1_3_0224b0c8_28905.sh'
ARCHIVE_GOG_TYPE='mojosetup'
ARCHIVE_GOG_MD5='a1172610549c60fdd0631de49b48414c'
ARCHIVE_GOG_VERSION='1.2.1.3-gog28905'
ARCHIVE_GOG_SIZE='1100'

ARCHIVE_GOG_OLD5='sunless_skies_cyclopean_owl_dlc_1_2_1_2_b0df8add_28695.sh'
ARCHIVE_GOG_OLD5_TYPE='mojosetup'
ARCHIVE_GOG_OLD5_MD5='d709c9b0c944bff07f2d2a0e1f424732'
ARCHIVE_GOG_OLD5_VERSION='1.2.1.2-gog28695'
ARCHIVE_GOG_OLD5_SIZE='1100'

ARCHIVE_GOG_OLD4='sunless_skies_cyclopean_owl_dlc_1_2_0_4_20d30549_27995.sh'
ARCHIVE_GOG_OLD4_TYPE='mojosetup'
ARCHIVE_GOG_OLD4_MD5='e9c2a969bc2129dcbffd6219b79798c2'
ARCHIVE_GOG_OLD4_VERSION='1.2.0.4-gog27995'
ARCHIVE_GOG_OLD4_SIZE='1100'

ARCHIVE_GOG_OLD3='sunless_skies_cyclopean_owl_dlc_1_2_0_2_4cf00080_27469.sh'
ARCHIVE_GOG_OLD3_TYPE='mojosetup'
ARCHIVE_GOG_OLD3_MD5='02fcfda980f0a396554e550a03c3f5f2'
ARCHIVE_GOG_OLD3_VERSION='1.2.0.2-gog27469'
ARCHIVE_GOG_OLD3_SIZE='1100'

ARCHIVE_GOG_OLD2='sunless_skies_cyclopean_owl_dlc_1_2_0_0_157b386b_27304.sh'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'
ARCHIVE_GOG_OLD2_MD5='1eb1b2a3e4886794ccf18133279274cd'
ARCHIVE_GOG_OLD2_VERSION='1.2.0.0-gog27304'
ARCHIVE_GOG_OLD2_SIZE='1100'

ARCHIVE_GOG_OLD1='sunless_skies_cyclopean_owl_dlc_1_1_9_6_e24eac9e_27177.sh'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'
ARCHIVE_GOG_OLD1_MD5='2bb27f4cb86ee68b2bd2204260487ee3'
ARCHIVE_GOG_OLD1_VERSION='1.1.9.6-gog27177'
ARCHIVE_GOG_OLD1_SIZE='1100'

ARCHIVE_GOG_OLD0='sunless_skies_cyclopean_owl_dlc_1_1_9_5_08b4e1b8_27040.sh'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'
ARCHIVE_GOG_OLD0_MD5='52d6ad60c60dd3a7354696275e00b3b0'
ARCHIVE_GOG_OLD0_VERSION='1.1.9.5-gog27040'
ARCHIVE_GOG_OLD0_SIZE='1100'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-dlc-cyclopean-owl"
PKG_MAIN_DEPS="$GAME_ID"

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

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
