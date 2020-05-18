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
# Deponia 2 - Chaos on Deponia
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200215.1

# Set game-specific variables

GAME_ID='deponia-2'
GAME_NAME='Deponia 2 - Chaos on Deponia'

ARCHIVE_GOG='gog_deponia_2_chaos_on_deponia_2.1.0.3.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/deponia_2_chaos_on_deponia'
ARCHIVE_GOG_MD5='7aa1251741a532e4b9f908a3af0d8f2a'
ARCHIVE_GOG_SIZE='3200000'
ARCHIVE_GOG_VERSION='3.3.2351-gog2.1.0.3'

ARCHIVE_HUMBLE='Deponia2_DEB_Full_3.2.2342_Multi_Daedalic_ESD.tar.gz'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/chaos-on-deponia'
ARCHIVE_HUMBLE_MD5='e7a71d5b8a83b2c2393095256b03553b'
ARCHIVE_HUMBLE_SIZE='3100000'
ARCHIVE_HUMBLE_VERSION='3.2.2342-humble'

ARCHIVE_OPTIONAL_ICONS='deponia-2_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/resources/deponia-2/'
ARCHIVE_OPTIONAL_ICONS_MD5='4469f0e85881f0db2c266dcb6222717c'

ARCHIVE_DOC0_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC0_DATA_PATH_HUMBLE='Chaos on Deponia'
ARCHIVE_DOC0_DATA_FILES='documents version.txt'

ARCHIVE_DOC1_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC1_DATA_FILES_GOG='*'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='Chaos on Deponia'
ARCHIVE_GAME_BIN_FILES='config.ini Deponia2 libs64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='Chaos on Deponia'
ARCHIVE_GAME_DATA_FILES='characters data.vis lua scenes videos'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 32x32 48x48 256x256'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Deponia2'
APP_MAIN_LIBS='libs64'
APP_MAIN_ICON_GOG='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# Easier upgrade from packages generated with pre-20181119.2 scripts
PKG_DATA_PROVIDE='deponia-2-videos'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx openal"

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

# Load icons archive if available

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
case "$ARCHIVE" in
	('ARCHIVE_HUMBLE')
		set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
	;;
esac
prepare_package_layout

# Include game icon

PKG='PKG_DATA'
if [ "$ARCHIVE_ICONS" ]; then
	ARCHIVE='ARCHIVE_ICONS' \
		extract_data_from "$ARCHIVE_ICONS"
	organize_data 'ICONS' "$PATH_ICON_BASE"
else
	case "$ARCHIVE" in
		('ARCHIVE_GOG')
			use_archive_specific_value 'APP_MAIN_ICON'
			icons_get_from_workdir 'APP_MAIN'
		;;
	esac
fi
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
