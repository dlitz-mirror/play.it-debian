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
# CrossCode - Demo
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200926.1

# Set game-specific variables

GAME_ID='crosscode-demo'
GAME_NAME='CrossCode - Demo'

ARCHIVES_LIST='
ARCHIVE_OFFICIAL_0
'

ARCHIVE_OFFICIAL_0='crosscode-demo.zip'
ARCHIVE_OFFICIAL_0_URL='https://www.cross-code.com/en/home'
ARCHIVE_OFFICIAL_0_MD5='22c54c8c415ecf056bd703dbed09c13d'
ARCHIVE_OFFICIAL_0_VERSION='0.7.1beta-crosscode'
ARCHIVE_OFFICIAL_0_SIZE='130000'
ARCHIVE_OFFICIAL_0_TYPE='zip'

ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='credits.html'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='crosscode-demo.exe ffmpegsumo.dll icudt.dll nw.pak'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='crosscode-demo.exe'
APP_MAIN_ICON='favicon.png'

PACKAGES_LIST='PKG_MAIN'

# glx is here because it seems nw can use regular OpenGL when swiftshader isn't present
PKG_MAIN_ARCH='32'
PKG_MAIN_DEPS='wine glx alsa'

# Store user data under a persistent path

DATA_DIRS="$DATA_DIRS ./userdata"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store user data under a persistent path
userdata_path_prefix="$WINEPREFIX/drive_c/users/$USER/Local Settings/Application Data/CrossCode/Local Storage"
userdata_path_persistent="$PATH_PREFIX/userdata"
if [ ! -h "$userdata_path_prefix" ]; then
	if [ -d "$userdata_path_prefix" ]; then
		# Migrate existing user data to the persistent path
		mv "$userdata_path_prefix"/* "$userdata_path_persistent"
		rmdir "$userdata_path_prefix"
	fi
	# Create link from prefix to persistent path
	mkdir --parents "$(dirname "$userdata_path_prefix")"
	ln --symbolic "$userdata_path_persistent" "$userdata_path_prefix"
fi'

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

# Extract game icons

(
	ARCHIVE='ARCHIVE_EXE'
	ARCHIVE_EXE="${PKG_MAIN_PATH}${PATH_GAME}/crosscode-demo.exe"
	ARCHIVE_EXE_TYPE='zip_unclean'
	extract_data_from "$ARCHIVE_EXE"
)
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
