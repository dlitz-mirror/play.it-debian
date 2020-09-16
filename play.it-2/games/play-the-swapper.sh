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
# The Swapper
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200812.7

# Set game-specific variables

GAME_ID='the-swapper'
GAME_NAME='The Swapper'

# find is used to delete some unwanted files related to Dropbox
SCRIPT_DEPS='find'

ARCHIVES_LIST='
ARCHIVE_HUMBLE_0'

ARCHIVE_HUMBLE_0='the-swapper-linux-1.24_1409159048.sh'
ARCHIVE_HUMBLE_0_URL='https://www.humblebundle.com/store/the-swapper'
ARCHIVE_HUMBLE_0_MD5='4f9627d245388edc320f61fae7cbd29f'
ARCHIVE_HUMBLE_0_SIZE='980000'
ARCHIVE_HUMBLE_0_VERSION='1.24-humble140404'
ARCHIVE_HUMBLE_0_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data/noarch'
ARCHIVE_DOC_DATA_FILES='README* Licences'

ARCHIVE_GAME_BIN32_PATH='data/noarch'
ARCHIVE_GAME_BIN32_FILES='lib/libfmodex.so lib/libmonosgen-2.0.so.0'

ARCHIVE_GAME_BIN64_PATH='data/noarch'
ARCHIVE_GAME_BIN64_FILES='lib64/libfmodex.so lib64/libmonosgen-2.0.so.0'

ARCHIVE_GAME_DATA_PATH='data/noarch'
ARCHIVE_GAME_DATA_FILES='data mono config.xml mainSettings.ini AdvanceMath.dll Antlr3.Runtime.dll C5.dll FarseerPhysics331.dll HackFlipcodeDecomposer.dll ImageManipulation.dll Jint.dll Lidgren.Network.dll MiniTK.dll MiniTK.dll.config MonoGame.Framework.dll Newtonsoft.Json.dll OptimusSwitcher.dll Poly2Tri.dll SDL2#.dll SDL2#.dll.config SteamManagedWrapper.dll Steamworks.NET.dll TargaImage.dll TrueEngine.dll TrueEngine.dll.config TheSwapper.exe TheSwapper.exe.config BugReporter.exe'

APP_MAIN_TYPE='mono'
APP_MAIN_LIBS_BIN32='lib'
APP_MAIN_LIBS_BIN64='lib64'
APP_MAIN_EXE='TheSwapper.exe'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID mono sdl2 sdl2_image"
PKG_BIN32_DEPS_DEB='libmono-posix4.0-cil, libmono-security4.0-cil, libmono-corlib4.5-cil, libopentk1.1-cil, libmono-system-configuration4.0-cil, libmono-system-core4.0-cil, libmono-system-data4.0-cil, libmono-system4.0-cil, libmono-system-drawing4.0-cil, libmono-system-numerics4.0-cil, libmono-system-runtime-serialization4.0-cil, libmono-system-security4.0-cil, libmono-system-xml4.0-cil, libmono-system-xml-linq4.0-cil'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"

# Optional icons pack

ARCHIVE_OPTIONAL_ICONS='the-swapper_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_MD5='cddcf271fb6eb10fba870aa91c30c410'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/resources/the-swapper/'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 32x32 48x48 128x128'

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

# Include optional icons pack

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
if [ -n "$ARCHIVE_ICONS" ]; then
	PKG='PKG_DATA'
	(
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
	organize_data 'ICONS' "$PATH_ICON_BASE"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
else
	###
	# TODO
	# This warning message should be provided by the library
	###
	case "${LANG%_*}" in
		('fr')
			message='Lʼarchive suivante nʼayant pas été fournie, lʼentrée de menu utilisera une icône générique : %s\n'
			message="$message"'Cette archive peut être téléchargée depuis %s\n'
		;;
		('en'|*)
			message='Due to the following archive missing, the menu entry will use a generic icon: %s\n'
			message="$message"'This archive can be downloaded from %s\n'
		;;
	esac
	print_warning
	printf "$message" "$ARCHIVE_OPTIONAL_ICONS" "$ARCHIVE_OPTIONAL_ICONS_URL"
	printf '\n'
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
find "$PLAYIT_WORKDIR/gamedata" \
	-name '*:com.dropbox.attributes:$DATA' \
	-delete
prepare_package_layout

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
