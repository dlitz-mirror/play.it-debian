#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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
# Talk to Me
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200925.1

# Set game-specific variables

GAME_ID='talk-to-me'
GAME_NAME='Talk to Me'

ARCHIVES_LIST='
ARCHIVE_ITCH_0'

ARCHIVE_ITCH_0='TalkToMe-1.02-pc.zip'
ARCHIVE_ITCH_0_URL='https://boop-studios.itch.io/talk-to-me'
ARCHIVE_ITCH_0_MD5='9f7ae1c12a4c7bcb6a40aa4157205e4b'
ARCHIVE_ITCH_0_SIZE='410000'
ARCHIVE_ITCH_0_VERSION='1.02-itch1'
ARCHIVE_ITCH_0_TYPE='zip'

ARCHIVE_GAME_BIN32_PATH='TalkToMe-1.02-pc'
ARCHIVE_GAME_BIN32_FILES='lib/linux-i686 TalkToMe.sh'

ARCHIVE_GAME_BIN64_PATH='TalkToMe-1.02-pc'
ARCHIVE_GAME_BIN64_FILES='lib/linux-x86_64'

ARCHIVE_GAME_DATA_PATH='TalkToMe-1.02-pc'
ARCHIVE_GAME_DATA_FILES='lib/pythonlib2.7 game TalkToMe.py renpy'

DATA_DIRS='game/saves'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='TalkToMe.sh'
APP_MAIN_ICON='TalkToMe-1.02-pc/TalkToMe.exe'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.12'

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

# Copy launching script between the binaries packages

LAUNCHER_SOURCE="${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_EXE"
LAUNCHER_DESTINATION="${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_EXE"
mkdir --parents "$(dirname "$LAUNCHER_DESTINATION")"
cp "$LAUNCHER_SOURCE" "$LAUNCHER_DESTINATION"

# Get icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
