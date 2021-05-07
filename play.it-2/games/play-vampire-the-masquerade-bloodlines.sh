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
# Vampire: The Masquerade - Bloodlines
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210507.14

# Set game-specific variables

SCRIPT_DEPS_DOTEMU='unzip'

GAME_ID='vampire-the-masquerade-bloodlines'
GAME_NAME='Vampire: The Masquerade - Bloodlines'

ARCHIVE_BASE_DOTEMU_0='vampire_the_masquerade_bloodlines_v1.2.exe'
ARCHIVE_BASE_DOTEMU_0_MD5='8981da5fa644475583b2888a67fdd741'
ARCHIVE_BASE_DOTEMU_0_TYPE='rar'
ARCHIVE_BASE_DOTEMU_0_SIZE='3000000'
ARCHIVE_BASE_DOTEMU_0_VERSION='1.2-dotemu1'

ARCHIVE_BASE_GOG_EN_2='setup_vampire_the_masquerade_-_bloodlines_1.2_(up_10.2)_(28160).exe'
ARCHIVE_BASE_GOG_EN_2_MD5='8c1907871d2ded8afda77d5b570d5383'
ARCHIVE_BASE_GOG_EN_2_TYPE='innosetup'
ARCHIVE_BASE_GOG_EN_2_PART1='setup_vampire_the_masquerade_-_bloodlines_1.2_(up_10.2)_(28160)-1.bin'
ARCHIVE_BASE_GOG_EN_2_PART1_MD5='a28edc25dc3c0f818673196852490628'
ARCHIVE_BASE_GOG_EN_2_PART1_TYPE='innosetup'
ARCHIVE_BASE_GOG_EN_2_SIZE='4100000'
ARCHIVE_BASE_GOG_EN_2_VERSION='1.2up10.2-gog28160'
ARCHIVE_BASE_GOG_EN_2_URL='https://www.gog.com/game/vampire_the_masquerade_bloodlines'

ARCHIVE_BASE_GOG_FR_2='setup_vampire_the_masquerade_-_bloodlines_1.2_(up_10.2)_(french)_(28160).exe'
ARCHIVE_BASE_GOG_FR_2_MD5='8877c5ab14363b249e72034fe5333921'
ARCHIVE_BASE_GOG_FR_2_TYPE='innosetup'
ARCHIVE_BASE_GOG_FR_2_PART1='setup_vampire_the_masquerade_-_bloodlines_1.2_(up_10.2)_(french)_(28160)-1.bin'
ARCHIVE_BASE_GOG_FR_2_PART1_MD5='0dddbbcd2dee5474066b4863c56aa5f0'
ARCHIVE_BASE_GOG_FR_2_PART1_TYPE='innosetup'
ARCHIVE_BASE_GOG_FR_2_SIZE='4200000'
ARCHIVE_BASE_GOG_FR_2_VERSION='1.2up10.2-gog28160'
ARCHIVE_BASE_GOG_FR_2_URL='https://www.gog.com/game/vampire_the_masquerade_bloodlines'

ARCHIVE_BASE_GOG_EN_1='setup_vampire_the_masquerade_-_bloodlines_1.2_(up_10.0)_(22135).exe'
ARCHIVE_BASE_GOG_EN_1_MD5='095771daf8fd1b26d34a099f182c8d4a'
ARCHIVE_BASE_GOG_EN_1_TYPE='innosetup'
ARCHIVE_BASE_GOG_EN_1_PART1='setup_vampire_the_masquerade_-_bloodlines_1.2_(up_10.0)_(22135)-1.bin'
ARCHIVE_BASE_GOG_EN_1_PART1_MD5='ef8a3fe212da189d811fcf6bc70a1e40'
ARCHIVE_BASE_GOG_EN_1_PART1_TYPE='innosetup'
ARCHIVE_BASE_GOG_EN_1_SIZE='4100000'
ARCHIVE_BASE_GOG_EN_1_VERSION='1.2up10.0-gog22135'

