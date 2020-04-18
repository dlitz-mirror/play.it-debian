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

script_version=20201003.2

# Set game-specific variables

GAME_ID='melodys-escape'
GAME_NAME='Melodyʼs Escape'

ARCHIVE_HUMBLE='Melodys_Escape_Linux.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/melodys-escape'
ARCHIVE_HUMBLE_MD5='4d463482418c2d9917c56df3bbde6eea'
ARCHIVE_HUMBLE_SIZE='60000'
ARCHIVE_HUMBLE_VERSION='1.0-humble160601'

ARCHIVE_OPTIONAL_ICONS='melodys-escape_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_MD5='656fce13728d399e557fd72c3a6bc244'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/resources/melodys-escape/'

ARCHIVE_DOC_DATA_PATH="Melody's Escape"
ARCHIVE_DOC_DATA_FILES='Licenses README.txt'

ARCHIVE_GAME_BIN_PATH="Melody's Escape"
ARCHIVE_GAME_BIN_FILES='MelodysEscape.bin.x86 lib *.dll FNA.dll.config *.so MelodysEscape.exe'

ARCHIVE_GAME_DATA_PATH="Melody's Escape"
ARCHIVE_GAME_DATA_FILES='BassPlugins BundledMusic Calibration Content Mods mono'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 32x32 48x48 64x64 128x128 256x256'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='lib'
APP_MAIN_PRERUN='# Work around terminfo Mono bug
# cf. https://github.com/mono/mono/issues/6752
export TERM="${TERM%-256color}"'
APP_MAIN_EXE='MelodysEscape.bin.x86'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++"

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

# Load optional archives

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
ARCHIVE="$ARCHIVE_MAIN"
if [ -n "$ARCHIVE_LIB64" ]; then
	PACKAGES_LIST="$PACKAGES_LIST_LIB64"
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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

#print instructions

print_instructions

exit 0
