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
# Dark Reign 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200301.1

# Set game-specific variables

GAME_ID='dark-reign-2'
GAME_NAME='Dark Reign 2'

ARCHIVE_GOG='setup_dark_reign2_2.0.0.11.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/dark_reign_2'
ARCHIVE_GOG_MD5='9a3d10825507b73c4db178f9caea2406'
ARCHIVE_GOG_VERSION='1.3.882-gog2.0.0.11'
ARCHIVE_GOG_SIZE='450000'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='*.htm *.pdf *.rtf *.txt'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe *.inf library'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='missions mods music packs sides worlds'

CONFIG_FILES='./settings.cfg'
DATA_DIRS='./mods ./users'
DATA_FILES='./dr2.log'

APP_REGEDIT='dr2-cdkey.reg'
APP_WINETRICKS='win98'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='launcher.exe'
APP_MAIN_ICON='dr2.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks"

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

# Get game icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Work around prompt for CD-key

if [ "$DRY_RUN" -eq 0 ]; then
	cat > "${PKG_BIN_PATH}${PATH_GAME}/$APP_REGEDIT" <<- 'EOF'
	REGEDIT4
	[HKEY_LOCAL_MACHINE\Software\WON\CDKeys]
	"DarkReign2"=hex:56,c1,0c,ed,bb,61,40,19,99,3d,cd,6c,78,51,4c,5e
	EOF
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