ARCHIVE_BASE_GOG_EN_0='setup_vtmb_1.2_(up_9.7_basic)_(11362).exe'
ARCHIVE_BASE_GOG_EN_0_MD5='62b8db3b054595fb46bd8eaa5f8ae7bc'
ARCHIVE_BASE_GOG_EN_0_TYPE='innosetup'
ARCHIVE_BASE_GOG_EN_0_PART1='setup_vtmb_1.2_(up_9.7_basic)_(11362)-1.bin'
ARCHIVE_BASE_GOG_EN_0_PART1_MD5='4177042d5a6e03026d52428e900e6137'
ARCHIVE_BASE_GOG_EN_0_PART1_TYPE='innosetup'
ARCHIVE_BASE_GOG_EN_0_SIZE='4100000'
ARCHIVE_BASE_GOG_EN_0_VERSION='1.2up9.7-gog11362'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='bin *.dll *.dll.12 *.exe.12 launcher.exe vampire.exe vampire/*dlls unofficial_patch/*dlls'

ARCHIVE_GAME_L10N_PATH='.'
ARCHIVE_GAME_L10N_FILES='docs *.pdf version.inf vampire/cfg vampire/pack101.vpk vampire/pack103.vpk vampire/stats.txt vampire/vidcfg.bin'

ARCHIVE_GAME_L10N_DE_PATH="$ARCHIVE_GAME_L10N_PATH"
ARCHIVE_GAME_L10N_DE_FILES="$ARCHIVE_GAME_L10N_FILES"

ARCHIVE_GAME_L10N_EN_PATH="$ARCHIVE_GAME_L10N_PATH"
ARCHIVE_GAME_L10N_EN_FILES="$ARCHIVE_GAME_L10N_FILES"

ARCHIVE_GAME_L10N_FR_PATH="$ARCHIVE_GAME_L10N_PATH"
ARCHIVE_GAME_L10N_FR_FILES="$ARCHIVE_GAME_L10N_FILES"

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES_DOTEMU='*.mpg *.tth *.txt *.dat vampire/maps vampire/media vampire/pack000.vpk vampire/pack001.vpk vampire/pack002.vpk vampire/pack003.vpk vampire/pack004.vpk vampire/pack005.vpk vampire/pack006.vpk vampire/pack007.vpk vampire/pack008.vpk vampire/pack009.vpk vampire/pack010.vpk vampire/pack100.vpk vampire/pack102.vpk vampire/python vampire/sound'
ARCHIVE_GAME_DATA_FILES_GOG='*.mpg *.pdf *.tth *.txt *.dat version.inf doc vampire unofficial_patch'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='vampire.exe'
APP_MAIN_ICON='vampire.exe'

APP_UP_ID="${GAME_ID}-up"
APP_UP_NAME="${GAME_NAME} - Unofficial Patch"
APP_UP_TYPE='wine'
APP_UP_EXE='vampire.exe'
APP_UP_OPTIONS='-game unofficial_patch'
APP_UP_ICON='vampire.exe'

###
# TODO
# We should try to build a dedicated package for localized data provided by gog archives
###

PACKAGES_LIST_DOTEMU='PKG_BIN PKG_L10N_DE PKG_L10N_EN PKG_L10N_FR PKG_DATA'
PACKAGES_LIST_GOG='PKG_BIN PKG_DATA'

# Data package - common properties

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_PROVIDE="$PKG_DATA_ID"
PKG_DATA_DESCRIPTION='data'

# Data package - gog archive

PKG_DATA_ID_GOG_EN="${PKG_DATA_ID}-en"
PKG_DATA_ID_GOG_FR="${PKG_DATA_ID}-fr"
PKG_DATA_DESCRIPTION_GOG_EN="${PKG_DATA_DESCRIPTION} - English version"
PKG_DATA_DESCRIPTION_GOG_FR="${PKG_DATA_DESCRIPTION} - French version"

