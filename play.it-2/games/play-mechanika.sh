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
# MechaNika
# build native Linux packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20180912.1

# Set game-specific variables

GAME_ID='mechanika'
GAME_NAME='MechaNika'

ARCHIVES_LIST='ARCHIVE_HUMBLE_32 ARCHIVE_HUMBLE_64'

ARCHIVE_HUMBLE_32='MechaNika_linux32_1.1.10.zip'
ARCHIVE_HUMBLE_32_URL='https://www.humblebundle.com/store/mechanika'
ARCHIVE_HUMBLE_32_MD5='177e488fd1fde7efd89b7bb5a86fe49e'
ARCHIVE_HUMBLE_32_SIZE='220000'
ARCHIVE_HUMBLE_32_VERSION='1.1.10-humble160417'

ARCHIVE_HUMBLE_64='MechaNika_linux64_1.1.10.zip'
ARCHIVE_HUMBLE_64_URL='https://www.humblebundle.com/store/mechanika'
ARCHIVE_HUMBLE_64_MD5='20fecb0fb6e7324c7c8d4b40040ed434'
ARCHIVE_HUMBLE_64_SIZE='220000'
ARCHIVE_HUMBLE_64_VERSION='1.1.10-humble160417'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='MechaNika jre/lib/jexec jre/lib/i386 jre/lib/amd64 jre/lib/*.jar jre/lib/*/*.jar'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='config.json jre MechaNika.jar'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='MechaNika'
APP_MAIN_ICONS_LIST='APP_MAIN_ICON_32 APP_MAIN_ICON_128'
APP_MAIN_ICON_32='graphics/icons/mechanika_icon_32.png'
APP_MAIN_ICON_128='graphics/icons/mechanika_icon_128.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH_HUMBLE_32='32'
PKG_BIN_ARCH_HUMBLE_64='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++"

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

# Get icons

(
	ARCHIVE='ARCHIVE_JAVA'
	ARCHIVE_JAVA="${PKG_DATA_PATH}${PATH_GAME}/MechaNika.jar"
	ARCHIVE_JAVA_TYPE='zip'
	extract_data_from "$ARCHIVE_JAVA"
)
PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

PKG='PKG_DATA'
write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
