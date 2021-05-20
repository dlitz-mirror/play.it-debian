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
# Anomaly 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210514.3

# Set game-specific variables

GAME_ID='anomaly-2'
GAME_NAME='Anomaly 2'

ARCHIVE_BASE_LINUX_0='Anomaly2_Linux_1387299615.zip'
ARCHIVE_BASE_LINUX_0_MD5='46f0ecd5363106e9eae8642836c29dfc'
ARCHIVE_BASE_LINUX_0_SIZE='2500000'
ARCHIVE_BASE_LINUX_0_VERSION='1.0-humble1'
ARCHIVE_BASE_LINUX_0_URL='https://www.humblebundle.com/store/anomaly-2'

ARCHIVE_BASE_WINDOWS_0='Anomaly2_Windows_1387299615.zip'
ARCHIVE_BASE_WINDOWS_0_MD5='2b5ccffcbaee8cfebfd4bb74cacb9fbc'
ARCHIVE_BASE_WINDOWS_0_SIZE='2500000'
ARCHIVE_BASE_WINDOWS_0_VERSION='1.0-humble1'
ARCHIVE_BASE_WINDOWS_0_URL='https://www.humblebundle.com/store/anomaly-2'

ARCHIVE_GAME_BIN_PATH_LINUX='Anomaly 2 Linux DRM-free'
ARCHIVE_GAME_BIN_PATH_WINDOWS='Anomaly 2 Windows DRM-free/2013-12-17 03-20'
ARCHIVE_GAME_BIN_FILES='*.exe *.dll *.txt Anomaly2 libopenal.so.1'

ARCHIVE_GAME_COMMON_PATH_LINUX='Anomaly 2 Linux DRM-free'
ARCHIVE_GAME_COMMON_PATH_WINDOWS='Anomaly 2 Windows DRM-free/2013-12-17 03-20'
ARCHIVE_GAME_COMMON_FILES='videos.dat voices.dat'

ARCHIVE_GAME_DATA_PATH_LINUX='Anomaly 2 Linux DRM-free'
ARCHIVE_GAME_DATA_PATH_WINDOWS='Anomaly 2 Windows DRM-free/2013-12-17 03-20'
ARCHIVE_GAME_DATA_FILES='*.idx *.str animations.dat common.dat scenes.dat sounds.dat templates.dat textures.dat'

# optional icons pack
ARCHIVE_OPTIONAL_ICONS='anomaly-2_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_MD5='73ddbd1651e08d6c8bb4735e5e0a4a81'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/resources/anomaly-2/'
ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='32x32 48x48 64x64 256x256'

# game binary — Linux version
APP_MAIN_TYPE_LINUX='native'
APP_MAIN_EXE_LINUX='Anomaly2'

# game binary — Windows version
APP_MAIN_TYPE_WINDOWS='wine'
APP_MAIN_EXE_WINDOWS='Anomaly 2.exe'
APP_MAIN_ICON_WINDOWS='Anomaly 2.exe'

PACKAGES_LIST='PKG_COMMON PKG_DATA PKG_BIN'

PKG_COMMON_ID="${GAME_ID}-data-common"
PKG_COMMON_DESCRIPTIOn='data - common'

# data packages — common properties
PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_PROVIDE="$PKG_DATA_ID"
PKG_DATA_DESCRIPTION='data'

# data packages — Linux version
PKG_DATA_ID_LINUX="${PKG_DATA_ID}-linux"
PKG_DATA_DESCRIPTION_LINUX="${PKG_DATA_DESCRIPTION} - Linux"

# data packages — Windows version
PKG_DATA_ID_WINDOWS="${PKG_DATA_ID}-windows"
PKG_DATA_DESCRIPTION_WINDOWS="${PKG_DATA_DESCRIPTION} - Windows"

# binaries package — common properties
PKG_BIN_ID="$GAME_ID"
PKG_BIN_PROVIDE="$PKG_BIN_ID"
PKG_BIN_ARCH='32'

# binaries package — Linux version
PKG_BIN_ID_LINUX="${PKG_BIN_ID}-linux"
PKG_BIN_DEPS_LINUX="${PKG_COMMON_ID} ${PKG_DATA_ID} glibc libstdc++ glx openal"
PKG_BIN_DEPS_ARCH_LINUX='lib32-libpulse lib32-libx11'
PKG_BIN_DEPS_DEB_LINUX='libpulse0, libx11-6'
PKG_BIN_DEPS_GENTOO_LINUX='media-sound/pulseaudio[abi_x86_32] x11-libs/libX11[abi_x86_32]'

# binaries package — Windows version
PKG_BIN_ID_WINDOWS="${PKG_BIN_ID}-windows"
PKG_BIN_DEPS_WINDOWS="${PKG_COMMON_ID} ${PKG_DATA_ID} wine glx xcursor"

# Keep compatibility with pre-20200303.1 scripts
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Keep compatibility with pre-20200303.1 scripts
if [ -e "$PATH_CONFIG/userdata/config.bin" ]; then
	mkdir --parents "$PATH_DATA/userdata"
	cp --remove-destination "$PATH_CONFIG/userdata/config.bin" "$PATH_DATA/userdata"
	mv "$PATH_CONFIG/userdata/config.bin" "$PATH_CONFIG/userdata/config.bin.old"
