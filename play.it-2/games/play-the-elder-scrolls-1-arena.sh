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
# The Elder Scrolls: Arena
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200206.1

# Set game-specific variables

GAME_ID='the-elder-scrolls-1-arena'
GAME_NAME='The Elder Scrolls: Arena'

ARCHIVE_GOG='setup_tes_arena_2.0.0.5.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_elder_scrolls_iii_morrowind_goty_edition'
ARCHIVE_GOG_MD5='ca5a894aa852f9dbb3ede787e51ec828'
ARCHIVE_GOG_SIZE='130000'
ARCHIVE_GOG_VERSION='1.07-gog2.0.0.5'

ARCHIVE_DOC_MAIN_PATH='app'
ARCHIVE_DOC_MAIN_FILES='*.pdf readme.txt'

ARCHIVE_GAME0_MAIN_PATH='app'
ARCHIVE_GAME0_MAIN_FILES='*.cfg *.exe *.inf *.ini *.65 *.ad *.adv *.bak *.bnk *.bsa *.cel *.cif *.clr *.col *.cpy *.dat *.flc *.gld *.img *.lgt *.lst *.me *.mif *.mnu *.ntz *.opl *.rci *.txt *.voc *.xfm cityintr citytxt extra speech'

ARCHIVE_GAME1_MAIN_PATH='app/__support'
ARCHIVE_GAME1_MAIN_FILES='save'

GAME_IMAGE='.'
GAME_IMAGE_TYPE='cdrom'

DATA_DIRS='./save ./arena_cd'

APP_MAIN_TYPE='dosbox'
APP_MAIN_PRERUN='config -set cpu cycles=fixed 20000
d:'
APP_MAIN_EXE='acd.exe'
APP_MAIN_OPTIONS='-Ssbpdig.adv -IOS220 -IRQS7 -DMAS1 -Mgenmidi.adv -IOM330 -IRQM2 -DMAM1'
APP_MAIN_ICON='app/goggame-1435828982.ico'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'
# Easier upgrade from packages generated with pre-20190302.3 scripts
PKG_MAIN_PROVIDE='the-elder-scrolls-1-arena-data'

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

# Extract icons

icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
