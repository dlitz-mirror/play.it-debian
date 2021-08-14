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
# Beyond Good and Evil
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210520.1

# Set game-specific variables

GAME_ID='beyond-good-and-evil'
GAME_NAME='Beyond Good and Evil'

ARCHIVE_BASE_0='setup_beyond_good_and_evil_2.1.0.9.exe'
ARCHIVE_BASE_0_MD5='fdfa4b94cf02e24523b01c9d54568482'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_VERSION='1.0-gog2.1.0.9'
ARCHIVE_BASE_0_SIZE='2200000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/beyond_good_and_evil'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='manual.pdf readme.txt'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.dll *.exe'

ARCHIVE_GAME0_BIN_PATH='sys'
ARCHIVE_GAME0_BIN_FILES='eax.dll'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='bgemakingof.bik jade.spe sally_clean.bf'

DATA_FILES='./sally.idx ./*.sav'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='run.exe'
APP_MAIN_ICON='bge.exe'

APP_SETTINGS_ID="${GAME_ID}_settings"
APP_SETTINGS_NAME="${GAME_NAME} - settings"
APP_SETTINGS_CAT='Settings'
APP_SETTINGS_TYPE='wine'
APP_SETTINGS_EXE='settingsapplication.exe'
APP_SETTINGS_ICON='settingsapplication.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine glx"

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract game icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_SETTINGS'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Set required registry key

registry_file='registry-dumps/init.reg'
registry_file_path="${PKG_BIN_PATH}${PATH_GAME}/${registry_file}"

APP_REGEDIT="${APP_REGEDIT} ${registry_file}"

mkdir --parents "$(dirname "$registry_file_path")"
cat > "$registry_file_path" << EOF
REGEDIT4

[HKEY_LOCAL_MACHINE\\Software\\Ubisoft\\Beyond Good & Evil]
"Install path"="C:\\\\${GAME_ID}"
EOF

# Use persistent storage for game settings

SETTINGS_REGISTRY_KEY='HKEY_CURRENT_USER\Software\Ubisoft\Beyond Good & Evil\settingsapplication.INI'
SETTINGS_REGISTRY_DUMP='registry-dumps/settings.reg'

CONFIG_DIRS="${CONFIG_DIRS} ./$(dirname "$SETTINGS_REGISTRY_DUMP")"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN

# Set path for persistent dump of game settings
SETTINGS_REGISTRY_KEY='$SETTINGS_REGISTRY_KEY'
SETTINGS_REGISTRY_DUMP='$SETTINGS_REGISTRY_DUMP'"
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'

# Dump game settings
regedit -E "$SETTINGS_REGISTRY_DUMP" "$SETTINGS_REGISTRY_KEY"'
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Load dump of game settings
if [ -e "$SETTINGS_REGISTRY_DUMP" ]; then
	wine regedit.exe "$SETTINGS_REGISTRY_DUMP"
fi'
APP_SETTINGS_PRERUN="$APP_MAIN_PRERUN"
APP_SETTINGS_POSTRUN="$APP_MAIN_POSTRUN"

# Automatically spawn game settings window on first launch

case "$OPTION_PREFIX" in
	('/usr'|'/usr/local')
		SETTINGS_CMD="$APP_SETTINGS_ID"
	;;
	(*' '*)
		SETTINGS_CMD="'${PATH_BIN}/${APP_SETTINGS_ID}'"
	;;
	(*)
		SETTINGS_CMD="${PATH_BIN}/${APP_SETTINGS_ID}"
	;;
esac

APP_MAIN_PRERUN="$APP_MAIN_PRERUN

# Automatically spawn game settings window on first launch
if [ ! -e \"\$SETTINGS_REGISTRY_DUMP\" ]; then
	$SETTINGS_CMD
	exit 0
fi"

# Hide EAX library from the game
# This helps avoiding some sound issues
# The library should still be available to the settings application

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Hide EAX library from the game
# This helps avoiding some sound issues
rm --force eax.dll'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_SETTINGS'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
