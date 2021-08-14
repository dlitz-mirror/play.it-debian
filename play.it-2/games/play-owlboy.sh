#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Owlboy
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201026.2

# Set game-specific variables

SCRIPT_DEPS='find dos2unix'

GAME_ID='owlboy'
GAME_NAME='Owlboy'

ARCHIVES_LIST='
ARCHIVE_HUMBLE_0
ARCHIVE_MULTIARCH_HUMBLE_3
ARCHIVE_MULTIARCH_HUMBLE_2
ARCHIVE_MULTIARCH_HUMBLE_1
ARCHIVE_MULTIARCH_HUMBLE_0'

ARCHIVE_HUMBLE_0='owlboy-01302020-bin'
ARCHIVE_HUMBLE_0_MD5='0d8d67c79b9359ee4b79913b6b640465'
ARCHIVE_HUMBLE_0_TYPE='mojosetup'
ARCHIVE_HUMBLE_0_URL='https://www.humblebundle.com/store/owlboy'
ARCHIVE_HUMBLE_0_SIZE='550000'
ARCHIVE_HUMBLE_0_VERSION='1.3.7013.40718-humble200130'

ARCHIVE_MULTIARCH_HUMBLE_3='owlboy-03152019-bin'
ARCHIVE_MULTIARCH_HUMBLE_3_MD5='2966b183f43f220ade646cb3f7872c49'
ARCHIVE_MULTIARCH_HUMBLE_3_TYPE='mojosetup'
ARCHIVE_MULTIARCH_HUMBLE_3_SIZE='550000'
ARCHIVE_MULTIARCH_HUMBLE_3_VERSION='1.3.7013.40178-humble190325'

ARCHIVE_MULTIARCH_HUMBLE_2='owlboy-12292017.bin'
ARCHIVE_MULTIARCH_HUMBLE_2_MD5='c2e99502013c7d2529bc2aefb6416dcf'
ARCHIVE_MULTIARCH_HUMBLE_2_TYPE='mojosetup'
ARCHIVE_MULTIARCH_HUMBLE_2_SIZE='570000'
ARCHIVE_MULTIARCH_HUMBLE_2_VERSION='1.3.6564.30139-humble1'

ARCHIVE_MULTIARCH_HUMBLE_1='owlboy-11022017-bin'
ARCHIVE_MULTIARCH_HUMBLE_1_MD5='d3a1e4753a604431c58eb1ea26c35543'
ARCHIVE_MULTIARCH_HUMBLE_1_TYPE='mojosetup'
ARCHIVE_MULTIARCH_HUMBLE_1_SIZE='570000'
ARCHIVE_MULTIARCH_HUMBLE_1_VERSION='1.3.6515.19883-humble171102'

ARCHIVE_MULTIARCH_HUMBLE_0='owlboy-05232017-bin'
ARCHIVE_MULTIARCH_HUMBLE_0_MD5='f35fba69fadffbf498ca8a38dbceeac1'
ARCHIVE_MULTIARCH_HUMBLE_0_TYPE='mojosetup'
ARCHIVE_MULTIARCH_HUMBLE_0_SIZE='570000'
ARCHIVE_MULTIARCH_HUMBLE_0_VERSION='1.2.6382.15868-humble1'

ARCHIVE_DOC_DATA_PATH='data'
ARCHIVE_DOC_DATA_FILES='Linux.README'

ARCHIVE_GAME_BIN32_PATH='data'
ARCHIVE_GAME_BIN32_FILES='lib/libmojoshader.so lib/libXNAFileDialog.so'

ARCHIVE_GAME_BIN64_PATH='data'
ARCHIVE_GAME_BIN64_FILES='lib64/libmojoshader.so lib64/libXNAFileDialog.so'

ARCHIVE_GAME_DATA_PATH='data'
ARCHIVE_GAME_DATA_FILES='content monoconfig monomachineconfig Owlboy.bmp Owlboy.exe FNA.dll FNA.dll.config GamedevUtility.dll MoonSharp.Interpreter.dll SharpFont.dll SharpFont.dll.config TimSort.dll'

CONFIG_FILES='./content/localizations/*/speechbubbleconfig.ini ./content/fonts/*.ini'

APP_MAIN_TYPE='mono'
APP_MAIN_LIBS_BIN32='lib'
APP_MAIN_LIBS_BIN64='lib64'
APP_MAIN_EXE='Owlboy.exe'
APP_MAIN_ICON='Owlboy.bmp'

PACKAGES_LIST='PKG_DATA PKG_BIN64'
PACKAGES_LIST_MULTIARCH='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID mono glx libudev1 freetype libSDL2-2.0.so.0 sdl2_image"
PKG_BIN32_DEPS_ARCH='lib32-faudio'
PKG_BIN32_DEPS_DEB='libmono-corlib4.5-cil, libmono-posix4.0-cil, libmono-security4.0-cil, libmono-system4.0-cil, libmono-system-core4.0-cil, libmono-system-configuration4.0-cil, libmono-system-data4.0-cil, libmono-system-design4.0-cil, libmono-system-drawing4.0-cil, libmono-system-management4.0-cil, libmono-system-numerics4.0-cil, libmono-system-runtime-serialization4.0-cil, libmono-system-security4.0-cil, libmono-system-transactions4.0-cil, libmono-system-xml4.0-cil, libfaudio0'
PKG_BIN32_DEPS_GENTOO='app-emulation/faudio[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='faudio'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='app-emulation/faudio'

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

# Update list of packages to build, based on source archive

###
# TODO
# This should always be done by the library
###
use_archive_specific_value 'PACKAGES_LIST'
# shellcheck disable=SC2086
set_temp_directories $PACKAGES_LIST

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Convert .ini files to Unix-style line separators

if [ $DRY_RUN -eq 0 ]; then
	find "${PKG_DATA_PATH}${PATH_GAME}" -type f -name '*.ini' -exec dos2unix '{}' + > /dev/null 2>&1
fi

# Write launchers

PKG='PKG_BIN64'
launchers_write 'APP_MAIN'
case "$ARCHIVE" in
	('ARCHIVE_MULTIARCH'*)
		PKG='PKG_BIN32'
		launchers_write 'APP_MAIN'
	;;
esac

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
