#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
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
# Undertale
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210325.2

# Set game-specific variables

GAME_ID='undertale'
GAME_NAME='Undertale'

ARCHIVES_LIST='
ARCHIVE_GOG_0
ARCHIVE_GOG_OLDEXE_1
ARCHIVE_GOG_OLDEXE_2'

ARCHIVE_GOG_0='undertale_en_1_08_18328.sh'
ARCHIVE_GOG_0_MD5='b134d85dd8bf723a74498336894ca723'
ARCHIVE_GOG_0_TYPE='mojosetup'
ARCHIVE_GOG_0_SIZE='160000'
ARCHIVE_GOG_0_VERSION='1.08-gog18328'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/undertale'

ARCHIVE_GOG_OLDEXE_1='undertale_en_1_06_15928.sh'
ARCHIVE_GOG_OLDEXE_1_MD5='54f9275d3def027e9f3f65a61094a662'
ARCHIVE_GOG_OLDEXE_1_TYPE='mojosetup'
ARCHIVE_GOG_OLDEXE_1_SIZE='160000'
ARCHIVE_GOG_OLDEXE_1_VERSION='1.06-gog15928'

ARCHIVE_GOG_OLDEXE_0='gog_undertale_2.0.0.1.sh'
ARCHIVE_GOG_OLDEXE_0_MD5='e740df4e15974ad8c21f45ebe8426fb0'
ARCHIVE_GOG_OLDEXE_0_TYPE='mojosetup'
ARCHIVE_GOG_OLDEXE_0_SIZE='160000'
ARCHIVE_GOG_OLDEXE_0_VERSION='1.001-gog2.0.0.1'

ARCHIVE_DOC_PATH='data/noarch/docs'
ARCHIVE_DOC_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='runner'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='assets'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='runner'
APP_MAIN_ICON='assets/icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc libstdc++ glx openal libxrandr glu"
PKG_BIN_DEPS_ARCH='lib32-libxext lib32-libx11'
PKG_BIN_DEPS_DEB='libxext6, libx11-6'
PKG_BIN_DEPS_GENTOO='x11-libs/libXext[abi_x86_32] x11-libs/libX11[abi_x86_32]'

# Keep compatibility with old archives

ARCHIVE_GAME_BIN_FILES_OLDEXE='UNDERTALE'
APP_MAIN_EXE_OLDEXE='UNDERTALE'

# Work around Mesa-related startup crash
# cf. https://gitlab.freedesktop.org/mesa/mesa/issues/1310

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Work around Mesa-related startup crash
# cf. https://gitlab.freedesktop.org/mesa/mesa/issues/1310
export radeonsi_sync_compile=true'

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

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

PKG='PKG_BIN'
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
