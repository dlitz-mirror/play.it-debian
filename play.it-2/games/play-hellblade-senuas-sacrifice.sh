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
# Hellblade: Senuaʼs Sacrifice
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200927.1

# Set game-specific variables

GAME_ID='hellblade-senuas-sacrifice'
GAME_NAME='Hellblade: Senuaʼs Sacrifice'

ARCHIVES_LIST='
ARCHIVE_GOG_0
'

ARCHIVE_GOG_0='setup_hellblade_senuas_sacrifice_1.03_(25168).exe'
ARCHIVE_GOG_0_MD5='0568c6e5c57dd64cc0a23a77fe54aafd'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/hellblade_senuas_sacrifice_pack'
ARCHIVE_GOG_0_VERSION='1.03-gog25168'
ARCHIVE_GOG_0_SIZE='23000000'
ARCHIVE_GOG_0_PART1='setup_hellblade_senuas_sacrifice_1.03_(25168)-1.bin'
ARCHIVE_GOG_0_PART1_MD5='b01d26d7555d26f2dc1cb8a361564cb7'
ARCHIVE_GOG_0_PART1_TYPE='innosetup'
ARCHIVE_GOG_0_PART2='setup_hellblade_senuas_sacrifice_1.03_(25168)-2.bin'
ARCHIVE_GOG_0_PART2_MD5='8e7e4e73fa6a535a4856005be7ea8cbb'
ARCHIVE_GOG_0_PART2_TYPE='innosetup'
ARCHIVE_GOG_0_PART3='setup_hellblade_senuas_sacrifice_1.03_(25168)-3.bin'
ARCHIVE_GOG_0_PART3_MD5='fcabee54e6f1072cbdbd46eb2a8ca0f8'
ARCHIVE_GOG_0_PART3_TYPE='innosetup'
ARCHIVE_GOG_0_PART4='setup_hellblade_senuas_sacrifice_1.03_(25168)-4.bin'
ARCHIVE_GOG_0_PART4_MD5='6fce92bde8bb15b0e706a7030874a3a9'
ARCHIVE_GOG_0_PART4_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH=''
ARCHIVE_DOC_DATA_FILES=''

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='engine hellbladegame/binaries hellbladegame/content/bink hellbladegame.exe'

ARCHIVE_GAME_DATA_PAK_1_PATH='.'
ARCHIVE_GAME_DATA_PAK_1_FILES='hellbladegame/content/paks/hellbladegame-windowsnoeditor.pak.1'

ARCHIVE_GAME_DATA_PAK_2_PATH='.'
ARCHIVE_GAME_DATA_PAK_2_FILES='hellbladegame/content/paks/hellbladegame-windowsnoeditor.pak.2'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='hellbladegame'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='hellbladegame.exe'
APP_MAIN_ICON='hellbladegame.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA_PAK_1 PKG_DATA_PAK_2 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_PRERM_RUN=''
PKG_DATA_DESCRIPTION='data'

PKG_DATA_PAK_1_ID="${PKG_DATA_ID}-pak-1"
PKG_DATA_PAK_1_DESCRIPTION='data - pak - chunk 1'

PKG_DATA_PAK_2_ID="${PKG_DATA_ID}-pak-2"
PKG_DATA_PAK_2_DESCRIPTION='data - pak - chunk 2'

PKG_DATA_DEPENDS="$PKG_DATA_PAK_1_ID $PKG_DATA_PAK_2_ID"

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Store user data in persistent paths

DATA_DIRS="$DATA_DIRS ./userdata"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store user data in persistent paths
userdata_path_prefix="$WINEPREFIX/drive_c/users/$USER/Local Settings/Application Data/HellbladeGame"
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
		PKG_BIN_DEPS="$PKG_BIN_DEPS dxvk-wine64-development dxvk"
	;;
	('arch'|'gentoo')
		APP_WINETRICKS="$APP_WINETRICKS dxvk"
		PKG_BIN_DEPS="$PKG_BIN_DEPS winetricks"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

# Split huge file into smaller chunks

###
# TODO
# With games getting bigger, a library-side function splitting files based on a maximum size may be helpful
# To ensure compatibility with .deb package format, we should never have to handle files bigger than 9GB
###
huge_file="$PLAYIT_WORKDIR/gamedata/hellbladegame/content/paks/hellbladegame-windowsnoeditor.pak"
case "${LANG%_*}" in
	('fr')
		message='Découpage de %s en plusieurs fichiers…'
	;;
	('en'|*)
		message='Splitting %s into smaller chunks…'
	;;
esac
# shellcheck disable=SC2059
printf "$message" "$huge_file"
if [ $DRY_RUN -eq 0 ]; then
	split --bytes=9G --numeric-suffixes=1 --suffix-length=1 "$huge_file" "${huge_file}."
	rm "$huge_file"
fi
printf '\t'
print_ok

# Set package scripts to rebuild the full file from its chunks

PKG_DATA_POSTINST_RUN="huge_file='$PATH_GAME/hellbladegame/content/paks/hellbladegame-windowsnoeditor.pak'"
# shellcheck disable=SC2016
PKG_DATA_POSTINST_RUN="$PKG_DATA_POSTINST_RUN"'
case "${LANG%_*}" in
	("fr")
		message="Reconstruction de %s à partir de ses parties…\n"
	;;
	("en"|*)
		message="Rebuilding %s from its chunks…\n"
	;;
esac
printf "$message" "$huge_file"
cat "${huge_file}."* > "$huge_file"
rm "${huge_file}."*'
PKG_DATA_PRERM_RUN="huge_file='$PATH_GAME/hellbladegame/content/paks/hellbladegame-windowsnoeditor.pak'"
# shellcheck disable=SC2016
PKG_DATA_PRERM_RUN="$PKG_DATA_PRERM_RUN"'
rm "$huge_file"'

# Prepare packages layout

prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

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
