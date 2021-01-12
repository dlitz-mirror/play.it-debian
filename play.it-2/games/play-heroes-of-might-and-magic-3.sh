#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Heroes of Might and Magic 3
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210112.1

# Set game-specific variables

GAME_ID='heroes-of-might-and-magic-3'
GAME_NAME='Heroes of Might and Magic Ⅲ'

SCRIPT_DEPS='iconv'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_OLDTEMPLATE_EN_1
ARCHIVE_GOG_OLDTEMPLATE_EN_0
ARCHIVE_GOG_FR_0
ARCHIVE_GOG_OLDTEMPLATE_FR_1
ARCHIVE_GOG_OLDTEMPLATE_FR_0'

# gog.com installer, English

ARCHIVE_GOG_EN_0='setup_heroes_of_might_and_magic_3_complete_4.0_(28740).exe'
ARCHIVE_GOG_EN_0_MD5='8dcd6c4a8c72c65a6920665e28245c57'
ARCHIVE_GOG_EN_0_TYPE='innosetup'
ARCHIVE_GOG_EN_0_PART1='setup_heroes_of_might_and_magic_3_complete_4.0_(28740)-1.bin'
ARCHIVE_GOG_EN_0_PART1_MD5='4285d54f27c40e815905c7069b6f9f84'
ARCHIVE_GOG_EN_0_PART1_TYPE='innosetup'
ARCHIVE_GOG_EN_0_VERSION='4.0-gog28740'
ARCHIVE_GOG_EN_0_SIZE='1100000'
ARCHIVE_GOG_EN_0_URL='https://www.gog.com/game/heroes_of_might_and_magic_3_complete_edition'

ARCHIVE_GOG_OLDTEMPLATE_EN_1='setup_homm_3_complete_4.0_(10665).exe'
ARCHIVE_GOG_OLDTEMPLATE_EN_1_MD5='0c97452fc4da4e8811173f21df873fab'
ARCHIVE_GOG_OLDTEMPLATE_EN_1_TYPE='innosetup'
ARCHIVE_GOG_OLDTEMPLATE_EN_1_VERSION='4.0-gog10665'
ARCHIVE_GOG_OLDTEMPLATE_EN_1_SIZE='1100000'

ARCHIVE_GOG_OLDTEMPLATE_EN_0='setup_homm3_complete_2.0.0.16.exe'
ARCHIVE_GOG_OLDTEMPLATE_EN_0_MD5='263d58f8cc026dd861e9bbcadecba318'
ARCHIVE_GOG_OLDTEMPLATE_EN_0_TYPE='innosetup'
ARCHIVE_GOG_OLDTEMPLATE_EN_0_PART1='patch_heroes_of_might_and_magic_3_complete_2.0.1.17.exe'
ARCHIVE_GOG_OLDTEMPLATE_EN_0_PART1_MD5='815b9c097cd57d0e269beb4cc718dad3'
ARCHIVE_GOG_OLDTEMPLATE_EN_0_PART1_TYPE='innosetup'
ARCHIVE_GOG_OLDTEMPLATE_EN_0_VERSION='3.0-gog2.0.1.17'
ARCHIVE_GOG_OLDTEMPLATE_EN_0_SIZE='1100000'

# gog.com installer, French

ARCHIVE_GOG_FR_0='setup_heroes_of_might_and_magic_3_complete_4.0_(french)_(28740).exe'
ARCHIVE_GOG_FR_0_MD5='be4b59590146299dbe77bda7a4ea4178'
ARCHIVE_GOG_FR_0_TYPE='innosetup'
ARCHIVE_GOG_FR_0_PART1='setup_heroes_of_might_and_magic_3_complete_4.0_(french)_(28740)-1.bin'
ARCHIVE_GOG_FR_0_PART1_MD5='88b71e0fd44e5be1ad6791e74120c61c'
ARCHIVE_GOG_FR_0_PART1_TYPE='innosetup'
ARCHIVE_GOG_FR_0_VERSION='4.0-gog28740'
ARCHIVE_GOG_FR_0_SIZE='1100000'
ARCHIVE_GOG_FR_0_URL='https://www.gog.com/game/heroes_of_might_and_magic_3_complete_edition'

ARCHIVE_GOG_OLDTEMPLATE_FR_1='setup_homm_3_complete_french_4.0_(10665).exe'
ARCHIVE_GOG_OLDTEMPLATE_FR_1_MD5='6c3ee33a531bd0604679581ab267d8a3'
ARCHIVE_GOG_OLDTEMPLATE_FR_1_TYPE='innosetup'
ARCHIVE_GOG_OLDTEMPLATE_FR_1_VERSION='4.0-gog10665'
ARCHIVE_GOG_OLDTEMPLATE_FR_1_SIZE='1100000'

