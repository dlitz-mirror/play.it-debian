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
# send your bug reports to contact@dotslashplay.it
###

script_version=20200619.4

# Set game-specific variables

# copy game id from play-sunless-skies.sh
GAME_ID='sunless-skies'
GAME_NAME='Sunless Skies — Cyclopean Owl DLC'

ARCHIVES_LIST='
ARCHIVE_GOG_10
ARCHIVE_GOG_9
ARCHIVE_GOG_8
ARCHIVE_GOG_7
ARCHIVE_GOG_6
ARCHIVE_GOG_5
ARCHIVE_GOG_4
ARCHIVE_GOG_3
ARCHIVE_GOG_2
ARCHIVE_GOG_1
ARCHIVE_GOG_0
'

ARCHIVE_GOG_10='sunless_skies_cyclopean_owl_dlc_1_3_6_3bef75f8_33955.sh'
ARCHIVE_GOG_10_TYPE='mojosetup'
ARCHIVE_GOG_10_MD5='d910cd2ce8d6ecb15abe183985d7d838'
ARCHIVE_GOG_10_VERSION='1.3.6.0-gog33955'
ARCHIVE_GOG_10_SIZE='1100'

ARCHIVE_GOG_9='sunless_skies_cyclopean_owl_dlc_1_3_2_06feaeba_33084.sh'
ARCHIVE_GOG_9_TYPE='mojosetup'
ARCHIVE_GOG_9_MD5='b8b19ec517d7490df943b886f4402d81'
ARCHIVE_GOG_9_VERSION='1.3.2.0-gog33084'
ARCHIVE_GOG_9_SIZE='1100'

ARCHIVE_GOG_8='sunless_skies_cyclopean_owl_dlc_1_2_4_0_015d561cx_31380.sh'
ARCHIVE_GOG_8_TYPE='mojosetup'
ARCHIVE_GOG_8_MD5='b5396ebeda83d75096b731c99551f7a8'
ARCHIVE_GOG_8_VERSION='1.2.4.0-gog31380'
ARCHIVE_GOG_8_SIZE='1100'

ARCHIVE_GOG_7='sunless_skies_cyclopean_owl_dlc_1_2_3_0_f3b4e1db_x_30226.sh'
ARCHIVE_GOG_7_TYPE='mojosetup'
ARCHIVE_GOG_7_MD5='5d9fdd039eaead44ad3af3e9d3c780fe'
ARCHIVE_GOG_7_VERSION='1.2.3.0-gog30226'
ARCHIVE_GOG_7_SIZE='1100'

ARCHIVE_GOG_6='sunless_skies_cyclopean_owl_dlc_1_2_1_3_0224b0c8_28905.sh'
ARCHIVE_GOG_6_TYPE='mojosetup'
ARCHIVE_GOG_6_MD5='a1172610549c60fdd0631de49b48414c'
ARCHIVE_GOG_6_VERSION='1.2.1.3-gog28905'
ARCHIVE_GOG_6_SIZE='1100'

ARCHIVE_GOG_5='sunless_skies_cyclopean_owl_dlc_1_2_1_2_b0df8add_28695.sh'
ARCHIVE_GOG_5_TYPE='mojosetup'
ARCHIVE_GOG_5_MD5='d709c9b0c944bff07f2d2a0e1f424732'
ARCHIVE_GOG_5_VERSION='1.2.1.2-gog28695'
ARCHIVE_GOG_5_SIZE='1100'

ARCHIVE_GOG_4='sunless_skies_cyclopean_owl_dlc_1_2_0_4_20d30549_27995.sh'
ARCHIVE_GOG_4_TYPE='mojosetup'
ARCHIVE_GOG_4_MD5='e9c2a969bc2129dcbffd6219b79798c2'
ARCHIVE_GOG_4_VERSION='1.2.0.4-gog27995'
ARCHIVE_GOG_4_SIZE='1100'

ARCHIVE_GOG_3='sunless_skies_cyclopean_owl_dlc_1_2_0_2_4cf00080_27469.sh'
ARCHIVE_GOG_3_TYPE='mojosetup'
ARCHIVE_GOG_3_MD5='02fcfda980f0a396554e550a03c3f5f2'
ARCHIVE_GOG_3_VERSION='1.2.0.2-gog27469'
ARCHIVE_GOG_3_SIZE='1100'

ARCHIVE_GOG_2='sunless_skies_cyclopean_owl_dlc_1_2_0_0_157b386b_27304.sh'
ARCHIVE_GOG_2_TYPE='mojosetup'
ARCHIVE_GOG_2_MD5='1eb1b2a3e4886794ccf18133279274cd'
ARCHIVE_GOG_2_VERSION='1.2.0.0-gog27304'
ARCHIVE_GOG_2_SIZE='1100'

ARCHIVE_GOG_1='sunless_skies_cyclopean_owl_dlc_1_1_9_6_e24eac9e_27177.sh'
ARCHIVE_GOG_1_TYPE='mojosetup'
ARCHIVE_GOG_1_MD5='2bb27f4cb86ee68b2bd2204260487ee3'
ARCHIVE_GOG_1_VERSION='1.1.9.6-gog27177'
ARCHIVE_GOG_1_SIZE='1100'

ARCHIVE_GOG_0='sunless_skies_cyclopean_owl_dlc_1_1_9_5_08b4e1b8_27040.sh'
ARCHIVE_GOG_0_TYPE='mojosetup'
ARCHIVE_GOG_0_MD5='52d6ad60c60dd3a7354696275e00b3b0'
ARCHIVE_GOG_0_VERSION='1.1.9.5-gog27040'
ARCHIVE_GOG_0_SIZE='1100'

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

# Work around misplaced file in provided archive

destination_file="$PLAYIT_WORKDIR/gamedata/data/noarch/game/dlc/OwlScout/OwlScout.dlc"

for source_file in \
	"$PLAYIT_WORKDIR/gamedata/data/noarch/game/DLC/OwlScout/OwlScout.dlc" \
	"$PLAYIT_WORKDIR/gamedata/data/noarch/game/OwlScout.dlc"
do
	if [ -e "$source_file" ]; then
		mkdir --parents "$(dirname "$destination_file")"
		mv "$source_file" "$destination_file"
	fi
done

# Prepare package

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
