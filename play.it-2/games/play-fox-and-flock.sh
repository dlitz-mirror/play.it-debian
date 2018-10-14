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
# Fox & Flock
# build native Linux packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20180912.1

# Set game-specific variables

SCRIPT_DEPS='convert'

GAME_ID='fox-and-flock'
GAME_NAME='Fox & Flock'

ARCHIVES_LIST='ARCHIVE_HUMBLE_32 ARCHIVE_HUMBLE_64'

ARCHIVE_HUMBLE_32='ff-linux-32.zip'
ARCHIVE_HUMBLE_32_URL='https://www.humblebundle.com/store/fox-flock'
ARCHIVE_HUMBLE_32_MD5='6e0dee8044a05ee5bfef8a9885f3f456'
ARCHIVE_HUMBLE_32_SIZE='320000'
ARCHIVE_HUMBLE_32_VERSION='1.0.0-humble1'

ARCHIVE_HUMBLE_64='ff-linux-64.zip'
ARCHIVE_HUMBLE_64_URL='https://www.humblebundle.com/store/fox-flock'
ARCHIVE_HUMBLE_64_MD5='d0c5d87d2415f4eb49c591612e877f42'
ARCHIVE_HUMBLE_64_SIZE='310000'
ARCHIVE_HUMBLE_64_VERSION='1.0.0-humble1'

ARCHIVE_GAME_BIN_PATH='Fox and Flock'
ARCHIVE_GAME_BIN_FILES='foxandflock libffmpegsumo.so nw.pak'

ARCHIVE_GAME_DATA_PATH='Fox and Flock'
ARCHIVE_GAME_DATA_FILES='dist icudtl.dat locales package.json'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='.'
APP_MAIN_EXE='foxandflock'
APP_MAIN_ICON='dist/img/icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH_HUMBLE_32='32'
PKG_BIN_ARCH_HUMBLE_64='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ libxrandr xcursor nss gconf gtk2"
PKG_BIN_DEPS_ARCH_HUMBLE_32='lib32-libnotify'
PKG_BIN_DEPS_ARCH_HUMBLE_64='libnotify'
PKG_BIN_DEPS_DEB='libnotify4'
PKG_BIN_DEPS_GENTOO='' #TODO

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
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Convert icon to standard resolutions

source="${PKG_DATA_PATH}${PATH_GAME}/$APP_MAIN_ICON"
for resolution in '128x128' '256x256'; do
	destination="${PKG_DATA_PATH}${PATH_ICON_BASE}/$resolution/apps/$GAME_ID.png"
	mkdir --parents "${destination%/*}"
	convert "$source" -resize "$resolution" "$destination"
done

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
