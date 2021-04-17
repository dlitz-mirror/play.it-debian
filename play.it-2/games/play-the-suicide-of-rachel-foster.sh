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
# The Suicide of Rachel Foster
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210409.4

# Set game-specific variables

GAME_ID='the-suicide-of-rachel-foster'
GAME_NAME='The Suicide of Rachel Foster'

ARCHIVE_GOG='setup_the_suicide_of_rachel_foster_1.0.3d_(36448).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_suicide_of_rachel_foster'
ARCHIVE_GOG_MD5='b351509e1845cdd6d99e7e252dc27815'
ARCHIVE_GOG_SIZE='11000000'
ARCHIVE_GOG_VERSION='1.0.3d-gog36448'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_PART1='setup_the_suicide_of_rachel_foster_1.0.3d_(36448)-1.bin'
ARCHIVE_GOG_PART1_MD5='f5cca9cdf87ec5bc32800b30cf7223e3'
ARCHIVE_GOG_PART1_TYPE='innosetup'
ARCHIVE_GOG_PART2='setup_the_suicide_of_rachel_foster_1.0.3d_(36448)-2.bin'
ARCHIVE_GOG_PART2_MD5='5ff56895c2de3bf2d973e89982d7a7c8'
ARCHIVE_GOG_PART2_TYPE='innosetup'
ARCHIVE_GOG_PART3='setup_the_suicide_of_rachel_foster_1.0.3d_(36448)-3.bin'
ARCHIVE_GOG_PART3_MD5='1f71e3117575dfe51758986882bc0e28'
ARCHIVE_GOG_PART3_TYPE='innosetup'

ARCHIVE_GAME_BIN_PATH='tsorf'
ARCHIVE_GAME_BIN_FILES='tsorf.exe engine tsorf/binaries tsorf/plugins'

ARCHIVE_GAME_DATA_PATH='tsorf'
ARCHIVE_GAME_DATA_FILES='tsorf'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='tsorf/binaries/win64/overlook-win64-shipping.exe'
APP_MAIN_ICON='tsorf/binaries/win64/overlook-win64-shipping.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

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
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Store user data in persistent paths

CONFIG_DIRS="${CONFIG_DIRS} ./userdata/Config"
DATA_DIRS="${DATA_DIRS} ./userdata/SaveGames"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Store user data in persistent paths
userdata_path_prefix="$WINEPREFIX/drive_c/users/$USER/Local Settings/Application Data/Daedalic Entertainment GmbH/The Suicide of Rachel Foster/Saved"
userdata_path_persistent="$PATH_PREFIX/userdata"
mkdir --parents "$userdata_path_persistent"
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

# Enable dxvk patches in the WINE prefix

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Install dxvk on first launch
if [ ! -e dxvk_installed ]; then
	# Wait a bit to ensure there is no lingering WINE process
	sleep 1s

	if command -v dxvk-setup >/dev/null 2>&1; then
		dxvk-setup install --development
	else
		winetricks dxvk
	fi
	touch dxvk_installed
fi'
case "$OPTION_PACKAGE" in
	('deb')
		# Debian-based distributions should use repositories-provided dxvk
		# winetricks is used as a fallback for branches not having access to dxvk-setup
		if [ -n "$PKG_BIN_DEPS_DEB" ]; then
			PKG_BIN_DEPS_DEB="${PKG_BIN_DEPS_DEB}, dxvk-wine64-development | winetricks, dxvk | winetricks"
		else
			PKG_BIN_DEPS_DEB='dxvk-wine64-development | winetricks, dxvk | winetricks'
		fi
	;;
	(*)
		# Default is to use winetricks
		PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks"
	;;
esac

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
