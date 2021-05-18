#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2020-2021, ahub
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
# Devil Daggers
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210518.8

# Set game-specific variables

GAME_ID='devil-daggers' # used for package name
GAME_NAME='Devil Daggers' # used for menu display


ARCHIVE_BASE_GOG_1='devil_daggers_v3_1_45183.sh'
ARCHIVE_BASE_GOG_1_URL='https://www.gog.com/game/devil_daggers'
ARCHIVE_BASE_GOG_1_MD5='2276b69f73738a0bad313a6e442558f4'
ARCHIVE_BASE_GOG_1_SIZE='460000' 
ARCHIVE_BASE_GOG_1_TYPE='mojosetup_unzip'
ARCHIVE_BASE_GOG_1_VERSION='3.1-gog45183' 

ARCHIVE_BASE_GOG_0='devil_daggers_en_update_1_20080.sh'
ARCHIVE_BASE_GOG_0_URL='https://www.gog.com/game/devil_daggers'
ARCHIVE_BASE_GOG_0_MD5='cf92f20e5a1662e9585fa500608ebdd1'
ARCHIVE_BASE_GOG_0_SIZE='420000' # rounded up 
ARCHIVE_BASE_GOG_0_TYPE='mojosetup_unzip'
ARCHIVE_BASE_GOG_0_VERSION='3.0-gog20080' # get that from the filename gameVersion-providerVersion

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

# dd/  default-44100.mhr  default-48000.mhr  devildaggers  lib64/  res/
ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='devildaggers'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='default-44100.mhr  default-48000.mhr res core dd'

DATA_FILES='error_log.txt'

APP_MAIN_TYPE='native'
APP_MAIN_ICON='data/noarch/support/icon.png'
APP_MAIN_EXE='devildaggers' 

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc libstdc++ glx libopenal.so.1 libX11.so.6"

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

# Ensure availability of CURL_OPENSSL_3 symbol

PKG='PKG_BIN'
ARCHIVE_OPTIONAL_LIBCURL3='libcurl3_7.52.1_64-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBCURL3_URL='https://downloads.dotslashplay.it/resources/libcurl/'
ARCHIVE_OPTIONAL_LIBCURL3_MD5='e276dd3620c31617baace84dfa3dca21'
archive_initialize_optional 'ARCHIVE_LIBCURL3' \
	'ARCHIVE_OPTIONAL_LIBCURL3'
if [ "$ARCHIVE_LIBCURL3" ]; then
	(
		ARCHIVE='ARCHIVE_LIBCURL3'
		extract_data_from "$ARCHIVE_LIBCURL3"
	)
	mkdir --parents "$(package_get_path "$PKG")${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
	mv "$PLAYIT_WORKDIR"/gamedata/* "$(package_get_path "$PKG")${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
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
