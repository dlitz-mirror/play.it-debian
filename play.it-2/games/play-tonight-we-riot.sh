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
# Tonight We Riot
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210725.5

# Set game-specific variables

GAME_ID='tonight-we-riot'
GAME_NAME='Tonight We Riot'

ARCHIVE_BASE_2='tonight_we_riot_linuxrelease_c_38381.sh'
ARCHIVE_BASE_2_MD5='7afc74aefbccaa58627d934e63c16247'
ARCHIVE_BASE_2_TYPE='mojosetup'
ARCHIVE_BASE_2_SIZE='690000'
ARCHIVE_BASE_2_VERSION='1.0.c-gog38381'
ARCHIVE_BASE_2_URL='https://www.gog.com/game/tonight_we_riot'

ARCHIVE_BASE_1='tonight_we_riot_linuxrelease_b_38278.sh'
ARCHIVE_BASE_1_MD5='7ca6aedccb70bcd027b9e79d5cfb8585'
ARCHIVE_BASE_1_TYPE='mojosetup'
ARCHIVE_BASE_1_SIZE='690000'
ARCHIVE_BASE_1_VERSION='1.0.b-gog38278'

ARCHIVE_BASE_0='tonight_we_riot_linuxrelease_a_38076.sh'
ARCHIVE_BASE_0_MD5='38b03db54a7d80895d2abe0d9f153ae7'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='690000'
ARCHIVE_BASE_0_VERSION='1.0.a-gog38076'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='TonightWeRiot_Linux.x86_64 TonightWeRiot_Linux_Data/Mono TonightWeRiot_Linux_Data/Plugins'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='TonightWeRiot_Linux_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='TonightWeRiot_Linux.x86_64'
APP_MAIN_ICON='TonightWeRiot_Linux_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ gtk2 libz.so.1 libgdk_pixbuf-2.0.so.0 libgobject-2.0.so.0 libglib-2.0.so.0"

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

# Work around Unity3D poor support for non-PulseAudio audio systems

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
		[ -h "${APP_LIBS:=libs}/libpulse-simple.so.0" ] \
		&& \
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
	[ $PULSEAUDIO_IS_AVAILABLE -eq 1 ] \
	&& \
	[ $KEEP_PULSEAUDIO_RUNNING -eq 0 ]
then
	pulseaudio --kill
fi'

# Work around Unity3D poor support for non-US locales

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Work around Unity3D poor support for non-US locales
export LANG=C'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
