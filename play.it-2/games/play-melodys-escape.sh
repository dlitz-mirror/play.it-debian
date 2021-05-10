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
# Melodyʼs Escape
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201122.1

# Set game-specific variables

GAME_ID='melodys-escape'
GAME_NAME='Melodyʼs Escape'

SCRIPT_DEPS='xdelta3'

ARCHIVE_HUMBLE='Melodys_Escape_Linux.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/melodys-escape'
ARCHIVE_HUMBLE_MD5='4d463482418c2d9917c56df3bbde6eea'
ARCHIVE_HUMBLE_SIZE='60000'
ARCHIVE_HUMBLE_VERSION='1.0-humble160601'

ARCHIVE_REQUIRED_LIB_PATCHES='melodys-escape_lib-patches.tar.gz'
ARCHIVE_REQUIRED_LIB_PATCHES_MD5='6aee21776f44df0d927babcddfa3c386'
ARCHIVE_REQUIRED_LIB_PATCHES_URL='https://downloads.dotslashplay.it/games/melodys-escape/'

ARCHIVE_OPTIONAL_ICONS='melodys-escape_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_MD5='656fce13728d399e557fd72c3a6bc244'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/games/melodys-escape/'

ARCHIVE_OPTIONAL_LIB64='melodys-escape_lib64.tar.gz'
ARCHIVE_OPTIONAL_LIB64_MD5='a77c6b3acd5910bd874a1ca4b7d0c53c'
ARCHIVE_OPTIONAL_LIB64_URL='https://downloads.dotslashplay.it/games/melodys-escape/'

ARCHIVE_DOC_DATA_PATH="Melody's Escape"
ARCHIVE_DOC_DATA_FILES='Licenses README.txt'

ARCHIVE_GAME_BIN32_PATH="Melody's Escape"
ARCHIVE_GAME_BIN32_FILES='lib/libbass.so lib/libbassmix.so lib/libmojoshader.so BassPlugins/libbassflac.so'

ARCHIVE_GAME_BIN64_PATH='.'
ARCHIVE_GAME_BIN64_FILES='lib64/libbass.so lib64/libbassmix.so lib64/libmojoshader.so BassPlugins/libbassflac.so'

ARCHIVE_GAME_DATA_PATH="Melody's Escape"
ARCHIVE_GAME_DATA_FILES='BundledMusic Calibration Content Mods mono *.dll.config MelodysEscape.exe Bass.Net.Linux.dll FNA.dll FNA.dll.config MelodyEngine.dll MelodyReactor.dll tar-cs.dll'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 32x32 48x48 64x64 128x128 256x256'

APP_MAIN_TYPE='mono'
APP_MAIN_LIBS_BIN32='lib'
APP_MAIN_LIBS_BIN64='lib64'
APP_MAIN_EXE='MelodysEscape.exe'

PACKAGES_LIST='PKG_BIN32 PKG_DATA'
PACKAGES_LIST_LIB64='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID mono openal sdl2 sdl2_image alsa"
PKG_BIN32_DEPS_DEB='libmono-2.0-1, libmono-posix4.0-cil, libmono-security4.0-cil, libmono-system-configuration4.0-cil, libmono-system-core4.0-cil, libmono-system-data4.0-cil, libmono-system4.0-cil, libmono-system-drawing4.0-cil, libmono-system-runtime-serialization4.0-cil, libmono-system-security4.0-cil, libmono-system-xml4.0-cil'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"

# Load common functions

target_version='2.12'

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

# Load required archives

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_LIB_PATCHES' 'ARCHIVE_REQUIRED_LIB_PATCHES'
ARCHIVE="$ARCHIVE_MAIN"
if [ -z "$ARCHIVE_LIB_PATCHES" ]; then
	archive_set_error_not_found 'ARCHIVE_REQUIRED_LIB_PATCHES'
fi

# Load optional archives

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
set_archive 'ARCHIVE_LIB64' 'ARCHIVE_OPTIONAL_LIB64'
ARCHIVE="$ARCHIVE_MAIN"
if [ -n "$ARCHIVE_LIB64" ]; then
	PACKAGES_LIST="$PACKAGES_LIST_LIB64"
	# shellcheck disable=SC2086
	set_temp_directories $PACKAGES_LIST
fi

# Include optional icons pack

if [ -n "$ARCHIVE_ICONS" ]; then
	PKG='PKG_DATA'
	(
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
	organize_data 'ICONS' "$PATH_ICON_BASE"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Include optional 64-bit libraries

if [ -n "$ARCHIVE_LIB64" ]; then
	(
		ARCHIVE='ARCHIVE_LIB64'
		extract_data_from "$ARCHIVE_LIB64"
	)
	prepare_package_layout
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Patch shipped libraries, to ensure they work with system-provided Mono

(
	ARCHIVE='ARCHIVE_LIB_PATCHES'
	extract_data_from "$ARCHIVE_LIB_PATCHES"
)
for file in 'MelodyReactor.dll' 'MelodysEscape.exe'; do
	original_file="${PKG_DATA_PATH}${PATH_GAME}/${file}"
	patched_file="$original_file"
	patch="$PLAYIT_WORKDIR/gamedata/${file}.delta"
	xdelta3 decode -f -s "$original_file" "$patch" "$patched_file"
done
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN32'
launchers_write 'APP_MAIN'
if [ -n "$ARCHIVE_LIB64" ]; then
	PKG='PKG_BIN64'
	launchers_write 'APP_MAIN'
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

#print instructions

print_instructions

exit 0
