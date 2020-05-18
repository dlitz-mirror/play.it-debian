#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, BetaRays
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
# Minecraft 4K
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190507.2

# Set game-specific variables

GAME_ID='minecraft-4k'
GAME_NAME='Minecraft 4K'

ARCHIVE_ARCHIVEORG='4K.exe'
ARCHIVE_ARCHIVEORG_URL='https://archive.org/details/Minecraft4K'
ARCHIVE_ARCHIVEORG_MD5='c566f5be102e1e1afc153690e47173e5'
ARCHIVE_ARCHIVEORG_VERSION='1.0-archiveorg180513'
ARCHIVE_ARCHIVEORG_SIZE='20'
ARCHIVE_ARCHIVEORG_TYPE='zip_unclean'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='M.class'

APP_MAIN_TYPE='java'
APP_MAIN_EXE='M'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='java'

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

launchers_write 'APP_MAIN'
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place --regexp-extended 's/^(java .*)-jar(.*)/\1\2/' "${PKG_MAIN_PATH}${PATH_BIN}/$GAME_ID"
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
