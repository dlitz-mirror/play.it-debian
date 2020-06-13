#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Baldurʼs Gate - Enhanced Edition
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200610.2

# Set game-specific variables

GAME_ID='baldurs-gate-1-enhanced-edition'
GAME_NAME='Baldurʼs Gate - Enhanced Edition'

ARCHIVES_LIST='ARCHIVE_GOG ARCHIVE_GOG_PRE25_OLD2 ARCHIVE_GOG_PRE25_OLD1 ARCHIVE_GOG_PRE25_OLD0'

ARCHIVE_GOG='baldur_s_gate_enhanced_edition_en_2_5_23121.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/baldurs_gate_enhanced_edition'
ARCHIVE_GOG_MD5='853f6e66db6cc5a4df0f72d23d65fcf7'
ARCHIVE_GOG_SIZE='3300000'
ARCHIVE_GOG_VERSION='2.5.17.0-gog23121'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_PRE25_OLD2='baldur_s_gate_enhanced_edition_en_2_3_67_3_20146.sh'
ARCHIVE_GOG_PRE25_OLD2_MD5='4d08fe21fcdeab51624fa2e0de2f5813'
ARCHIVE_GOG_PRE25_OLD2_SIZE='3200000'
ARCHIVE_GOG_PRE25_OLD2_VERSION='2.3.67.3-gog20146'
ARCHIVE_GOG_PRE25_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_PRE25_OLD1='gog_baldur_s_gate_enhanced_edition_2.5.0.9.sh'
ARCHIVE_GOG_PRE25_OLD1_MD5='224be273fd2ec1eb0246f407dda16bc4'
ARCHIVE_GOG_PRE25_OLD1_SIZE='3200000'
ARCHIVE_GOG_PRE25_OLD1_VERSION='2.3.67.3-gog2.5.0.9'

ARCHIVE_GOG_PRE25_OLD0='gog_baldur_s_gate_enhanced_edition_2.5.0.7.sh'
ARCHIVE_GOG_PRE25_OLD0_MD5='37ece59534ca63a06f4c047d64b82df9'
ARCHIVE_GOG_PRE25_OLD0_SIZE='3200000'
ARCHIVE_GOG_PRE25_OLD0_VERSION='2.3.67.3-gog2.5.0.7'

ARCHIVE_OPTIONAL_ICONS='baldurs-gate-1-enhanced-edition_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/resources/baldurs-gate-1-enhanced-edition/'
ARCHIVE_OPTIONAL_ICONS_MD5='58401cf80bc9f1a9e9a0896f5d74b02a'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='BaldursGate'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='BaldursGate64'

ARCHIVE_GAME_L10N_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_FILES='lang'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='movies music chitin.key Manuals scripts data engine.lua'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 24x42 32x32 48x48 64x64 256x256'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='BaldursGate'
APP_MAIN_EXE_BIN64='BaldursGate64'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_L10N PKG_DATA'
# Keep compatibility with old archives
PACKAGES_LIST_GOG_PRE25='PKG_BIN32 PKG_L10N PKG_DATA'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_DESCRIPTION='localizations'
# Easier upgrade from packages generated with pre-20180926.3 scripts
PKG_L10N_PROVIDE='baldurs-gate-enhanced-edition-l10n'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# Easier upgrade from packages generated with pre-20180926.3 scripts
PKG_DATA_PROVIDE='baldurs-gate-enhanced-edition-data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_L10N_ID $PKG_DATA_ID glibc libstdc++ glx openal libxrandr alsa xcursor"
# Easier upgrade from packages generated with pre-20180926.3 scripts
PKG_BIN32_PROVIDE='baldurs-gate-enhanced-edition'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
# Easier upgrade from packages generated with pre-20180926.3 scripts
PKG_BIN64_PROVIDE='baldurs-gate-enhanced-edition'

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

# Set packages list based on source archive

use_archive_specific_value 'PACKAGES_LIST'
# shellcheck disable=SC2086
set_temp_directories $PACKAGES_LIST

# Load icons archive if available

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
ARCHIVE="$ARCHIVE_MAIN"

# Ensure availability of 32-bit libssl.so.1.0.0

