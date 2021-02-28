#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotlsashplay.it>
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
# Trine 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210228.1

# Set game-specific variables

GAME_ID='trine-2'
GAME_NAME='Trine 2'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0
ARCHIVE_HUMBLE_0'

ARCHIVE_GOG_1='gog_trine_2_complete_story_2.0.0.5.sh'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/trine_2_complete_story'
ARCHIVE_GOG_1_MD5='dd7126c1a6210e56fde20876bdb0a2ac'
ARCHIVE_GOG_1_VERSION='2.01.425-gog2.0.0.5'
ARCHIVE_GOG_1_SIZE='3700000'

ARCHIVE_GOG_0='gog_trine_2_complete_story_2.0.0.4.sh'
ARCHIVE_GOG_0_MD5='dae867bff938dde002eafcce0b72e5b4'
ARCHIVE_GOG_0_VERSION='2.01.425-gog2.0.0.4'
ARCHIVE_GOG_0_SIZE='3700000'

ARCHIVE_HUMBLE_0='trine2_complete_story_v2_01_build_425_humble_linux_full.zip'
ARCHIVE_HUMBLE_0_URL='https://www.humblebundle.com/store/trine-2-complete-story'
ARCHIVE_HUMBLE_0_MD5='82049b65c1bce6841335935bc05139c8'
ARCHIVE_HUMBLE_0_VERSION='2.01build425-humble141016'
ARCHIVE_HUMBLE_0_SIZE='3700000'

ARCHIVE_DOC0_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC1_DATA_PATH_HUMBLE='.'
ARCHIVE_DOC1_DATA_FILES='readme*'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='.'
ARCHIVE_GAME_BIN_FILES='bin lib'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='.'
ARCHIVE_GAME_DATA_FILES='data *.fbq trine2.png'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='lib/lib32'
APP_MAIN_EXE='bin/trine2_linux_launcher_32bit'
APP_MAIN_ICON='trine2.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc glu openal gtk2 vorbis alsa"

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

# Ensure availability of libPNG 1.2

case "$OPTION_PACKAGE" in
	('arch'|'gentoo')
		# Use package from official repositories
		PKG_BIN_DEPS_ARCH="$PKG_BIN_DEPS_ARCH lib32-libpng12"
		PKG_BIN_DEPS_GENTOO="$PKG_BIN_DEPS_GENTOO media-libs/libpng:1.2[abi_x86_32]"
	;;
	('deb')
		# Use archive provided by ./play.it
		ARCHIVE_OPTIONAL_LIBPNG32='libpng_1.2_32-bit.tar.gz'
		ARCHIVE_OPTIONAL_LIBPNG32_URL='https://downloads.dotslashplay.it/resources/libpng/'
		ARCHIVE_OPTIONAL_LIBPNG32_MD5='15156525b3c6040571f320514a0caa80'
		ARCHIVE_MAIN="$ARCHIVE"
		set_archive 'ARCHIVE_LIBPNG32' 'ARCHIVE_OPTIONAL_LIBPNG32'
		if [ "$ARCHIVE_LIBPNG32" ]; then
			extract_data_from "$ARCHIVE_LIBPNG32"
			mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
			mv "$PLAYIT_WORKDIR"/gamedata/* "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
			rm --recursive "$PLAYIT_WORKDIR/gamedata"
			ln --symbolic './libpng12.so.0.50.0' "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS/libpng12.so.0"
		else
			case "${LANG%_*}" in
				('fr')
					message='Archive introuvable : %s\n'
					message="$message"'La bibliothèque libPNG 1.2 ne sera pas incluse.\n'
					message="$message"'Cette archive peut être téléchargée depuis %s\n'
				;;
				('en'|*)
					message='Archive not found: %s\n'
					message="$message"'The libPNG 1.2 library will not be included.\n'
					message="$message"'This archive can be downloaded from %s\n'
				;;
			esac
			print_warning
			printf "$message" "$ARCHIVE_OPTIONAL_LIBPNG32" "$ARCHIVE_OPTIONAL_LIBPNG32_URL"
			printf '\n'
		fi
		ARCHIVE="$ARCHIVE_MAIN"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Set execution permissions on all binaries

find "${PKG_BIN_PATH}${PATH_GAME}/bin" -type f -exec chmod 755 '{}' +

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

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
