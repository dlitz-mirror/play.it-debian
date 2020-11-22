#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Risk of Rain
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201122.6

# Set game-specific variables

GAME_ID='risk-of-rain'
GAME_NAME='Risk of Rain'

ARCHIVES_LIST='
ARCHIVE_GOG_0
ARCHIVE_HUMBLE_0'

ARCHIVE_GOG_0='gog_risk_of_rain_2.1.0.5.sh'
ARCHIVE_GOG_0_MD5='34f8e1e2dddc6726a18c50b27c717468'
ARCHIVE_GOG_0_SIZE='180000'
ARCHIVE_GOG_0_VERSION='1.2.8-gog2.1.0.5'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/risk_of_rain'

ARCHIVE_HUMBLE_0='Risk_of_Rain_v1.3.0_DRM-Free_Linux_.zip'
ARCHIVE_HUMBLE_0_MD5='21eb80a7b517d302478c4f86dd5ea9a2'
ARCHIVE_HUMBLE_0_SIZE='100000'
ARCHIVE_HUMBLE_0_VERSION='1.3.0-humble160519'
ARCHIVE_HUMBLE_0_URL='https://www.humblebundle.com/store/risk-of-rain'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='.'
ARCHIVE_GAME_BIN_FILES='Risk_of_Rain'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='.'
ARCHIVE_GAME_DATA_FILES='assets'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Risk_of_Rain'
APP_MAIN_ICON='assets/icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glu openal libxrandr libcurl"

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

# Ensure availability of CURL_OPENSSL_3 symbol

ARCHIVE_OPTIONAL_LIBCURL3='libcurl3_7.60.0_32-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBCURL3_URL='https://downloads.dotslashplay.it/resources/libcurl/'
ARCHIVE_OPTIONAL_LIBCURL3_MD5='7206100f065d52de5a4c0b49644aa052'
ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_LIBCURL3' 'ARCHIVE_OPTIONAL_LIBCURL3'
if [ "$ARCHIVE_LIBCURL3" ]; then
	extract_data_from "$ARCHIVE_LIBCURL3"
	mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
	mv "$PLAYIT_WORKDIR"/gamedata/* "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
	ln --symbolic 'libcurl.so.4.5.0' "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS/libcurl.so.4"
else
	case "${LANG%_*}" in
		('fr')
			message='Archive introuvable : %s\n'
			message="$message"'La bibliothèque cURL fournissant le symbole CURL_OPENSSL_3 ne sera pas incluse.\n'
			message="$message"'Cette archive peut être téléchargée depuis %s\n'
		;;
		('en'|*)
			message='Archive not found: %s\n'
			message="$message"'The cURL library providing CURL_OPENSSL_3 symbol will not be included.\n'
			message="$message"'This archive can be downloaded from %s\n'
		;;
	esac
	print_warning
	printf "$message" "$ARCHIVE_OPTIONAL_LIBCURL3" "$ARCHIVE_OPTIONAL_LIBCURL3_URL"
	printf '\n'
fi
ARCHIVE="$ARCHIVE_MAIN"

# Ensure availability of libSSL 1.0.0

case "$OPTION_PACKAGE" in
	('arch'|'gentoo')
		# Use package from official repositories
		PKG_BIN_DEPS_ARCH="$PKG_BIN_DEPS_ARCH lib32-openssl-1.0"
		PKG_BIN_DEPS_GENTOO="$PKG_BIN_DEPS_GENTOO dev-libs/openssl-compat[abi_x86_32]"
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
			mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
			mv "$PLAYIT_WORKDIR"/gamedata/* "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
			rm --recursive "$PLAYIT_WORKDIR/gamedata"
		else
			case "${LANG%_*}" in
				('fr')
					message='Archive introuvable : %s\n'
					message="$message"'La bibliothèque libSSL 1.0.0 ne sera pas incluse.\n'
					message="$message"'Cette archive peut être téléchargée depuis %s\n'
				;;
				('en'|*)
					message='Archive not found: %s\n'
					message="$message"'The libSSL 1.0.0 library will not be included.\n'
					message="$message"'This archive can be downloaded from %s\n'
				;;
			esac
			print_warning
			printf "$message" "$ARCHIVE_OPTIONAL_LIBSSL32" "$ARCHIVE_OPTIONAL_LIBSSL32_URL"
			printf '\n'
		fi
		ARCHIVE="$ARCHIVE_MAIN"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