case "$OPTION_PACKAGE" in
	('arch')
		# Use package from official repositories
		PKG_BIN32_DEPS_ARCH="$PKG_BIN32_DEPS_ARCH lib32-openssl-1.0"
	;;
	('deb')
		# Use archive provided by ./play.it
		ARCHIVE_OPTIONAL_LIBSSL32='libssl_1.0.0_32-bit.tar.gz'
		ARCHIVE_OPTIONAL_LIBSSL32_URL='https://downloads.dotslashplay.it/resources/libssl/'
		ARCHIVE_OPTIONAL_LIBSSL32_MD5='9443cad4a640b2512920495eaf7582c4'
		ARCHIVE_MAIN="$ARCHIVE"
		set_archive 'ARCHIVE_LIBSSL32' 'ARCHIVE_OPTIONAL_LIBSSL32'
		if [ "$ARCHIVE_LIBSSL32" ]; then
			extract_data_from "$ARCHIVE_LIBSSL32"
			mkdir --parents "${PKG_BIN32_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
			mv "$PLAYIT_WORKDIR"/gamedata/* "${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
			rm --recursive "$PLAYIT_WORKDIR/gamedata"
		else
			case "${LANG%_*}" in
				('fr')
					message='Lʼarchive suivante nʼayant pas été fournie, libssl.so.1.0.0 ne sera pas inclus dans les paquets : %s\n'
					message="$message"'Cette archive peut être téléchargée depuis %s\n'
				;;
				('en'|*)
					message='Due to the following archive missing, the packages will not include libssl.so.1.0.0: %s\n'
					message="$message"'This archive can be downloaded from %s\n'
				;;
			esac
			print_warning
			printf "$message" "$ARCHIVE_OPTIONAL_LIBSSL32" "$ARCHIVE_OPTIONAL_LIBSSL32_URL"
			printf '\n'
		fi
		ARCHIVE="$ARCHIVE_MAIN"
	;;
	('gentoo')
		# Use package from official repositories
		PKG_BIN32_DEPS_GENTOO="$PKG_BIN32_DEPS_GENTOO dev-libs/openssl-compat[abi_x86_32]"
	;;
	(*)
		# Unsupported package type, throw an error
		liberror 'OPTION_PACKAGE' "$0"
	;;
esac

# Ensure availability of 64-bit libssl.so.1.0.0
# This library is not required for the older archives only providing 32-bit binaries

if [ -z "${PACKAGES_LIST##*PKG_BIN64*}" ]; then
	case "$OPTION_PACKAGE" in
		('arch')
			# Use package from official repositories
			PKG_BIN64_DEPS_ARCH="$PKG_BIN64_DEPS_ARCH openssl-1.0"
		;;
		('deb')
			# Use archive provided by ./play.it
			ARCHIVE_OPTIONAL_LIBSSL64='libssl_1.0.0_64-bit.tar.gz'
			ARCHIVE_OPTIONAL_LIBSSL64_URL='https://downloads.dotslashplay.it/resources/libssl/'
			ARCHIVE_OPTIONAL_LIBSSL64_MD5='89917bef5dd34a2865cb63c2287e0bd4'
			ARCHIVE_MAIN="$ARCHIVE"
			set_archive 'ARCHIVE_LIBSSL64' 'ARCHIVE_OPTIONAL_LIBSSL64'
			if [ "$ARCHIVE_LIBSSL64" ]; then
				extract_data_from "$ARCHIVE_LIBSSL64"
				mkdir --parents "${PKG_BIN64_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
				mv "$PLAYIT_WORKDIR"/gamedata/* "${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
				rm --recursive "$PLAYIT_WORKDIR/gamedata"
			else
				case "${LANG%_*}" in
					('fr')
						message='Lʼarchive suivante nʼayant pas été fournie, libssl.so.1.0.0 ne sera pas inclus dans les paquets : %s\n'
						message="$message"'Cette archive peut être téléchargée depuis %s\n'
					;;
					('en'|*)
						message='Due to the following archive missing, the packages will not include libssl.so.1.0.0: %s\n'
						message="$message"'This archive can be downloaded from %s\n'
					;;
				esac
				print_warning
				printf "$message" "$ARCHIVE_OPTIONAL_LIBSSL64" "$ARCHIVE_OPTIONAL_LIBSSL64_URL"
				printf '\n'
			fi
			ARCHIVE="$ARCHIVE_MAIN"
		;;
		('gentoo')
			# Use package from official repositories
			PKG_BIN64_DEPS_GENTOO="$PKG_BIN64_DEPS_GENTOO dev-libs/openssl-compat"
		;;
		(*)
			# Unsupported package type, throw an error
			liberror 'OPTION_PACKAGE' "$0"
		;;
	esac
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icons

PKG='PKG_DATA'
if [ "$ARCHIVE_ICONS" ]; then
	ARCHIVE_MAIN="$ARCHIVE"
	ARCHIVE='ARCHIVE_ICONS'
	extract_data_from "$ARCHIVE_ICONS"
	ARCHIVE="$ARCHIVE_MAIN"
	organize_data 'ICONS' "$PATH_ICON_BASE"
else
	icons_get_from_workdir 'APP_MAIN'
fi
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN32'
launchers_write 'APP_MAIN'
case "$ARCHIVE" in
	('ARCHIVE_GOG_PRE25'*)
		# No 64-bit binary provided
	;;
	(*)
		PKG='PKG_BIN64'
		launchers_write 'APP_MAIN'
	;;
esac

# Build package

case "$ARCHIVE" in
	('ARCHIVE_GOG_PRE25'*)
		# Old 32-bit version depends on libjson.so.0
		PKG_BIN32_DEPS="$PKG_BIN32_DEPS json"
		case "$OPTION_PACKAGE" in
			('arch'|'gentoo')
				LIB_PATH='/usr/lib32'
			;;
			('deb')
				LIB_PATH='/lib/i386-linux-gnu'
			;;
			(*)
				# Unsupported package type, throw an error
				liberror 'OPTION_PACKAGE' "$0"
			;;
		esac
		cat > "$postinst" <<- EOF
		if \
		    [ ! -e "$LIB_PATH/libjson.so.0" ] && \
		    [ ! -e "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0" ]
		then
		    for file in \
		        libjson-c.so \
		        libjson-c.so.2 \
		        libjson-c.so.3
		    do
		        if [ -e "$LIB_PATH/\$file" ] ; then
		            mkdir --parents "$PATH_GAME/${APP_MAIN_LIBS:=libs}"
		            ln --symbolic "$LIB_PATH/\$file" "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
		            break
		        fi
		    done
		fi
		EOF
		cat > "$prerm" <<- EOF
		if [ -e "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0" ]; then
		    rm "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
		fi
		EOF
		write_metadata 'PKG_BIN32'
		write_metadata 'PKG_L10N' 'PKG_DATA'
	;;
	(*)
		write_metadata
	;;
esac
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
