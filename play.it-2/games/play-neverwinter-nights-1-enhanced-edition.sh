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
# Neverwinter Nights: Enhanced Edition
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201002.3

# Set game-specific variables

GAME_ID='neverwinter-nights-1-enhanced-edition'
GAME_NAME='Neverwinter Nights: Enhanced Edition'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0
ARCHIVE_GOG_EN_1
ARCHIVE_GOG_FR_1
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0
'

# Base game archive

ARCHIVE_GOG_1='neverwinter_nights_enhanced_edition_81_8193_16_41300.sh'
ARCHIVE_GOG_1_MD5='a52646002ab14c452731b0636fdc8278'
ARCHIVE_GOG_1_TYPE='mojosetup'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/neverwinter_nights_enhanced_edition_pack'
ARCHIVE_GOG_1_VERSION='1.81.8193.16-gog41300'
ARCHIVE_GOG_1_SIZE='6200000'

ARCHIVE_GOG_0='neverwinter_nights_enhanced_edition_80_8193_9_37029.sh'
ARCHIVE_GOG_0_MD5='fb98f859b5f5516fc7df8b00c7264c07'
ARCHIVE_GOG_0_TYPE='mojosetup'
ARCHIVE_GOG_0_VERSION='1.80.8193.9-gog37029'
ARCHIVE_GOG_0_SIZE='5000000'

ARCHIVE_GOG_EN_1='neverwinter_nights_enhanced_edition_78_8186_1_32700.sh'
ARCHIVE_GOG_EN_1_MD5='4fbd9086c0c355245e2645ecb80eac44'
ARCHIVE_GOG_EN_1_TYPE='mojosetup'
ARCHIVE_GOG_EN_1_VERSION='1.78.8186.1-gog32700'
ARCHIVE_GOG_EN_1_SIZE='4800000'

ARCHIVE_GOG_FR_1='neverwinter_nights_enhanced_edition_french_78_8186_1_32700.sh'
ARCHIVE_GOG_FR_1_MD5='80d9a74b706cf4706c5c4f55c8e10c3c'
ARCHIVE_GOG_FR_1_TYPE='mojosetup'
ARCHIVE_GOG_FR_1_VERSION='1.78.8186.1-gog32700'
ARCHIVE_GOG_FR_1_SIZE='4800000'

ARCHIVE_GOG_EN_0='neverwinter_nights_enhanced_edition_78_8186_25455.sh'
ARCHIVE_GOG_EN_0_MD5='da5a06cc92c4e43cbd851e6df8b5bb9e'
ARCHIVE_GOG_EN_0_TYPE='mojosetup'
ARCHIVE_GOG_EN_0_VERSION='1.78.8186-gog25455'
ARCHIVE_GOG_EN_0_SIZE='4700000'

ARCHIVE_GOG_FR_0='neverwinter_nights_enhanced_edition_french_78_8186_25455.sh'
ARCHIVE_GOG_FR_0_MD5='61b7d20a09288694e9930d74d335b950'
ARCHIVE_GOG_FR_0_TYPE='mojosetup'
ARCHIVE_GOG_FR_0_VERSION='1.78.8186-gog25455'
ARCHIVE_GOG_FR_0_SIZE='4700000'

# Extra language packs

ARCHIVE_GOG_1_OPTIONAL_L10N_FR='neverwinter_nights_enhanced_edition_french_extras_81_8193_16_41300.sh'
ARCHIVE_GOG_1_OPTIONAL_L10N_FR_MD5='1fe0cc196c146834ff186935ae2d3d66'
ARCHIVE_GOG_1_OPTIONAL_L10N_FR_TYPE='mojosetup'
ARCHIVE_GOG_1_OPTIONAL_L10N_FR_URL='https://www.gog.com/game/neverwinter_nights_enhanced_edition_french_extras'
ARCHIVE_GOG_1_OPTIONAL_L10N_FR_SIZE='840000'

ARCHIVE_GOG_0_OPTIONAL_L10N_FR='neverwinter_nights_enhanced_edition_french_extras_80_8193_9_37029.sh'
ARCHIVE_GOG_0_OPTIONAL_L10N_FR_MD5='5e0564a161259b003c7dc0f8d8aa743f'
ARCHIVE_GOG_0_OPTIONAL_L10N_FR_TYPE='mojosetup'
ARCHIVE_GOG_0_OPTIONAL_L10N_FR_SIZE='840000'