# Localization packages - dotemu archive only

PKG_L10N_ID="${GAME_ID}-l10n"

PKG_L10N_DE_ID="${PKG_L10N_ID}-de"
PKG_L10N_DE_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DE_DESCRIPTION='German localization'

PKG_L10N_EN_ID="${PKG_L10N_ID}-en"
PKG_L10N_EN_PROVIDE="$PKG_L10N_ID"
PKG_L10N_EN_DESCRIPTION='English localization'

PKG_L10N_FR_ID="${PKG_L10N_ID}-fr"
PKG_L10N_FR_PROVIDE="$PKG_L10N_ID"
PKG_L10N_FR_DESCRIPTION='French localization'

# Binaries package - common properties

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine"

# Binaries package - dotemu archive

PKG_BIN_DEPS_DOTEMU="${PKG_L10N_ID} ${PKG_BIN_DEPS}"

# Use persistent storage for user data

CONFIG_DIRS='./vampire/cfg ./unofficial_patch/cfg'
CONFIG_FILES='./vampire/vidcfg.bin ./unofficial_patch/vidcfg.bin'
DATA_DIRS='./vampire/maps/graphs ./vampire/python ./vampire/save ./unofficial_patch/maps/graphs ./unofficial_patch/python ./unofficial_patch/save'

# Keep compatibility with old archives

ARCHIVE_GAME_BIN_PATH_GOG_EN_0='app'
ARCHIVE_GAME_DATA_PATH_GOG_EN_0='app'

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

# Set script dependencies depending on source archive

use_archive_specific_value 'SCRIPT_DEPS'
check_deps

# Set list of packages to build depending on source archive

use_archive_specific_value 'PACKAGES_LIST'
# shellcheck disable=SC2086
set_temp_directories $PACKAGES_LIST

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
case "$ARCHIVE" in
	('ARCHIVE_BASE_DOTEMU'*)
		(
			ARCHIVE='ARCHIVE_DE'
			ARCHIVE_DE="${PLAYIT_WORKDIR}/gamedata/de.zip"
			ARCHIVE_DE_TYPE='zip'
			extract_data_from "$ARCHIVE_DE"
			rm "$ARCHIVE_DE"
		)
		tolower "${PLAYIT_WORKDIR}/gamedata"
		prepare_package_layout 'PKG_L10N_DE' 'PKG_DATA'
		find "${PLAYIT_WORKDIR}/gamedata" -type d -empty -delete
		(
			# shellcheck disable=SC2030
			ARCHIVE='ARCHIVE_EN'
			ARCHIVE_EN="${PLAYIT_WORKDIR}/gamedata/en.zip"
			ARCHIVE_EN_TYPE='zip'
			extract_data_from "$ARCHIVE_EN"
			rm "$ARCHIVE_EN"
		)
		tolower "${PLAYIT_WORKDIR}/gamedata"
		prepare_package_layout 'PKG_L10N_EN' 'PKG_DATA'
		find "${PLAYIT_WORKDIR}/gamedata" -type d -empty -delete
		(
			# shellcheck disable=SC2030
			ARCHIVE='ARCHIVE_FR'
			ARCHIVE_FR="${PLAYIT_WORKDIR}/gamedata/fr.zip"
			ARCHIVE_FR_TYPE='zip'
			extract_data_from "$ARCHIVE_FR"
			rm "$ARCHIVE_FR"
		)
		tolower "${PLAYIT_WORKDIR}/gamedata"
		prepare_package_layout 'PKG_L10N_FR' 'PKG_DATA'
		find "${PLAYIT_WORKDIR}/gamedata" -type d -empty -delete
		(
			# shellcheck disable=SC2030
			ARCHIVE='ARCHIVE_COMMON1'
			ARCHIVE_COMMON1="${PLAYIT_WORKDIR}/gamedata/common1.zip"
			ARCHIVE_COMMON1_TYPE='zip'
			extract_data_from "$ARCHIVE_COMMON1"
			rm "$ARCHIVE_COMMON1"
			ARCHIVE='ARCHIVE_COMMON2'
			ARCHIVE_COMMON2="${PLAYIT_WORKDIR}/gamedata/common2.zip"
			ARCHIVE_COMMON2_TYPE='zip'
			extract_data_from "$ARCHIVE_COMMON2"
			rm "$ARCHIVE_COMMON2"
		)
		tolower "${PLAYIT_WORKDIR}/gamedata"
	;;