fi'
APP_MAIN_PRERUN_LINUX="$APP_MAIN_PRERUN"
APP_MAIN_PRERUN_WINDOWS="$APP_MAIN_PRERUN"

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

# Try to load icons archive

case "$ARCHIVE" in
	('ARCHIVE_BASE_LINUX'*)
		ARCHIVE_MAIN="$ARCHIVE"
		set_archive 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
		ARCHIVE="$ARCHIVE_MAIN"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icons

case "$ARCHIVE" in
	('ARCHIVE_BASE_LINUX'*)
		if [ -n "$ARCHIVE_ICONS" ]; then
			(
				ARCHIVE='ARCHIVE_ICONS'
				extract_data_from "$ARCHIVE_ICONS"
			)
			PKG='PKG_DATA'
			organize_data 'ICONS' "$PATH_ICON_BASE"
		fi
	;;
	('ARCHIVE_BASE_WINDOWS'*)
		PKG='PKG_BIN'
		use_archive_specific_value 'APP_MAIN_ICON'
		icons_get_from_package 'APP_MAIN'
		icons_move_to 'PKG_DATA'
	;;
esac

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Hack to work around infinite loading times

###
# TODO
# This hack could probably be included in the package, instead of built at run time
###
PKG_BIN_DEPS_LINUX="${PKG_BIN_DEPS_LINUX} gcc32"
case "$ARCHIVE" in
	('ARCHIVE_BASE_LINUX'*)
		cat > "${PKG_BIN_PATH}${PATH_GAME}/preload.c" <<- EOF
		#define _GNU_SOURCE
		#include <dlfcn.h>
		#include <semaphore.h>
		#include <stdio.h>
		#include <time.h>
		#include <unistd.h>

		static int (*_realSemTimedWait)(sem_t *, const struct timespec *) = NULL;

		int sem_timedwait(sem_t *sem, const struct timespec *abs_timeout) {
		    if (abs_timeout->tv_nsec >= 1000000000) {
		        ((struct timespec *)abs_timeout)->tv_nsec -= 1000000000;
		        ((struct timespec *)abs_timeout)->tv_sec++;
		    }
		    return _realSemTimedWait(sem, abs_timeout);
		}
		__attribute__((constructor)) void init(void) {
		    _realSemTimedWait = dlsym(RTLD_NEXT, "sem_timedwait");
		}
		EOF
	;;
esac
APP_MAIN_PRERUN_LINUX="$APP_MAIN_PRERUN_LINUX"'

# Work around infinite loading time bug
gcc -m32 -o preload.so preload.c -ldl -shared -fPIC -Wall -Wextra
LD_PRELOAD=./preload.so
export LD_PRELOAD'
APP_MAIN_POSTRUN_LINUX="$APP_MAIN_POSTRUN_LINUX"'

# Unload hack used to work around infinite loading time bug
unset LD_PRELOAD'

# Share saved games and config between Linux and Windows engines

APP_MAIN_PRERUN_LINUX="$APP_MAIN_PRERUN_LINUX"'

# Share saved games and config between Linux and Windows engines
NEW_LAUNCH_REQUIRED=0
if [ -e "$HOME/.Anomaly 2" ] && [ ! -h "$HOME/.Anomaly 2" ]; then
	for file in \
		config.bin \
		DefaultUser \
		iPhoneProfiles
	do
		if [ -e "$HOME/.Anomaly 2/$file" ]; then
			mkdir --parents "$PATH_DATA/userdata"
			cp --recursive "$HOME/.Anomaly 2/$file" "$PATH_DATA/userdata"
		fi
	done
	mv "$HOME/.Anomaly 2" "$HOME/.Anomaly 2.old"
	NEW_LAUNCH_REQUIRED=1
fi
if [ ! -e "$HOME/.Anomaly 2" ]; then
	rm --force "$HOME/.Anomaly 2"
	ln --symbolic "$PATH_PREFIX/userdata" "$HOME/.Anomaly 2"
fi
if [ $NEW_LAUNCH_REQUIRED -eq 1 ]; then
	"$0"
	exit 0
fi'
DATA_DIRS="$DATA_DIRS ./userdata"
APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"'
userdata:users/$USER/Application Data/11bitstudios/Anomaly 2'

# Ensure PulseAudio is available when running the Linux version

PKG_BIN_DEPS_LINUX="${PKG_BIN_DEPS_LINUX} pulseaudio"
APP_MAIN_PRERUN_LINUX="$APP_MAIN_PRERUN_LINUX"'

# Ensure PulseAudio is running
PULSEAUDIO_IS_AVAILABLE=1
if pulseaudio --check; then
	KEEP_PULSEAUDIO_RUNNING=1
else
	KEEP_PULSEAUDIO_RUNNING=0
fi
pulseaudio --start'
APP_MAIN_POSTRUN_LINUX="$APP_MAIN_POSTRUN_LINUX"'

# Stop pulseaudio if it has specifically been started for the game
if [ $KEEP_PULSEAUDIO_RUNNING -eq 0 ]; then
	pulseaudio --kill
fi'

# Write launchers

PKG='PKG_BIN'
use_archive_specific_value 'APP_MAIN_TYPE'
use_archive_specific_value 'APP_MAIN_PRERUN'
use_archive_specific_value 'APP_MAIN_POSTRUN'
use_archive_specific_value 'APP_MAIN_EXE'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