ARCHIVE_GOG_OLDTEMPLATE_FR_0='setup_homm3_complete_french_2.1.0.20.exe'
ARCHIVE_GOG_OLDTEMPLATE_FR_0_MD5='ca8e4726acd7b5bc13c782d59c5a459b'
ARCHIVE_GOG_OLDTEMPLATE_FR_0_TYPE='innosetup'
ARCHIVE_GOG_OLDTEMPLATE_FR_0_VERSION='3.0-gog2.1.0.20'
ARCHIVE_GOG_OLDTEMPLATE_FR_0_SIZE='1100000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='eula *.cnt *.hlp *.pdf *.txt'

ARCHIVE_GAME0_BIN_WINE_PATH='.'
ARCHIVE_GAME0_BIN_WINE_FILES='*.exe binkw32.dll ifc20.dll ifc21.dll mcp.dll mp3dec.asi mss32.dll smackw32.dll'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='data maps mp3'

# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_OLDTEMPLATE='app'
ARCHIVE_GAME_DATA_PATH_GOG_OLDTEMPLATE='app'
ARCHIVE_GAME0_BIN_WINE_PATH_GOG_OLDTEMPLATE='app'
ARCHIVE_GAME1_BIN_WINE_PATH_GOG_OLDTEMPLATE_EN_0='tmp'
ARCHIVE_GAME1_BIN_WINE_FILES_GOG_OLDTEMPLATE_EN_0='heroes3.exe'

CONFIG_DIRS='./config'
DATA_DIRS='./games ./maps ./random_maps'
DATA_FILES='./data/h3ab_bmp.lod ./data/h3ab_spr.lod ./data/h3bitmap.lod ./data/h3sprite.lod'

APP_REGEDIT='tweaks.reg'
APP_WINETRICKS="vd=\$(xrandr|awk '/\\*/ {print \$1}')"

APP_MAIN_TYPE_BIN_WINE='wine'
APP_MAIN_TYPE_BIN_VCMI='native'
APP_MAIN_EXE='heroes3.exe'
APP_MAIN_ICON='heroes3.exe'

APP_EDITOR_MAP_TYPE='wine'
APP_EDITOR_MAP_ID="${GAME_ID}_map-editor"
APP_EDITOR_MAP_EXE='h3maped.exe'
APP_EDITOR_MAP_ICON='h3maped.exe'
APP_EDITOR_MAP_NAME="$GAME_NAME - map editor"

APP_EDITOR_CAMPAIGN_TYPE='wine'
APP_EDITOR_CAMPAIGN_ID="${GAME_ID}_campaign-editor"
APP_EDITOR_CAMPAIGN_EXE='h3ccmped.exe'
APP_EDITOR_CAMPAIGN_ICON='h3ccmped.exe'
APP_EDITOR_CAMPAIGN_NAME="$GAME_NAME - campaign editor"

PACKAGES_LIST='PKG_BIN_VCMI PKG_BIN_WINE PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_ID_GOG_EN="${PKG_DATA_ID}-en"
PKG_DATA_ID_GOG_FR="${PKG_DATA_ID}-fr"
PKG_DATA_PROVIDE="$PKG_DATA_ID"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ID="$GAME_ID"

PKG_BIN_VCMI_ID="${PKG_BIN_ID}-vcmi"
PKG_BIN_VCMI_PROVIDE="$PKG_BIN_ID"
PKG_BIN_VCMI_DEPS="$PKG_DATA_ID"
PKG_BIN_VCMI_DEPS_ARCH='vcmi'
PKG_BIN_VCMI_DEPS_DEB='vcmi'
PKG_BIN_VCMI_DEPS_GENTOO='games-strategy/vcmi' # overlay required: https://github.com/qdii/qdiilay

PKG_BIN_WINE_ID="${PKG_BIN_ID}-wine"
PKG_BIN_WINE_ID_GOG_EN="${PKG_BIN_WINE_ID}-en"
PKG_BIN_WINE_ID_GOG_FR="${PKG_BIN_WINE_ID}-fr"
PKG_BIN_WINE_PROVIDE="$PKG_BIN_ID"
PKG_BIN_WINE_ARCH='32'
PKG_BIN_WINE_DEPS="$PKG_DATA_ID wine winetricks xrandr glx"

