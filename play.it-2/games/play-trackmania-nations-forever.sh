#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# TrackMania Nations Forever
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201202.13

# Set game-specific variables

SCRIPT_DEPS='innoextract'

GAME_ID='trackmania-nations-forever'
GAME_NAME='TrackMania Nations Forever'

ARCHIVES_LIST='
ARCHIVE_TRACKMANIA_0'

###
# TODO
# We need a new variable ARCHIVE_xxx_EXTRACTOR to force a given extractor.
# Here it would be something similar to:
# ARCHIVE_TRACKMANIA_0_EXTRACTOR='bsdtar'
# When ARCHIVE_xxx_EXTRACTOR is set, ARCHIVE_xxx_TYPE would be optional.
###
ARCHIVE_TRACKMANIA_0='tmnationsforever_setup.exe'
ARCHIVE_TRACKMANIA_0_MD5='2a36d70989f94ba9369993749ff20640'
ARCHIVE_TRACKMANIA_0_TYPE='mojosetup' # Sorry, this is a PE file and I just want it to be extracted with bsdtar.
ARCHIVE_TRACKMANIA_0_VERSION='2.11.26-1'
ARCHIVE_TRACKMANIA_0_SIZE='520000'
ARCHIVE_TRACKMANIA_0_URL='https://trackmaniaforever.com/nations/'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='binkw32.dll openal32.dll thumbgbx.dll thumbgbx.tlb tmforever.exe tmforeverlauncher.exe wrap_oal.dll'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='gamedata packs tmforever.map gbx.ico launchicon.png nadeo.ini'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='tmforeverlauncher.exe'
APP_MAIN_ICON='launchicon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine glx"

# Store game progress and configuration in persistent paths

DATA_DIRS="$DATA_DIRS ./userdata"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store game progress and configuration in persistent paths
data_path_prefix="$WINEPREFIX/drive_c/users/$USER/My Documents/TmForever"
data_path_persistent="$PATH_PREFIX/userdata"
if [ ! -h "$data_path_prefix" ]; then
	if [ -d "$data_path_prefix" ]; then
		# Migrate existing data to the persistent path
		mv "$data_path_prefix"/* "$data_path_persistent"
		rmdir "$data_path_prefix"
	fi
	# Create link from prefix to persistent path
	mkdir --parents "$(dirname "$data_path_prefix")"
	ln --symbolic "$data_path_persistent" "$data_path_prefix"
fi'

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

ARCHIVE_INNER="$PLAYIT_WORKDIR/gamedata/TmNationsForever_Setup_Tmp.exe"
ARCHIVE_INNER_TYPE='innosetup'
(
	ARCHIVE='ARCHIVE_INNER'
	extract_data_from "$ARCHIVE_INNER"
	if [ $DRY_RUN -eq 0 ]; then
		rm "$ARCHIVE_INNER"
	fi
)

prepare_package_layout

# Extract game icons

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Enable dxvk patches in the WINE prefix

case "$OPTION_PACKAGE" in
	('deb')
		APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
		# Install dxvk on first launch
		if [ ! -e dxvk_installed ]; then
			sleep 3s
			dxvk-setup install --development
			touch dxvk_installed
		fi'
		PKG_BIN_DEPS="$PKG_BIN_DEPS dxvk-wine32-development dxvk"
	;;
	('arch'|'gentoo')
		APP_WINETRICKS="$APP_WINETRICKS dxvk"
		PKG_BIN_DEPS="$PKG_BIN_DEPS winetricks"
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
