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
# A Boy and His Blob
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210712.6

# Set game-specific variables

GAME_ID='a-boy-and-his-blob'
GAME_NAME='A Boy and His Blob'

ARCHIVE_BASE_ZOOM_0='A Boy and His Blob.tar.gz'
ARCHIVE_BASE_ZOOM_0_MD5='4e56d18404f82a2c6f6489661df807c8'
ARCHIVE_BASE_ZOOM_0_SIZE='1300000'
ARCHIVE_BASE_ZOOM_0_VERSION='2016.04.21-zoom1'
ARCHIVE_BASE_ZOOM_0_URL='https://www.zoom-platform.com/product/a-boy-and-his-blob'

ARCHIVE_BASE_GOG_0='gog_a_boy_and_his_blob_2.1.0.2.sh'
ARCHIVE_BASE_GOG_0_MD5='7025963a3a26f838877374f72ce3760d'
ARCHIVE_BASE_GOG_0_TYPE='mojosetup'
ARCHIVE_BASE_GOG_0_SIZE='1300000'
ARCHIVE_BASE_GOG_0_VERSION='2016.04.21-gog2.1.0.2'
ARCHIVE_BASE_GOG_0_URL='https://www.gog.com/game/a_boy_and_his_blob'

ARCHIVE_GAME_BIN_PATH_ZOOM='A Boy And His Blob/game'
ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='Blob libfmod.so.7 libGLEW.so.1.10'

ARCHIVE_GAME_DATA_PATH_ZOOM='A Boy And His Blob/game'
ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='content'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='.'
APP_MAIN_EXE='Blob'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx libSDL2-2.0.so.0"

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

# Load icons archive if available

ARCHIVE_OPTIONAL_ICONS='a-boy-and-his-blob_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_MD5='2a555c1f6b02a45b8932c8e72a9c1dd6'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/resources/a-boy-and-his-blob/'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 32x32 48x48 64x64'

archive_initialize_optional \
	'ARCHIVE_ICONS' \
	'ARCHIVE_OPTIONAL_ICONS'
if [ -z "$ARCHIVE_ICONS" ]; then
	case "$ARCHIVE" in
		('ARCHIVE_BASE_GOG_'*)
			APP_MAIN_ICON='data/noarch/support/icon.png'
			message_fr='Lʼarchive suivante nʼayant pas été fournie, lʼicône spécifique à GOG sera utilisée au lieu de lʼicône originale : %s\n'
			message_en='Due to the following archive missing, the GOG-specific icon will be used instead of the original one: %s\n'
		;;
		(*)
			message_fr='Lʼarchive suivante nʼayant pas été fournie, lʼentrée de menu utilisera une icône générique : %s\n'
			message_en='Due to the following archive missing, the menu entry will use a generic icon: %s\n'
		;;
	esac
	message_fr="$message_fr"'Cette archive peut être téléchargée depuis %s\n'
	message_en="$message_en"'This archive can be downloaded from %s\n'
	case "${LANG%_*}" in
		('fr')
			message="$message_fr"
		;;
		('en'|*)
			message="$message_en"
		;;
	esac
	print_warning
	printf "$message" "$ARCHIVE_OPTIONAL_ICONS" "$ARCHIVE_OPTIONAL_ICONS_URL"
	printf '\n'
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "${PLAYIT_WORKDIR}/gamedata"
prepare_package_layout

# Get game icon

PKG='PKG_DATA'
if [ -n "$ARCHIVE_ICONS" ]; then
	(
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
	organize_data 'ICONS' "$PATH_ICON_BASE"
elif [ -n "$APP_MAIN_ICON" ]; then
	icons_get_from_workdir 'APP_MAIN'
fi

# Delete temporary files

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