# Keep compatibility with old archives
PKG_DATA_ID_GOG_OLDTEMPLATE_EN="$PKG_DATA_ID_GOG_EN"
PKG_DATA_ID_GOG_OLDTEMPLATE_FR="$PKG_DATA_ID_GOG_FR"
PKG_BIN_WINE_ID_GOG_OLDTEMPLATE_EN="$PKG_BIN_WINE_ID_GOG_EN"
PKG_BIN_WINE_ID_GOG_OLDTEMPLATE_FR="$PKG_BIN_WINE_ID_GOG_FR"

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

# For old gog.com English archive, get the patched .exe

case "$ARCHIVE" in
	('ARCHIVE_GOG_OLDTEMPLATE_EN_0')
		extract_data_from "$SOURCE_ARCHIVE_PART1"
	;;
esac

prepare_package_layout

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Allow to skip intro video on first launch + set default settings

file="${PKG_BIN_WINE_PATH}${PATH_GAME}/$APP_REGEDIT"
if [ $DRY_RUN -eq 0 ];then
	cat > "$file" <<- 'EOF'
	Windows Registry Editor Version 5.00

	[HKEY_LOCAL_MACHINE\Software\New World Computing\Heroes of Might and Magic® III\1.0]
	"Animate SpellBook"=dword:00000001
	"Autosave"=dword:00000001
	"Bink Video"=dword:00000001
	"Blackout Computer"=dword:00000000
	"Combat Army Info Level"=dword:00000000
	"Combat Auto Creatures"=dword:00000001
	"Combat Auto Spells"=dword:00000001
	"Combat Ballista"=dword:00000001
	"Combat Catapult"=dword:00000001
	"Combat First Aid Tent"=dword:00000001
	"Combat Shade Level"=dword:00000000
	"Combat Speed"=dword:00000000
	"Computer Walk Speed"=dword:00000003
	"First Time"=dword:00000000
	"Last Music Volume"=dword:00000005
	"Last Sound Volume"=dword:00000005
	"Main Game Full Screen"=dword:00000001
	"Main Game Show Menu"=dword:00000001
	"Main Game X"=dword:0000000a
	"Main Game Y"=dword:0000000a
	"Move Reminder"=dword:00000001
	"Music Volume"=dword:00000005
	"Network Default Name"="Player"
	"Quick Combat"=dword:00000000
	"Show Combat Grid"=dword:00000000
	"Show Combat Mouse Hex"=dword:00000000
	"Show Intro"=dword:00000001
	"Show Route"=dword:00000001
	"Sound Volume"=dword:00000005
	"Test Blit"=dword:00000000
	"Test Decomp"=dword:00000000
	"Test Read"=dword:00000000
	"Town Outlines"=dword:00000001
	"Video Subtitles"=dword:00000001
	"Walk Speed"=dword:00000002
	"Window Scroll Speed"=dword:00000001
	EOF
	iconv --from-code=UTF-8 --to-code=UTF-16 --output="$file" "$file"
fi

# Extract icons

PKG='PKG_BIN_WINE'
icons_get_from_package 'APP_MAIN' 'APP_EDITOR_MAP' 'APP_EDITOR_CAMPAIGN'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN_WINE'
use_package_specific_value 'APP_MAIN_TYPE'
launchers_write 'APP_MAIN' 'APP_EDITOR_MAP' 'APP_EDITOR_CAMPAIGN'

PKG='PKG_BIN_VCMI'
use_package_specific_value 'APP_MAIN_TYPE'
launcher="${PKG_BIN_VCMI_PATH}${PATH_BIN}/$GAME_ID"
if [ $DRY_RUN -eq 0 ]; then
	mkdir --parents "${launcher%/*}"
	touch "$launcher"
	chmod 755 "$launcher"
	launcher_write_script_headers "$launcher"
	{
		cat <<- 'EOF'
		VCMI_DATA="${XDG_DATA_HOME:="$HOME/.local/share"}/vcmi"
		EOF
		cat <<- EOF
		GAME_PATH="$PATH_GAME"
		EOF
		cat <<- 'EOF'

		for dir in data maps mp3; do
		    if [ ! -e "$VCMI_DATA/$dir" ]; then
		        mkdir --parents "$VCMI_DATA"
		        cp --recursive --remove-destination --symbolic-link "$GAME_PATH/$dir" "$VCMI_DATA"
		    fi
		done

		vcmilauncher

		exit 0
		EOF
	} >> "$launcher"
fi
launcher_write_desktop 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

printf '\n'
printf 'VCMI:'
print_instructions 'PKG_DATA' 'PKG_BIN_VCMI'
printf 'WINE:'
print_instructions 'PKG_DATA' 'PKG_BIN_WINE'

exit 0
