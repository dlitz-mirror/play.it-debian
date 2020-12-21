#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Botanicula
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201221.1

# Set game-specific variables

SCRIPT_DEPS='identify'

GAME_ID='botanicula'
GAME_NAME='Botanicula'

ARCHIVES_LIST='ARCHIVE_GOG'

ARCHIVE_GOG='gog_botanicula_2.0.0.2.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/botanicula'
ARCHIVE_GOG_MD5='7b92a379f8d2749e2f97c43ecc540c3c'
ARCHIVE_GOG_SIZE='760000'
ARCHIVE_GOG_VERSION='1.0.1-gog2.0.0.2'

ARCHIVE_DOC_PATH='data/noarch/docs'
ARCHIVE_DOC_FILES='./*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='./bin/adl ./runtimes'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='./bin/*.xml ./bin/*.swf ./bin/data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='bin/adl'
APP_MAIN_OPTIONS='bin/BotaniculaLinux-app.xml -nodebug'
unset APP_MAIN_ICONS_LIST
for res in 16 32 36 48 57 72 114 128 256 512; do
	APP_MAIN_ICONS_LIST="$APP_MAIN_ICONS_LIST APP_MAIN_ICON_${res}"
	export APP_MAIN_ICON_${res}="bin/data/icons/b${res}.png"
	export APP_MAIN_ICON_${res}_RES="$res"
done

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS_DEB="$PKG_DATA_ID, libc6, libstdc++6, libnss3, libgtk2.0-0, libxml2, libasound2-plugins"
PKG_BIN_DEPS_ARCH="$PKG_DATA_ID lib32-nss lib32-gtk2 lib32-libxml2 lib32-alsa-plugins"

# Load common functions

target_version='2.3'

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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

PKG='PKG_BIN'
organize_data 'GAME_BIN' "$PATH_GAME"

PKG='PKG_DATA'
organize_data 'DOC'       "$PATH_DOC"
organize_data 'GAME_DATA' "$PATH_GAME"

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

postinst_icons_linking 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
