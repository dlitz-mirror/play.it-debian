#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Mortal Kombat 3
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210329.3

# Set game-specific variables

GAME_ID='mortal-kombat-3'
GAME_NAME='Mortal Kombat Ⅲ'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='setup_mortal_kombat3_2.0.0.2.exe'
ARCHIVE_GOG_0_MD5='e9703877b5bd2dfde5b2d65b8586aa6d'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_VERSION='1.0-gog2.0.0.2'
ARCHIVE_GOG_0_SIZE='87000'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/mortal_kombat_123'

ARCHIVE_GAME_MAIN_PATH='app/mk3'
ARCHIVE_GAME_MAIN_FILES='drivers image *.asg *.bat *.dat *.exe *.ftr *.ini *.mk3'

CONFIG_FILES='./*.ini'
DATA_FILES='./*.dat'

GAME_IMAGE='image/mk3.cue'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='mk3.exe'
APP_MAIN_ICON='app/goggame-1207667063.ico'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icons

icons_get_from_workdir 'APP_MAIN'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Ensure case consistency between the disk image table of contents and the actual filenames

DISK_IMAGE="${PKG_MAIN_PATH}${PATH_GAME}/${GAME_IMAGE}"

pattern='MK3\.GOG'
replacement='mk3.gog'
expression="s/${pattern}/${replacement}/"

pattern='Track'
replacement='track'
expression="${expression};s/${pattern}/${replacement}/g"

sed --in-place --expression="$expression" "$DISK_IMAGE"

# Write launchers

launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
