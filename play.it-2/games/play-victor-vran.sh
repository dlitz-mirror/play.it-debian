#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2017-2021, Jacek Szafarkiewicz
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
# Victor Vran
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210525.8

# Set game-specific variables

SCRIPTS_DEPS='gcc'

GAME_ID='victor-vran'
GAME_NAME='Victor Vran'

ARCHIVE_BASE_0='victor_vran_2_07_20181005_24296.sh'
ARCHIVE_BASE_0_MD5='506f55f5521131e7ab69b656a3e55582'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'
ARCHIVE_BASE_0_VERSION='2.07.20181005-gog24296'
ARCHIVE_BASE_0_SIZE='5000000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/victor_vran'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='VictorVranGOG'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='DLC Local Movies Packs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='VictorVranGOG'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc libstdc++ libcurl-gnutls libxrandr glx libopenal.so.1 libX11.so.6 libSDL2-2.0.so.0"
PKG_BIN_DEPS_ARCH='lib32-libxext lib32-libxrender lib32-libxt'
PKG_BIN_DEPS_DEB='libxext6, libxrender1, libxt6'
PKG_BIN_DEPS_GENTOO='x11-libs/libXext[abi_x86_32] x11-libs/libXrender[abi_x86_32] x11-libs/libXt[abi_x86_32]'

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

# Work around the engine expectation that files are owned by the current user

###
# TODO
# Add in the hacks directory a short description of the included hacks
###

PKG='PKG_BIN'
HACKS_DIRECTORY_NAME='hacks'
HACKS_DIRECTORY="$(package_get_path "$PKG")${PATH_GAME}/${HACKS_DIRECTORY_NAME}"
HACK_SOURCE="${HACKS_DIRECTORY}/vv_noatime.c"
HACK_ELF="${HACK_SOURCE%.c}.so"

mkdir --parents "$HACKS_DIRECTORY"

cat > "$HACK_SOURCE" << 'EOF'
#define _GNU_SOURCE
#include <dlfcn.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stddef.h>
#include <stdarg.h>

typedef int (*orig_open_f_type)(const char *pathname, int flags, mode_t mode);

int open(const char *pathname, int flags, ...)
{
	va_list valist;
	mode_t mode;
	static orig_open_f_type orig_open = NULL;
	if (orig_open == NULL)
		orig_open = (orig_open_f_type)dlsym(RTLD_NEXT, "open");

	flags &= ~O_NOATIME;

	if (flags & (O_CREAT | O_TMPFILE)) {
		va_start(valist, flags);
		mode = va_arg(valist, mode_t);
		va_end(valist);
	}

	return orig_open(pathname, flags, mode);
}
EOF

set +o errexit
gcc -shared "$HACK_SOURCE" -o "$HACK_ELF" -Wall -m32 -fPIC -ldl
HACK_BUILD_STATUS=$?
set -o errexit

###
# TODO
# A documentation page on our forge should list the required packages.
###

if [ $HACK_BUILD_STATUS -ne 0 ]; then
	case "${LANG%_*}" in
		('fr')
			HACK_BUILD_ERROR_MESSAGE='Les bibliothèques nécessaires à construire des binaires 32-bit ne sont pas disponibles sur ce système.\n'
		;;
		('en'|*)
			HACK_BUILD_ERROR_MESSAGE='Libraries required to build 32-bit binaries are not available on the current system.\n'
		;;
	esac
	print_error
	printf "$HACK_BUILD_ERROR_MESSAGE"
	exit 1
fi

APP_MAIN_PRERUN="$APP_MAIN_PRERUN

# Work around the engine expectation that files are owned by the current user
LD_PRELOAD='${HACKS_DIRECTORY_NAME}/$(basename "$HACK_ELF")'
export LD_PRELOAD"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get game icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'

# Include shipped libgcrypt.so.11 on Debian
# Use the system-provided libraries on Arch Linux and Gentoo

case "$OPTION_PACKAGE" in
	('deb')
		PKG='PKG_BIN'
		PATH_LIBS="$(package_get_path "$PKG")${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
		mkdir --parents "$PATH_LIBS"
		mv \
			"${PLAYIT_WORKDIR}/gamedata/data/noarch/game/i386/lib/i386-linux-gnu/libgcrypt.so.11.7.0" \
			"$PATH_LIBS"
		ln --symbolic 'libgcrypt.so.11.7.0' "${PATH_LIBS}/libgcrypt.so.11"
	;;
	('arch')
		PKG_BIN_DEPS_ARCH="${PKG_BIN_DEPS_ARCH} lib32-libgcrypt15"
	;;
	('gentoo'|'egentoo')
		PKG_BIN_DEPS_GENTOO="${PKG_BIN_DEPS_GENTOO} dev-libs/libgcrypt-compat[abi_x86_32]"
	;;
esac

# Clean up temporary data

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Work around a failure to launch due to not parsing the correct SSL configuration

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Work around a failure to launch due to not parsing the correct SSL configuration

export OPENSSL_CONF=/etc/ssl'

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
