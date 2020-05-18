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
# The Elder Scrolls II: Daggerfall
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190327.1

# Set game-specific variables

GAME_ID='the-elder-scrolls-2-daggerfall'
GAME_NAME='The Elder Scrolls II: Daggerfall'

ARCHIVE_GOG='setup_the_elder_scrolls_ii_daggerfall_1.07_(28043).exe'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_elder_scrolls_iii_morrowind_goty_edition'
ARCHIVE_GOG_MD5='94acfb7acfe2242241d4355ada481d98'
ARCHIVE_GOG_SIZE='560000'
ARCHIVE_GOG_VERSION='1.07.213-gog28043'

ARCHIVE_GOG_OLD0='setup_tes_daggerfall_2.0.0.4.exe'
ARCHIVE_GOG_OLD0_MD5='68f1eb4f257d8da4c4eab2104770c49b'
ARCHIVE_GOG_OLD0_SIZE='580000'
ARCHIVE_GOG_OLD0_VERSION='1.07.213-gog2.0.0.4'

ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='*.pdf'
# Keep compatibility with old archives
ARCHIVE_DOC_MAIN_PATH_GOG_OLD0='app'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='*.cfg *.exe *.txt *.ini arena2 dagger.ico data *.bnk *.386 *.scr test*'
# Keep compatibility with old archives
ARCHIVE_GAME_MAIN_PATH_GOG_OLD0='app'

CONFIG_FILES='./*.cfg'
DATA_DIRS='./pics ./save0 ./save1 ./save2 ./save3 ./save4 ./save5'
DATA_FILES='./arena2/bio.dat ./arena2/copyfile.dat ./arena2/rumor.dat ./arena2/mapsave.sav ./arena2/*.DAT arena2/*.AMF'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='fall.exe'
APP_MAIN_OPTIONS='z.cfg'
APP_MAIN_ICON='dagger.ico'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'
# Easier upgrade from packages generated with pre-20190302.3 scripts
PKG_BIN_PROVIDE='the-elder-scrolls-2-daggerfall-data'

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

# Extract icons

icons_get_from_package 'APP_MAIN'

# Write launchers

launcher_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
