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
# Stellaris - Ancient Relics Story Pack
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210529.4

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris'

EXPANSION_ID='ancient-relics'
EXPANSION_NAME='Ancient Relics Story Pack'

ARCHIVE_BASE_7='stellaris_ancient_relics_3_0_3_47193.sh'
ARCHIVE_BASE_7_MD5='d98a169dca98257b3944517d98cd17a0'
ARCHIVE_BASE_7_TYPE='mojosetup_unzip'
ARCHIVE_BASE_7_SIZE='34000'
ARCHIVE_BASE_7_VERSION='3.0.3-gog47193'
ARCHIVE_BASE_7_URL='https://www.gog.com/game/stellaris_ancient_relics_story_pack'

ARCHIVE_BASE_6='stellaris_ancient_relics_3_0_2_46477.sh'
ARCHIVE_BASE_6_MD5='affdeedf2e83d8a496195f055eb74676'
ARCHIVE_BASE_6_TYPE='mojosetup_unzip'
ARCHIVE_BASE_6_SIZE='34000'
ARCHIVE_BASE_6_VERSION='3.0.2-gog46477'

ARCHIVE_BASE_5='stellaris_ancient_relics_3_0_1_2_46213.sh'
ARCHIVE_BASE_5_MD5='0de7b65612047036c679625a7d8d68af'
ARCHIVE_BASE_5_TYPE='mojosetup_unzip'
ARCHIVE_BASE_5_SIZE='34000'
ARCHIVE_BASE_5_VERSION='3.0.1.2-gog46213'

ARCHIVE_BASE_4='stellaris_ancient_relics_2_8_1_2_42827.sh'
ARCHIVE_BASE_4_MD5='4d1fa824f08e2853bd7d81e5a5c57f3e'
ARCHIVE_BASE_4_SIZE='34000'
ARCHIVE_BASE_4_VERSION='2.8.1.2-gog42827'
ARCHIVE_BASE_4_TYPE='mojosetup_unzip'

ARCHIVE_BASE_3='stellaris_ancient_relics_2_8_0_5_42441.sh'
ARCHIVE_BASE_3_MD5='bf137af989998a1020f73719b9de7306'
ARCHIVE_BASE_3_SIZE='34000'
ARCHIVE_BASE_3_VERSION='2.8.0.5-gog42441'
ARCHIVE_BASE_3_TYPE='mojosetup_unzip'

ARCHIVE_BASE_2='stellaris_ancient_relics_2_8_0_3_42321.sh'
ARCHIVE_BASE_2_MD5='5e3509ccddcf8759773ce8161a081f36'
ARCHIVE_BASE_2_SIZE='34000'
ARCHIVE_BASE_2_VERSION='2.8.0.3-gog42321'
ARCHIVE_BASE_2_TYPE='mojosetup_unzip'

ARCHIVE_BASE_1='stellaris_ancient_relics_story_pack_2_7_2_38578.sh'
ARCHIVE_BASE_1_MD5='a4b7251cd695846f650da58e58aea6bc'
ARCHIVE_BASE_1_SIZE='34000'
ARCHIVE_BASE_1_VERSION='2.7.2-gog38578'
ARCHIVE_BASE_1_TYPE='mojosetup_unzip'

ARCHIVE_BASE_0='stellaris_ancient_relics_story_pack_2_7_1_38218.sh'
ARCHIVE_BASE_0_MD5='b69fc2a812c6eb817e866ec447e461ce'
ARCHIVE_BASE_0_SIZE='34000'
ARCHIVE_BASE_0_VERSION='2.7.1-gog38218'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc/dlc021_ancient_relics'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-${EXPANSION_ID}"
PKG_MAIN_DESCRIPTION="$EXPANSION_NAME"
PKG_MAIN_DEPS="$GAME_ID"

# Ensure smooth upgrade from pre-20201031.1 packages
PKG_MAIN_PROVIDE='stellaris-ancient-relics-story-pack'

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

GAME_NAME="$GAME_NAME - $EXPANSION_NAME"
print_instructions

exit 0
