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
# Icewind Dale - Enhanced Edition
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180929.1

# Set game-specific variables

GAME_ID='icewind-dale-1-enhanced-edition'
GAME_NAME='Icewind Dale - Enhanced Edition'

ARCHIVE_GOG='icewind_dale_enhanced_edition_en_2_5_17_23121.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/icewind_dale_enhanced_edition'
ARCHIVE_GOG_MD5='bdfcd244568916123c243fb95de1d08b'
ARCHIVE_GOG_SIZE='2900000'
ARCHIVE_GOG_VERSION='2.5.17.0-gog23121'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='icewind_dale_enhanced_edition_en_2_5_16_3_20626.sh'
ARCHIVE_GOG_OLD1_MD5='f237e9506f046862e8d1c2d21c8fd588'
ARCHIVE_GOG_OLD1_SIZE='2900000'
ARCHIVE_GOG_OLD1_VERSION='2.5.16.3-gog20626'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_icewind_dale_enhanced_edition_2.1.0.5.sh'
ARCHIVE_GOG_OLD0_MD5='fc7244f4793eec365b8ac41d91a4edbb'
ARCHIVE_GOG_OLD0_SIZE='2900000'
ARCHIVE_GOG_OLD0_VERSION='1.4.0-gog2.1.0.5'

ARCHIVE_OPTIONAL_LIBSSL32='libssl_1.0.0_32-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBSSL32_URL='https://www.dotslashplay.it/ressources/libssl/'
ARCHIVE_OPTIONAL_LIBSSL32_MD5='9443cad4a640b2512920495eaf7582c4'

ARCHIVE_OPTIONAL_LIBSSL64='libssl_1.0.0_64-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBSSL64_URL='https://www.dotslashplay.it/ressources/libssl/'
ARCHIVE_OPTIONAL_LIBSSL64_MD5='89917bef5dd34a2865cb63c2287e0bd4'

ARCHIVE_OPTIONAL_ICONS='icewind-dale-1-enhanced-edition_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_URL='https://www.dotslashplay.it/ressources/icewind-dale-1-enhanced-edition/'
ARCHIVE_OPTIONAL_ICONS_MD5='2e7db406aca79f9182c4efa93df80bf4'

ARCHIVE_DOC_PATH='data/noarch/docs'
ARCHIVE_DOC_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='IcewindDale'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='IcewindDale64'

ARCHIVE_GAME_L10N_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_FILES='lang'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='chitin.key engine.lua data movies music scripts'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 32x32 48x48 64x64 128x128 256x256'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='libs'
APP_MAIN_EXE_BIN32='IcewindDale'
APP_MAIN_EXE_BIN64='IcewindDale64'
APP_MAIN_ICON_GOG='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_L10N PKG_DATA'
# Keep compatibility with old archives
PACKAGES_LIST_GOG_OLD0='PKG_BIN32 PKG_L10N PKG_DATA'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_DESCRIPTION='localizations'
# Easier upgrade from packages generated with pre-20180926.2 scripts
PKG_L10N_PROVIDE='icewind-dale-enhanced-edition-l10n'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# Easier upgrade from packages generated with pre-20180926.2 scripts
PKG_DATA_PROVIDE='icewind-dale-enhanced-edition-data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_L10N_ID $PKG_DATA_ID glibc libstdc++ glx openal"
PKG_BIN32_DEPS_ARCH='lib32-openssl-1.0'
# Easier upgrade from packages generated with pre-20180926.2 scripts
PKG_BIN32_PROVIDE='icewind-dale-enhanced-edition'
# Keep compatibility with old archives
PKG_BIN32_DEPS_GOG_OLD0="$PKG_BIN32_DEPS json"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH="$PKG_BIN32_DEPS_ARCH"
# Easier upgrade from packages generated with pre-20180926.2 scripts
PKG_BIN64_PROVIDE='icewind-dale-enhanced-edition'

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

# Set pakcages list dependending on source archive
use_archive_specific_value 'PACKAGES_LIST'
set_temp_directories $PACKAGES_LIST

# Try to load icons archive

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
ARCHIVE="$ARCHIVE_MAIN"

# Use libSSL 1.0.0 archives (Debian packages only)

if [ "$OPTION_PACKAGE" = 'deb' ]; then
	ARCHIVE_MAIN="$ARCHIVE"
	archive_set 'ARCHIVE_LIBSSL32' 'ARCHIVE_OPTIONAL_LIBSSL32'
	archive_set 'ARCHIVE_LIBSSL64' 'ARCHIVE_OPTIONAL_LIBSSL64'
	ARCHIVE="$ARCHIVE_MAIN"
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icons

PKG='PKG_DATA'
if [ "$ARCHIVE_ICONS" ]; then
	(
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
	organize_data 'ICONS' "$PATH_ICON_BASE"
else
	icons_get_from_workdir 'APP_MAIN'
fi
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include libSSL 1.0.0 (Debian packages only)

if [ "$ARCHIVE_LIBSSL32" ]; then
	(
		ARCHIVE='ARCHIVE_LIBSSL32'
		extract_data_from "$ARCHIVE_LIBSSL32"
	)
	mkdir --parents "${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi
if [ "$ARCHIVE_LIBSSL64" ]; then
	(
		ARCHIVE='ARCHIVE_LIBSSL64'
		extract_data_from "$ARCHIVE_LIBSSL64"
	)
	mkdir --parents "${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Write launchers

PKG='PKG_BIN32'
write_launcher 'APP_MAIN'
case "$ARCHIVE" in
	('ARCHIVE_GOG_OLD0');;
	(*)
		PKG='PKG_BIN64'
		write_launcher 'APP_MAIN'
	;;
esac

# Build package

use_archive_specific_value 'PKG_BIN32_DEPS'
case "$ARCHIVE" in
	('ARCHIVE_GOG_OLD0')
		case "$OPTION_PACKAGE" in
			('arch')
				cat > "$postinst" <<- EOF
				if [ ! -e /usr/lib32/libjson.so.0 ] && [ -e /usr/lib32/libjson-c.so ] ; then
				    mkdir --parents "$PATH_GAME/$APP_MAIN_LIBS"
				    ln --symbolic /usr/lib32/libjson-c.so "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
				fi
				EOF
			;;
			('deb')
				cat > "$postinst" <<- EOF
				if [ ! -e /lib/i386-linux-gnu/libjson.so.0 ]; then
				    mkdir --parents "$PATH_GAME/$APP_MAIN_LIBS"
				    for file in\
				        libjson-c.so\
				        libjson-c.so.2\
				        libjson-c.so.3
				    do
				        if [ -e "/lib/i386-linux-gnu/\$file" ] ; then
				            ln --symbolic "/lib/i386-linux-gnu/\$file" "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
				            break
				        fi
				    done
				fi
				EOF
			;;
		esac
		cat > "$prerm" <<- EOF
		if [ -e "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0" ]; then
		    rm "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
		fi
		EOF
	;;
esac
write_metadata 'PKG_BIN32'
case "$ARCHIVE" in
	('ARCHIVE_GOG_OLD0');;
	(*)
		write_metadata 'PKG_BIN64'
	;;
esac
write_metadata 'PKG_L10N' 'PKG_DATA'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
