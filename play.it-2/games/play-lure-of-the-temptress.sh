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
# Lure of the Temptress
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200221.2

# Set game-specific variables

GAME_ID='lure-of-the-temptress'
GAME_NAME='Lure of the Temptress'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR'

ARCHIVE_GOG_EN='lure_of_the_temptress_en_gog_2_20099.sh'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/lure_of_the_temptress'
ARCHIVE_GOG_EN_TYPE='mojosetup'
ARCHIVE_GOG_EN_MD5='0882be47bf6dd9d619726b04fe4fb95c'
ARCHIVE_GOG_EN_SIZE='94000'
ARCHIVE_GOG_EN_VERSION='1.1-gog20099'

ARCHIVE_GOG_FR='lure_of_the_temptress_fr_gog_2_20099.sh'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/lure_of_the_temptress'
ARCHIVE_GOG_FR_TYPE='mojosetup'
ARCHIVE_GOG_FR_MD5='c890f929d3e3932915d0214fa451eb7e'
ARCHIVE_GOG_FR_SIZE='94000'
ARCHIVE_GOG_FR_VERSION='1.1-gog20099'

ARCHIVE_DOC0_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC0_MAIN_FILES='*.txt'

ARCHIVE_DOC1_MAIN_PATH_GOG_EN='data/noarch/docs/english'
# There is no French manual in the archive; fall back to English one instead
ARCHIVE_DOC1_MAIN_PATH_GOG_FR='data/noarch/docs/english'
ARCHIVE_DOC1_MAIN_FILES='*.pdf *.txt'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='*.vga'

APP_MAIN_TYPE='scummvm'
APP_MAIN_SCUMMID='lure'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="$GAME_ID"
PKG_MAIN_ID_GOG_EN="${GAME_ID}-en"
PKG_MAIN_ID_GOG_FR="${GAME_ID}-fr"
PKG_MAIN_PROVIDE="$PKG_MAIN_ID"
PKG_MAIN_DEPS='scummvm'

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
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get icon

icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

launchers_write 'APP_MAIN'

# Build package

if [ "$OPTION_PACKAGE" = 'deb' ]; then
	file="$PKG_MAIN_PATH/etc/apt/preferences.d/$GAME_ID"
	mkdir --parents "${file%/*}"
	cat > "$file" <<- EOF
	Package: $GAME_ID
	Pin: release o=Debian
	Pin-Priority: -1
	EOF
fi
cat > "$postinst" << EOF
if [ ! -f "$PATH_GAME/lure.dat" ]; then
	ln --symbolic /usr/share/scummvm/lure.dat "$PATH_GAME"
fi
EOF
cat > "$prerm" << EOF
if [ -f "$PATH_GAME/lure.dat" ]; then
	rm "$PATH_GAME/lure.dat"
fi
EOF
write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
