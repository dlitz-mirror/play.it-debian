#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2019, Solène "Mopi" Huault
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
# Baldur’s Gate 2 - Enhanced Edition
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20191009.1

# Set game-specific variables

GAME_ID='baldurs-gate-2-enhanced-edition'
GAME_NAME='Baldurʼs Gate 2 - Enhanced Edition'

ARCHIVE_GOG='baldur_s_gate_2_enhanced_edition_en_2_5_21851.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/baldurs_gate_2_enhanced_edition'
ARCHIVE_GOG_MD5='4508edf93d6b138a7e91aa0f2f82605a'
ARCHIVE_GOG_SIZE='3700000'
ARCHIVE_GOG_VERSION='2.5.16.6-gog21851'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_baldur_s_gate_2_enhanced_edition_2.6.0.11.sh'
ARCHIVE_GOG_OLD0_MD5='b9ee856a29238d4aec65367377d88ac4'
ARCHIVE_GOG_OLD0_SIZE='2700000'
ARCHIVE_GOG_OLD0_VERSION='2.3.67.3-gog2.6.0.11'

ARCHIVE_OPTIONAL_LIBSSL32='libssl_1.0.0_32-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBSSL32_URL='https://www.dotslashplay.it/ressources/libssl/'
ARCHIVE_OPTIONAL_LIBSSL32_MD5='9443cad4a640b2512920495eaf7582c4'

ARCHIVE_OPTIONAL_LIBSSL64='libssl_1.0.0_64-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBSSL64_URL='https://www.dotslashplay.it/ressources/libssl/'
ARCHIVE_OPTIONAL_LIBSSL64_MD5='89917bef5dd34a2865cb63c2287e0bd4'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='BaldursGateII'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='BaldursGateII64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='chitin.key engine.lua lang Manuals movies music scripts data'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='libs'
APP_MAIN_EXE_BIN32='BaldursGateII'
APP_MAIN_EXE_BIN64='BaldursGateII64'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'
# Keep compatibility with old archives
PACKAGES_LIST_GOG_OLD0='PKG_BIN32 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# This is needed for smooth upgrades from packages generated with script version < 20180801.3
PKG_DATA_PROVIDE="${GAME_ID}-areas"

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx openal libxrandr alsa xcursor"
PKG_BIN32_DEPS_ARCH='lib32-libx11 lib32-expat lib32-openssl-1.0'
PKG_BIN32_DEPS_DEB='libx11-6, libexpat1'
PKG_BIN32_DEPS_GENTOO='libx11-6[abi_x86_32] dev-libs/expat[abi_x86_32] dev-libs/openssl[abi_x86_32]'
# Keep compatibility with old archives
PKG_BIN32_DEPS_OLD0="$PKG_DATA_ID glibc libstdc++ glx openal json"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libx11 expat openssl-1.0'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='libx11-6 dev-libs/expat dev-libs/openssl'

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

# Update list of packages to build, based on source archive

use_archive_specific_value 'PACKAGES_LIST'
# shellcheck disable=SC2086
set_temp_directories $PACKAGES_LIST

# Use libSSL 1.0.0 32-bit archive

case "$OPTION_PACKAGE" in
	('deb')
		ARCHIVE_MAIN="$ARCHIVE"
		set_archive 'ARCHIVE_LIBSSL32' 'ARCHIVE_OPTIONAL_LIBSSL32'
		case "$ARCHIVE" in
			('ARCHIVE_GOG_OLD0')
				# Nothing to do here, 64-bit binary is not available
				true
			;;
			(*)
				set_archive 'ARCHIVE_LIBSSL64' 'ARCHIVE_OPTIONAL_LIBSSL64'
			;;
		esac
		ARCHIVE="$ARCHIVE_MAIN"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get game icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include libSSL into the game directory

if [ "$ARCHIVE_LIBSSL32" ]; then
	(
		# shellcheck disable=SC2030
		ARCHIVE='ARCHIVE_LIBSSL32'
		extract_data_from "$ARCHIVE_LIBSSL32"
	)
	mkdir --parents "${PKG_BIN32_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
	mv "$PLAYIT_WORKDIR/gamedata"/lib*.so.1.0.0 "${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi
if [ "$ARCHIVE_LIBSSL64" ]; then
	(
		# shellcheck disable=SC2030
		ARCHIVE='ARCHIVE_LIBSSL64'
		extract_data_from "$ARCHIVE_LIBSSL64"
	)
	mkdir --parents "${PKG_BIN64_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
	mv "$PLAYIT_WORKDIR/gamedata"/lib*.so.1.0.0 "${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Write launchers

PKG='PKG_BIN32'
launchers_write 'APP_MAIN'
# shellcheck disable=SC2031
case "$ARCHIVE" in
	('ARCHIVE_GOG_OLD0')
		# Nothing to do here, 64-bit binary is not available
		true
	;;
	(*)
		PKG='PKG_BIN64'
		launchers_write 'APP_MAIN'
	;;
esac

# Build packages

# shellcheck disable=SC2031
case "$ARCHIVE" in
	('ARCHIVE_GOG_OLD0')
		# Ensure that libjson.so.0 can be found and loaded for game versions needing it
		target="$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
		cat > "$postinst" <<- EOF
		if [ ! -e "$target" ]; then
		    for source in \
		        /lib/i386-linux-gnu/libjson-c.so \
		        /lib/i386-linux-gnu/libjson-c.so.2 \
		        /lib/i386-linux-gnu/libjson-c.so.3 \
		        /usr/lib32/libjson-c.so
		    do
		        if [ -e "\$source" ] ; then
		            mkdir --parents "${target%/*}"
		            ln --symbolic "\$source" "$target"
		            break
		        fi
		    done
		fi
		EOF
		cat > "$prerm" <<- EOF
		if [ -e "$target" ]; then
		    rm "$target"
		    rmdir --ignore-fail-on-non-empty --parents "${target%/*}"
		fi
		EOF
		write_metadata 'PKG_BIN32'
	;;
	(*)
		write_metadata 'PKG_BIN32' 'PKG_BIN64'
	;;
esac
write_metadata 'PKG_DATA'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
