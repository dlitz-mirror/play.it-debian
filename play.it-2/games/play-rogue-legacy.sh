#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, BetaRays
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
# Rogue legacy
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180825.1

# Set game-specific variables

GAME_ID='rogue-legacy'
GAME_NAME='Rogue legacy'

ARCHIVE_GOG='rogue_legacy_en_1_4_0_22617.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/rogue_legacy'
ARCHIVE_GOG_MD5='60a1a7a7ff84a50e2ac52f2e44dce92d'
ARCHIVE_GOG_VERSION='1.4.0-gog22617'
ARCHIVE_GOG_SIZE='370000'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_rogue_legacy_2.0.0.2.sh'
ARCHIVE_GOG_OLD0_MD5='1b99d6122f0107b420cad9547efefc5e'
ARCHIVE_GOG_OLD0_VERSION='1.2.0b-gog2.0.0.2'
ARCHIVE_GOG_OLD0_SIZE='240000'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_HUMBLE='roguelegacy-12282013-bin'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/rogue-legacy'
ARCHIVE_HUMBLE_MD5='b2a18745b911ed87a048440c2f8a0404'
ARCHIVE_HUMBLE_VERSION='1.2.0b-humble131228'
ARCHIVE_HUMBLE_SIZE='240000'
ARCHIVE_HUMBLE_TYPE='mojosetup'

ARCHIVE_DOC0_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC0_DATA_PATH_HUMBLE='data'
ARCHIVE_DOC0_DATA_FILES='./Linux.README'

ARCHIVE_DOC1_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC1_DATA_FILES='./*.txt'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='data'
ARCHIVE_GAME_BIN32_FILES='Rogue*.bin.x86 lib/libmojoshader.so lib/libmono-2.0.so.1'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='data'
ARCHIVE_GAME_BIN64_FILES='Rogue*.bin.x86_64 lib64/libmojoshader.so lib64/libmono-2.0.so.1'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='data'
ARCHIVE_GAME_DATA_FILES='*.bmp *.dll *.dll.config *.exe Content mono*'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32_GOG='RogueLegacy.bin.x86'
APP_MAIN_EXE_BIN64_GOG='RogueLegacy.bin.x86_64'
APP_MAIN_EXE_BIN32_HUMBLE='RogueCastle.bin.x86'
APP_MAIN_EXE_BIN64_HUMBLE='RogueCastle.bin.x86_64'
APP_MAIN_ICON='Rogue Legacy.bmp'
# Keep compatibility with old archives
APP_MAIN_EXE_BIN32_GOG_OLD0='RogueCastle.bin.x86'
APP_MAIN_EXE_BIN64_GOG_OLD0='RogueCastle.bin.x86_64'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID sdl2 openal glibc"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.10'

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

use_archive_specific_value 'APP_MAIN_EXE_BIN32'
use_archive_specific_value 'APP_MAIN_EXE_BIN64'
for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Fix a crash when starting from some terminals

pattern='s#^"\./$APP_EXE" .*#& > ./logs/$(date +%F-%R).log#'
sed --in-place "$pattern" "${PKG_BIN32_PATH}${PATH_BIN}/$GAME_ID"
sed --in-place "$pattern" "${PKG_BIN64_PATH}${PATH_BIN}/$GAME_ID"

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
