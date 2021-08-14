#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotlashplay.it>
# Copyright (c)      2020, Emmanuel Gil Peyrot <linkmauve@linkmauve.fr>
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
# Pandemonium!
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201202.2

# Set game-specific variables

GAME_ID='pandemonium'
GAME_NAME='Pandemonium!'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='setup_pandemonium_2.0.0.15.exe'
ARCHIVE_GOG_0_MD5='dee53eb1c87be925d64e75ea01eca74f'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_VERSION='1.0-gog2.0.0.15'
ARCHIVE_GOG_0_SIZE='130000'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/pandemonium'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='pandy.exe charles.exe 3dfxspl.dll glide.dll libogg-0.dll libvorbis-0.dll libvorbisfile-3.dll sst1init.dll win32.dll xanlib.dll resource.cnf pandemonium.bat'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='jesters.pkg level21.pkg level653.pkg level663.pkg level673.pkg level683.pkg level75.pkg level76.pkg level77.pkg level96.pkg level97.pkg'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='pandy.exe'
APP_MAIN_ICON='app/gfw_high.ico'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine glx"

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
(
	# Skip this step in dry-run mode
	test $DRY_RUN -eq 1 && exit 0

	cd "$PLAYIT_WORKDIR"/gamedata/app
	mv pandy3.exe pandy.exe
	mv full3.cnf resource.cnf
)
prepare_package_layout

# Extract game icons

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'

# Clean up temporary files

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
