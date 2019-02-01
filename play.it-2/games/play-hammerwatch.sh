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
# Hammerwatch
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181021.4

# Set game-specific variables

GAME_ID='hammerwatch'
GAME_NAME='Hammerwatch'

ARCHIVE_GOG='gog_hammerwatch_2.1.0.7.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/hammerwatch'
ARCHIVE_GOG_MD5='2d1f01b73f43e0b6399ab578c52c6cb6'
ARCHIVE_GOG_SIZE='230000'
ARCHIVE_GOG_VERSION='1.32-gog2.1.0.7'

ARCHIVE_HUMBLE='hammerwatch_linux_141.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/hammerwatch'
ARCHIVE_HUMBLE_MD5='a342298f2201a33a616e412b70c4a7f8'
ARCHIVE_HUMBLE_SIZE='230000'
ARCHIVE_HUMBLE_VERSION='1.42-humble180913'

ARCHIVE_HUMBLE_OLD0='hammerwatch_linux1.32.zip'
ARCHIVE_HUMBLE_OLD0_MD5='c31f4053bcde3dc34bc8efe5f232c26e'
ARCHIVE_HUMBLE_OLD0_SIZE='230000'
ARCHIVE_HUMBLE_OLD0_VERSION='1.32-humble160405'

ARCHIVE_DOC_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES_GOG='*'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='.'
ARCHIVE_GAME_BIN32_FILES='lib Hammerwatch.bin.x86'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN32_PATH_HUMBLE_OLD0='Hammerwatch'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='.'
ARCHIVE_GAME_BIN64_FILES='lib64 Hammerwatch.bin.x86_64'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN64_PATH_HUMBLE_OLD0='Hammerwatch'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='.'
ARCHIVE_GAME_DATA_FILES='*.dll *.dll.config *.pdb Hammerwatch.exe editor levels mono assets*'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_HUMBLE_OLD0='Hammerwatch'

CONFIG_FILES='./*.xml'
DATA_FILES='./*.log ./*.txt'
DATA_DIRS='./levels ./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Hammerwatch.bin.x86'
APP_MAIN_EXE_BIN64='Hammerwatch.bin.x86_64'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='Hammerwatch.exe'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_MEDIA_ID $PKG_DATA_ID glibc libstdc++ sdl2 glx"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Copy 'Hammerwatch.exe' into game prefix

pattern='s/^\tcp --parents --dereference --remove-destination "$APP_EXE" "$PATH_PREFIX"$/&\n'
pattern="$pattern"'\tcp --parents --remove-destination "Hammerwatch.exe" "$PATH_PREFIX"/'
file1="${PKG_BIN32_PATH}${PATH_BIN}/$GAME_ID"
file2="${PKG_BIN64_PATH}${PATH_BIN}/$GAME_ID"
sed --in-place "$pattern" "$file1" "$file2"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