ARCHIVE_DOC_DATA_PATH='data/noarch/game/lang/en/docs'
ARCHIVE_DOC_DATA_FILES='*.pdf *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_EN='data/noarch/docs'
ARCHIVE_DOC_DATA_PATH_GOG_FR='data/noarch/docs'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='bin/linux-x86'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_FILES_GOG_EN_0='bin/linux'
ARCHIVE_GAME_BIN_FILES_GOG_FR_0='bin/linux'

ARCHIVE_DOC_L10N_DE_PATH='data/noarch/game/lang/de/docs/legacy'
ARCHIVE_DOC_L10N_DE_FILES='*.pdf *.rtf *.txt'

ARCHIVE_DOC_L10N_EN_PATH='data/noarch/game/lang/en/docs/legacy'
ARCHIVE_DOC_L10N_EN_FILES='*.pdf *.rtf *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_L10N_EN_PATH_GOG_EN='data/noarch/docs/legacy'

ARCHIVE_DOC_L10N_ES_PATH='data/noarch/game/lang/es/docs/legacy'
ARCHIVE_DOC_L10N_ES_FILES='*.pdf *.rtf *.txt'

ARCHIVE_DOC_L10N_FR_PATH='data/noarch/game/lang/fr/docs/legacy'
ARCHIVE_DOC_L10N_FR_FILES='*.pdf *.rtf *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_L10N_FR_PATH_GOG_FR='data/noarch/docs/legacy'

ARCHIVE_DOC_L10N_IT_PATH='data/noarch/game/lang/it/docs/legacy'
ARCHIVE_DOC_L10N_IT_FILES='*.pdf *.rtf *.txt'

ARCHIVE_DOC_L10N_PL_PATH='data/noarch/game/lang/pl/docs/legacy'
ARCHIVE_DOC_L10N_PL_FILES='*.pdf *.rtf *.txt'

ARCHIVE_GAME_L10N_DE_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_DE_FILES='lang/de/data'

# Keep compatibility with old archives
ARCHIVE_GAME_L10N_EN_PATH_GOG_EN='data/noarch/game'
ARCHIVE_GAME_L10N_EN_FILES_GOG_EN='data/*.tlk'

ARCHIVE_GAME_L10N_ES_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_ES_FILES='lang/es/data'

ARCHIVE_GAME_L10N_FR_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_FR_FILES='lang/fr/data'
# Keep compatibility with old archives
ARCHIVE_GAME_L10N_FR_FILES_GOG_FR='data/*.tlk'

ARCHIVE_GAME_L10N_IT_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_IT_FILES='lang/it/data'

ARCHIVE_GAME_L10N_PL_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_PL_FILES='lang/pl/data'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='data ovr lang/en/data'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Run the game binary from its parent directory
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'
APP_MAIN_EXE='bin/linux-x86/nwmain-linux'
APP_MAIN_ICON='data/noarch/game/bin/win32/nwmain.exe'
# Keep compatibility with old archives
APP_MAIN_EXE_GOG_EN_0='bin/linux/nwmain-linux'
APP_MAIN_EXE_GOG_FR_0='bin/linux/nwmain-linux'

APP_SERVER_ID="${GAME_ID}_server"
APP_SERVER_NAME="$GAME_NAME - server"
APP_SERVER_TYPE='native'
APP_SERVER_PRERUN="$APP_MAIN_PRERUN"
APP_SERVER_EXE='bin/linux-x86/nwserver-linux'
APP_SERVER_ICON='data/noarch/game/bin/win32/nwserver.exe'
# Keep compatibility with old archives
APP_SERVER_EXE_GOG_EN_0='bin/linux/nwserver-linux'
APP_SERVER_EXE_GOG_FR_0='bin/linux/nwserver-linux'

PACKAGES_LIST='PKG_BIN PKG_L10N_DE PKG_L10N_ES PKG_L10N_FR PKG_L10N_IT PKG_L10N_PL PKG_DATA'
PACKAGES_LIST_GOG_EN='PKG_BIN PKG_L10N_EN PKG_DATA'
PACKAGES_LIST_GOG_FR='PKG_BIN PKG_L10N_FR PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_L10N_ID="${GAME_ID}-l10n"

PKG_L10N_DE_ID="${PKG_L10N_ID}-de"
PKG_L10N_DE_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DE_DESCRIPTION='German localization'

PKG_L10N_EN_ID="${PKG_L10N_ID}-en"
PKG_L10N_EN_PROVIDE="$PKG_L10N_ID"
PKG_L10N_EN_DESCRIPTION='English localization'

