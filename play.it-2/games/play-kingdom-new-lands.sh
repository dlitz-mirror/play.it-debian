#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# Kingdom New Lands
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180802.2

# Set game-specific variables

GAME_ID='kingdom-new-lands'
GAME_NAME='Kingdom New Lands'

ARCHIVE_GOG='kingdom_new_lands_en_1_2_8_19096.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/kingdom_new_lands'
ARCHIVE_GOG_MD5='3499d709e78410ef7f447c12e3c66039'
ARCHIVE_GOG_SIZE='450000'
ARCHIVE_GOG_VERSION='1.2.8-gog19096'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD='gog_kingdom_new_lands_2.6.0.8.sh'
ARCHIVE_GOG_OLD_MD5='0d662366f75d5da214e259d792e720eb'
ARCHIVE_GOG_OLD_SIZE='420000'
ARCHIVE_GOG_OLD_VERSION='1.2.3-gog2.6.0.8'
ARCHIVE_GOG_OLD_TYPE='mojosetup'

DATA_DIRS='./logs'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='./*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='./Kingdom_Data/Mono/x86 ./Kingdom_Data/Plugins/x86 ./Kingdom.x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='./Kingdom_Data/Mono/x86_64 ./Kingdom_Data/Plugins/x86_64 ./Kingdom.x86_64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='./Kingdom_Data/global* ./Kingdom_Data/level* ./Kingdom_Data/resources* ./Kingdom_Data/ScreenSelector.png ./Kingdom_Data/sharedassets* ./Kingdom_Data/Managed ./Kingdom_Data/Mono/etc ./Kingdom_Data/Resources ./Kingdom_Data/boot.config'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Kingdom.x86'
APP_MAIN_EXE_BIN64='Kingdom.x86_64'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICONS_LIST='APP_MAIN_ICON'
APP_MAIN_ICON='Kingdom_Data/Resources/UnityPlayer.png'
APP_MAIN_ICON_RES='128'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ sdl2"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.8'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	for path in\
		'./'\
		"$XDG_DATA_HOME/play.it/"\
		"$XDG_DATA_HOME/play.it/play.it-2/lib/"\
		'/usr/local/share/games/play.it/'\
		'/usr/local/share/play.it/'\
		'/usr/share/games/play.it/'\
		'/usr/share/play.it/'
	do
		if [ -z "$PLAYIT_LIB2" ] && [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
	if [ -z "$PLAYIT_LIB2" ]; then
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

prepare_package_layout

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "${PLAYIT_WORKDIR}"

# Print instructions

print_instructions

exit 0