esac

###
# TODO
# There might be a less tricky way to rename the included directory
# The current method will break if some future version of the archive includes multiple files matching "unofficial_patch_*"
###
# shellcheck disable=SC2144
if [ -e "$PLAYIT_WORKDIR"/gamedata/unofficial_patch_* ]; then
	mv "$PLAYIT_WORKDIR"/gamedata/unofficial_patch_* "$PLAYIT_WORKDIR/gamedata/unofficial_patch"
fi

prepare_package_layout

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
# shellcheck disable=SC2031
case "$ARCHIVE" in
	('ARCHIVE_GOG'*)
		icons_get_from_package 'APP_UP'
	;;
esac
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Enable dxvk patches in the WINE prefix

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Install dxvk on first launch
if [ ! -e dxvk_installed ]; then
	# Wait a bit to ensure there is no lingering wine process
	sleep 1s

	if \
		command -v dxvk-setup >/dev/null 2>&1 && \
		command -v wine-development >/dev/null 2>&1
	then
		dxvk-setup install --development
		touch dxvk_installed
	elif command -v winetricks >/dev/null 2>&1; then
		winetricks dxvk
		touch dxvk_installed
	else
		message="\\033[1;33mWarning:\\033[0m\\n"
		message="${message}DXVK patches could not be installed in the WINE prefix.\\n"
		message="${message}The game might run with display or performance issues.\\n"
		printf "\\n${message}\\n"
	fi

	# Wait a bit to ensure there is no lingering wine process
	sleep 1s
fi'
case "$OPTION_PACKAGE" in
	('deb')
		# Debian-based distributions should use repositories-provided dxvk
		# winetricks is used as a fallback for branches not having access to dxvk-setup
		extra_dependencies='vulkan-icd | mesa-vulkan-drivers, dxvk-wine32-development | winetricks, dxvk | winetricks'
		if [ -n "$PKG_BIN_DEPS_DEB" ]; then
			PKG_BIN_DEPS_DEB="${PKG_BIN_DEPS_DEB}, ${extra_dependencies}"
		else
			PKG_BIN_DEPS_DEB="$extra_dependencies"
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
# shellcheck disable=SC2031
case "$ARCHIVE" in
	('ARCHIVE_GOG'*)
		launchers_write 'APP_UP'
	;;
esac

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

# shellcheck disable=SC2031
case "$ARCHIVE" in
	('ARCHIVE_BASE_DOTEMU'*)
		case "${LANG%_*}" in
			('fr')
				lang_string='version %s :'
				lang_de='allemande'
				lang_en='anglaise'
				lang_fr='française'
			;;
			('en'|*)
				lang_string='%s version:'
				lang_de='German'
				lang_en='English'
				lang_fr='French'
			;;
		esac
		printf '\n'
		# shellcheck disable=SC2059
		printf "$lang_string" "$lang_de"
		print_instructions 'PKG_L10N_DE' 'PKG_DATA' 'PKG_BIN'
		# shellcheck disable=SC2059
		printf "$lang_string" "$lang_en"
		print_instructions 'PKG_L10N_EN' 'PKG_DATA' 'PKG_BIN'
		# shellcheck disable=SC2059
		printf "$lang_string" "$lang_fr"
		print_instructions 'PKG_L10N_FR' 'PKG_DATA' 'PKG_BIN'
	;;
	(*)
		print_instructions
	;;
esac

exit 0
