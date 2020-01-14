#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
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
# Anomaly: Warzone Earth
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20191103.1

# Set game-specific variables

GAME_ID='anomaly-warzone-earth'
GAME_NAME='Anomaly: Warzone Earth'

ARCHIVE_HUMBLE='AnomalyWarzoneEarth-Installer_Humble_Linux_1364850491.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/anomaly-warzone-earth'
ARCHIVE_HUMBLE_MD5='acf5147293b42c7625aea6ad0e56afc4'
ARCHIVE_HUMBLE_SIZE='870000'
ARCHIVE_HUMBLE_VERSION='1.0-humble2'

ARCHIVE_HUMBLE_OLD0='AnomalyWarzoneEarth-Installer'
ARCHIVE_HUMBLE_OLD0_MD5='36d3fb101ab7c674d475b8f0b59d5e68'
ARCHIVE_HUMBLE_OLD0_SIZE='440000'
ARCHIVE_HUMBLE_OLD0_VERSION='1.0-humble1'
ARCHIVE_HUMBLE_OLD0_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data'
ARCHIVE_DOC_DATA_FILES='Copyright* README'

ARCHIVE_GAME_BIN_PATH='data'
ARCHIVE_GAME_BIN_FILES='AnomalyWarzoneEarth'

ARCHIVE_GAME_DATA_PATH='data'
ARCHIVE_GAME_DATA_FILES='*.dat *.idx icon.png'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# work around infinite loading time bug
gcc -m32 -o preload.so preload.c -ldl -shared -fPIC -Wall -Wextra
export LD_PRELOAD=./preload.so'
APP_MAIN_EXE='AnomalyWarzoneEarth'
APP_MAIN_ICON='icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTIOn='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx openal gcc32"
PKG_BIN_DEPS_ARCH_LINUX='lib32-libx11'
PKG_BIN_DEPS_DEB_LINUX='libx11-6'
PKG_BIN_DEPS_GENTOO_LINUX='x11-libs/libX11[abi_x86_32]'

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
case "$ARCHIVE" in
	('ARCHIVE_HUMBLE_OLD0')
		# no .zip container
	;;
	(*)
		(
			ARCHIVE='ARCHIVE_INNER'
			ARCHIVE_INNER_PATH="$PLAYIT_WORKDIR/gamedata/AnomalyWarzoneEarth-Installer"
			ARCHIVE_INNER_TYPE='mojosetup'
			extract_data_from "$ARCHIVE_INNER_PATH"
			rm "$ARCHIVE_INNER_PATH"
		)
	;;
esac
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Hack to work around infinite loading times

cat > "${PKG_BIN_PATH}${PATH_GAME}/preload.c" << EOF
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

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
