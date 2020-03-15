#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Gobliins 2: The Prince Buffoon
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200214.1

# Set game-specific variables

GAME_ID='gobliins-2'
GAME_NAME='Gobliins 2: The Prince Buffoon'

ARCHIVE_GOG='setup_gobliins_2_-_the_prince_buffoon_1.02_(20270).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/gobliiins_pack'
ARCHIVE_GOG_MD5='3607f4ab042fea51e3b6544775955701'
ARCHIVE_GOG_TYPE='innosetup1.7'
ARCHIVE_GOG_SIZE='110000'
ARCHIVE_GOG_VERSION='1.02-gog20270'

ARCHIVE_GOG_OLD0='setup_gobliiins2_2.1.0.63.exe'
ARCHIVE_GOG_OLD0_MD5='0baf2ce55d00fce9af4c98848e88d7dc'
ARCHIVE_GOG_OLD0_SIZE='100000'
ARCHIVE_GOG_OLD0_VERSION='1.02-gog2.1.0.63'

ARCHIVE_GAME_DATA_DISK_PATH='.'
ARCHIVE_GAME_DATA_DISK_FILES='gobnew.lic intro.stk track1.mp3'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_DISK_PATH_GOG_OLD0='app'

ARCHIVE_GAME_DATA_FLOPPY_PATH='fdd'
ARCHIVE_GAME_DATA_FLOPPY_FILES='*'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_FLOPPY_PATH_GOG_OLD0='app/fdd'

ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='*.pdf'
# Keep compatibility with old archives
ARCHIVE_DOC_MAIN_PATH_GOG_OLD0='app'

APP_MAIN_TYPE='scummvm'
APP_MAIN_SCUMMID='gob'
APP_MAIN_ICON='goggame-1207662293.ico'
# Keep compatibility with old archives
APP_MAIN_ICON_GOG_OLD0='app/goggame-1207662293.ico'

PACKAGES_LIST='PKG_MAIN PKG_DATA_DISK PKG_DATA_FLOPPY'

PKG_DATA_ID="${GAME_ID}-data"

PKG_DATA_DISK_ID="${PKG_DATA_ID}-disk"
PKG_DATA_DISK_PROVIDE="$PKG_DATA_ID"
PKG_DATA_DISK_DESCRIPTION='data - CD-ROM version'

PKG_DATA_FLOPPY_ID="${PKG_DATA_ID}-floppy"
PKG_DATA_FLOPPY_PROVIDE="$PKG_DATA_ID"
PKG_DATA_FLOPPY_DESCRIPTION='data - floppy version'

PKG_MAIN_DEPS="$PKG_DATA_ID scummvm"

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get game icon

PKG='PKG_MAIN'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_MAIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

case "${LANG%_*}" in
	('fr')
		version_string='version %s :'
		version_disk='CD-ROM'
		version_floppy='disquette'
	;;
	('en'|*)
		version_string='%s version:'
		version_disk='CD-ROM'
		version_floppy='Floppy'
	;;
esac
printf '\n'
# shellcheck disable=SC2059
printf "$version_string" "$version_disk"
print_instructions 'PKG_DATA_DISK' 'PKG_MAIN'
# shellcheck disable=SC2059
printf "$version_string" "$version_floppy"
print_instructions 'PKG_DATA_FLOPPY' 'PKG_MAIN'

exit 0
