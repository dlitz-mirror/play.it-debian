#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c)      2020, Emmanuel Gil Peyrot <linkmauve@linkmauve.fr>
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
# Higurashi no naku koro ni Hou - Chapter 1 Onikakushi
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201203.6

# Set game-specific variables

GAME_ID='higurashi-no-naku-koro-ni-hou-chapter-1-onikakushi'
GAME_NAME='Higurashi no naku koro ni Hou - Chapter 1 Onikakushi'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='higurashi_when_they_cry_hou_ch_1_onikakushi_1_0_bgm_sfx_update_28641.sh'
ARCHIVE_GOG_0_MD5='501e514ef5accc565eac6e98c384e4aa'
ARCHIVE_GOG_0_TYPE='mojosetup'
ARCHIVE_GOG_0_VERSION='1.0-gog28641'
ARCHIVE_GOG_0_SIZE='310000'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/higurashi_when_they_cry_hou_ch1_onikakushi'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='HigurashiEp01.x86 HigurashiEp01_Data/Mono/x86 HigurashiEp01_Data/Plugins/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='HigurashiEp01.x86_64 HigurashiEp01_Data/Mono/x86_64 HigurashiEp01_Data/Plugins/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='HigurashiEp01_Data'

APP_MAIN_TYPE='native'
#shellcheck disable=SC2016
APP_MAIN_PRERUN='# Work around Unity3D poor support for non-US locales
export LANG=C'
APP_MAIN_EXE_BIN32='HigurashiEp01.x86'
APP_MAIN_EXE_BIN64='HigurashiEp01.x86_64'
APP_MAIN_ICON='HigurashiEp01_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx xcursor libxrandr gtk2 libgdk_pixbuf-2.0.so.0 libgobject-2.0.so.0 libglib-2.0.so.0"
PKG_BIN32_DEPS_ARCH='lib32-libx11'
PKG_BIN32_DEPS_DEB='libx11-6'
PKG_BIN32_DEPS_GENTOO='x11-libs/libX11[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libx11'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/libX11'

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Use a per-session dedicated file for logs

mkdir --parents logs
if [ -z "$APP_OPTIONS" ]; then
	APP_OPTIONS="-logFile logs/$(date +%F-%R).log"
elif [ -n "${APP_OPTIONS##* -logFile *}" ]; then
	APP_OPTIONS="$APP_OPTIONS -logFile logs/$(date +%F-%R).log"
fi'

# Work around crash on launch related to libpulse

# shellcheck disable=SC1004
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Start pulseaudio if it is available
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
fi

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
# shellcheck disable=SC1004
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'
# Stop pulseaudio if it has specifically been started for the game
if \
	[ $PULSEAUDIO_IS_AVAILABLE -eq 1 ] && \
	[ $KEEP_PULSEAUDIO_RUNNING -eq 0 ]
then
	pulseaudio --kill
fi'

# Load common functions

target_version='2.12'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
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

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

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