PKG_L10N_ES_ID="${PKG_L10N_ID}-es"
PKG_L10N_ES_PROVIDE="$PKG_L10N_ID"
PKG_L10N_ES_DESCRIPTION='Spanish localization'

PKG_L10N_FR_ID="${PKG_L10N_ID}-fr"
PKG_L10N_FR_PROVIDE="$PKG_L10N_ID"
PKG_L10N_FR_DESCRIPTION='French localization'

PKG_L10N_IT_ID="${PKG_L10N_ID}-it"
PKG_L10N_IT_PROVIDE="$PKG_L10N_ID"
PKG_L10N_IT_DESCRIPTION='Italian localization'

PKG_L10N_PL_ID="${PKG_L10N_ID}-pl"
PKG_L10N_PL_PROVIDE="$PKG_L10N_ID"
PKG_L10N_PL_DESCRIPTION='Polish localization'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx openal"
# Keep compatibility with old archives
PKG_BIN_ARCH_GOG_EN='32'
PKG_BIN_ARCH_GOG_FR='32'
PKG_BIN_DEPS_GOG_EN="$PKG_DATA_ID $PKG_L10N_ID glibc libstdc++ glx openal"
PKG_BIN_DEPS_GOG_FR="$PKG_DATA_ID $PKG_L10N_ID glibc libstdc++ glx openal"

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

# Update list of packages to build, based on source archive

###
# TODO
# This should always be done by the library
###
use_archive_specific_value 'PACKAGES_LIST'
# shellcheck disable=SC2086
set_temp_directories $PACKAGES_LIST

# Load extra archives

ARCHIVE_MAIN="$ARCHIVE"
if [ -n "$(get_value "${ARCHIVE_MAIN}_OPTIONAL_L10N_FR")" ]; then
	set_archive 'ARCHIVE_L10N_FR' "${ARCHIVE_MAIN}_OPTIONAL_L10N_FR"
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
if [ -n "$ARCHIVE_L10N_FR" ]; then
	ARCHIVE_MAIN="$ARCHIVE"
	ARCHIVE='ARCHIVE_L10N_FR'
	extract_data_from "$ARCHIVE_L10N_FR"
	ARCHIVE="$ARCHIVE_MAIN"
fi
prepare_package_layout

# Get game icon

case "$ARCHIVE" in
	('ARCHIVE_GOG_EN_0'|'ARCHIVE_GOG_FR_0')
		###
		# TODO
		# No icon seems to be provided for some old archives
		# We could provide an optional archive including icons from other archives
		###
	;;
	(*)
		PKG='PKG_DATA'
		icons_get_from_workdir 'APP_MAIN' 'APP_SERVER'
	;;
esac
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
use_archive_specific_value 'APP_MAIN_EXE'
use_archive_specific_value 'APP_SERVER_EXE'
launchers_write 'APP_MAIN' 'APP_SERVER'

# Build packages

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

case "$ARCHIVE" in
	('ARCHIVE_GOG_EN'*|'ARCHIVE_GOG_FR'*)
		print_instructions
	;;
	(*)
		case "${LANG%_*}" in
			('fr')
				message='version %s :'
				lang_de='allemande'
				lang_en='anglaise'
				lang_es='espagnole'
				lang_fr='française'
				lang_it='italienne'
				lang_pl='polonaise'
			;;
			('en'|*)
				message='%s version:'
				lang_de='German'
				lang_en='English'
				lang_es='Spanish'
				lang_fr='French'
				lang_it='Italian'
				lang_pl='Polish'
			;;
		esac
		printf '\n'
		# shellcheck disable=SC2059
		printf "$message" "$lang_de"
		print_instructions 'PKG_L10N_DE' 'PKG_DATA' 'PKG_BIN'
		# shellcheck disable=SC2059
		printf "$message" "$lang_es"
		print_instructions 'PKG_L10N_ES' 'PKG_DATA' 'PKG_BIN'
		# shellcheck disable=SC2059
		printf "$message" "$lang_en"
		print_instructions 'PKG_DATA' 'PKG_BIN'
		# shellcheck disable=SC2059
		printf "$message" "$lang_fr"
		print_instructions 'PKG_L10N_FR' 'PKG_DATA' 'PKG_BIN'
		# shellcheck disable=SC2059
		printf "$message" "$lang_it"
		print_instructions 'PKG_L10N_IT' 'PKG_DATA' 'PKG_BIN'
		# shellcheck disable=SC2059
		printf "$message" "$lang_pl"
		print_instructions 'PKG_L10N_PL' 'PKG_DATA' 'PKG_BIN'
	;;
esac

exit 0
