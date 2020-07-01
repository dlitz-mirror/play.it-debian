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
# Gibbous - A Cthulhu Adventure
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200608.1

# Set game-specific variables

GAME_ID='gibbous-a-cthulhu-adventure'
GAME_NAME='Gibbous - A Cthulhu Adventure'

ARCHIVES_LIST='
ARCHIVE_GOG_0
'

ARCHIVE_GOG_0='gibbous_a_cthulhu_adventure_x86_64_1_8_35773.sh'
ARCHIVE_GOG_0_MD5='c92315690df34ee8affa24f184486ccb'
ARCHIVE_GOG_0_TYPE='mojosetup_unzip'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/gibbous_a_cthulhu_adventure'
ARCHIVE_GOG_0_SIZE='9500000'
ARCHIVE_GOG_0_VERSION='1.8-gog35773'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='Gibbous?-?A?Cthulhu?Adventure.x86_64 Gibbous?-?A?Cthulhu?Adventure_Data/Mono Gibbous?-?A?Cthulhu?Adventure_Data/Plugins'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Gibbous?-?A?Cthulhu?Adventure_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# Start pulseaudio if it is available
if command -v pulseaudio >/dev/null 2>&1; then
	PULSEAUDIO_IS_AVAILABLE=1
	if pulseaudio --check; then
		KEEP_PULSEAUDIO_RUNNING=1
	else
		KEEP_PULSEAUDIO_RUNNING=0
	fi
	pulseaudio --start
else
	PULSEAUDIO_IS_AVAILABLE=0
fi'
# shellcheck disable=SC1004,SC2016
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Work around crash on launch related to libpulse
# Some Unity3D games crash on launch if libpulse-simple.so.0 is available but pulseaudio is not running
if [ $PULSEAUDIO_IS_AVAILABLE -eq 0 ]; then
	mkdir --parents "${APP_LIBS:=libs}"
	ln --force --symbolic /dev/null "$APP_LIBS/libpulse-simple.so.0"
else
	if \
		[ -h "${APP_LIBS:=libs}/libpulse-simple.so.0" ] && \
		[ "$(realpath "$APP_LIBS/libpulse-simple.so.0")" = "/dev/null" ]
	then
		rm "$APP_LIBS/libpulse-simple.so.0"
		rmdir --ignore-fail-on-non-empty --parents "$APP_LIBS"
	fi
fi'
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Work around Unity3D poor support for non-US locales
export LANG=C'
# shellcheck disable=SC1004,SC2016
APP_MAIN_POSTRUN='# Stop pulseaudio if it has specifically been started for the game
if \
	[ $PULSEAUDIO_IS_AVAILABLE -eq 1 ] && \
	[ $KEEP_PULSEAUDIO_RUNNING -eq 0 ]
then
	pulseaudio --kill
fi'
APP_MAIN_EXE='Gibbous - A Cthulhu Adventure.x86_64'
APP_MAIN_ICON='Gibbous - A Cthulhu Adventure_Data/Resources/UnityPlayer.png'
# Use a per-session dedicated file for logs
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ gtk2"
PKG_BIN_DEPS_ARCH='libx11 gdk-pixbuf2 glib2'
PKG_BIN_DEPS_DEB='libx11-6, libgdk-pixbuf2.0-0, libglib2.0-0'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11 dev-libs/glib sys-libs/zlib'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
