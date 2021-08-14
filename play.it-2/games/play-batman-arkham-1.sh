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
# Batman: Arkham Asylum
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210221.6

# Set game-specific variables

GAME_ID='batman-arkham-1'
GAME_NAME='Batman: Arkham Asylum'

ARCHIVE_GOG='setup_batman_arkham_asylum_goty_1.1_(38915).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/batman_arkham_asylum_goty'
ARCHIVE_GOG_MD5='46dc5afd1cf4a41f4c910a8c43fe8023'
ARCHIVE_GOG_VERSION='1.1-gog38915'
ARCHIVE_GOG_SIZE='8700000'
ARCHIVE_GOG_TYPE='innosetup'

ARCHIVE_GOG_PART1='setup_batman_arkham_asylum_goty_1.1_(38915)-1.bin'
ARCHIVE_GOG_PART1_MD5='59df55da8ffce48afd9a196c816769c3'
ARCHIVE_GOG_PART1_TYPE='innosetup'

ARCHIVE_GOG_PART2='setup_batman_arkham_asylum_goty_1.1_(38915)-2.bin'
ARCHIVE_GOG_PART2_MD5='8b7b283f4ea74c7f208bdd26c2f7a5b4'
ARCHIVE_GOG_PART2_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.rtf'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='binaries *.dll redist/directx'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='app/bmgame bmgame engine'

CONFIG_DIRS='engine/config bmgame/config'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='binaries/bmlauncher.exe'
APP_MAIN_ICON='binaries/shippingpc-bmgame.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
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

# Store saved games in a persistent path

DATA_DIRS="$DATA_DIRS ./saves"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store saved games in a persistent path
saves_path_prefix="$WINEPREFIX/drive_c/users/$USER/My Documents/Square Enix/Batman Arkham Asylum GOTY/SaveData"
saves_path_persistent="$PATH_PREFIX/saves"
if [ ! -h "$saves_path_prefix" ]; then
	if [ -d "$saves_path_prefix" ]; then
		# Migrate existing saved games to the persistent path
		mv "$saves_path_prefix"/* "$saves_path_persistent"
		rmdir "$saves_path_prefix"
	fi
	# Create link from prefix to persistent path
	mkdir --parents "$(dirname "$saves_path_prefix")"
	ln --symbolic "$saves_path_persistent" "$saves_path_prefix"
fi'

# Store configuration in a persistent path

CONFIG_DIRS="${CONFIG_DIRS} ./config"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store configuration in a persistent path
config_path_prefix="$WINEPREFIX/drive_c/users/$USER/My Documents/Square Enix/Batman Arkham Asylum GOTY/BmGame/Config"
config_path_persistent="$PATH_PREFIX/config"
if [ ! -h "$config_path_prefix" ]; then
	if [ -d "$config_path_prefix" ]; then
		# Migrate existing configuration to the persistent path
		mv "$config_path_prefix"/* "$config_path_persistent"
		rmdir "$config_path_prefix"
	fi
	# Create link from prefix to persistent path
	mkdir --parents "$(dirname "$config_path_prefix")"
	ln --symbolic "$config_path_persistent" "$config_path_prefix"
fi'

# Install PhysX

###
# TODO
# We should use the PhysX installer shipped with the game installer instead of the one downloaded by winetricks
###
APP_WINETRICKS="${APP_WINETRICKS} physx"
PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks"

# Install .NET 3.5 runtime in the WINE prefix

###
# TODO
# We should use the .NET 3.5 installer shipped with the game installer instead of the one downloaded by winetricks
###
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Do not disable mscoree library
export WINEDLLOVERRIDES="winemenubuilder.exe,mshtml=d"
# Install .NET 3.5 runtime on first launch
if [ ! -e dotnet35_installed ]; then
	sleep 3s
	winetricks dotnet35
	touch dotnet35_installed
fi'
PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks"

# Install shipped DirectX in the WINE prefix

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Install shipped DirectX on first launch
if [ ! -e directx9_installed ]; then
	sleep 3s
	wine redist/directx/dxsetup.exe
	winetricks d3dx9 d3dcompiler_43
	touch directx9_installed
fi'
PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks"

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

# Set up a WINE virtual desktop on first launch, using the current desktop resolution
# Cursor is prevented to leave the game window, avoiding issues with mouse look

APP_WINETRICKS="${APP_WINETRICKS} vd=\$(xrandr|awk '/\\*/ {print \$1}') grabfullscreen=y"
PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks xrandr"

# Run the game binary from its directory

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Run the game binary from its directory
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
