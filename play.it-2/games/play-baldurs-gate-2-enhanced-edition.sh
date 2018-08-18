#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180801.4

# Set game-specific variables

GAME_ID='baldurs-gate-2-enhanced-edition'
GAME_NAME='Baldur’s Gate 2 - Enhanced Edition'

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

ARCHIVE_LIBSSL_32='libssl_1.0.0_32-bit.tar.gz'
ARCHIVE_LIBSSL_32_MD5='9443cad4a640b2512920495eaf7582c4'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='./*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='./BaldursGateII ./engine.lua'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='./chitin.key ./lang ./Manuals ./movies ./music ./scripts ./data'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='libs'
APP_MAIN_EXE='BaldursGateII'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# this is needed for smooth upgrades from packages generated with script version < 20180801.3
PKG_DATA_PROVIDE="${GAME_ID}-areas"

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx openal"
PKG_BIN_DEPS_ARCH='lib32-openssl-1.0'

# Load common functions

target_version='2.9'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	for path in\
		'./'\
		"$XDG_DATA_HOME/play.it/"\
		"$XDG_DATA_HOME/play.it/play.it-2/lib/"\
		'/usr/local/share/games/play.it/'\
		'/usr/local/share/play.it/'\
		'/usr/share/games/play.it/'\
		'/usr/share/play.it/'
	do
		if [ -z "$PLAYIT_LIB2" ] && [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
	if [ -z "$PLAYIT_LIB2" ]; then
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
. "$PLAYIT_LIB2"

# Use libSSL 1.0.0 32-bit archive

if [ "$OPTION_PACKAGE" != 'arch' ]; then
	ARCHIVE_MAIN="$ARCHIVE"
	set_archive 'ARCHIVE_LIBSSL' 'ARCHIVE_LIBSSL_32'
	ARCHIVE="$ARCHIVE_MAIN"
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get game icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include libSSL into the game directory

if [ "$ARCHIVE_LIBSSL" ]; then
	(
		ARCHIVE='ARCHIVE_LIBSSL'
		extract_data_from "$ARCHIVE_LIBSSL"
	)
	mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Ensure that libjson.so.0 can be found and loaded for game versions needing it

if [ 'ARCHIVE' = 'ARCHIVE_GOG_OLD0' ]; then
	PKG_BIN_DEPS="$PKG_BIN_DEPS json"

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
fi

# Build packages

write_metadata 'PKG_BIN'
write_metadata 'PKG_DATA'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
