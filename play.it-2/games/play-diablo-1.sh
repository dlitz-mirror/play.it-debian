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
# Diablo
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210418.8

# Set game-specific variables

GAME_ID='diablo-1'
GAME_NAME='Diablo'

ARCHIVES_LIST='
ARCHIVE_BASE_5
ARCHIVE_BASE_4
ARCHIVE_BASE_3
ARCHIVE_BASE_2
ARCHIVE_BASE_1
ARCHIVE_BASE_0'

ARCHIVE_BASE_5='setup_diablo_1.09_hellfire_v2_(30038).exe'
ARCHIVE_BASE_5_URL='https://www.gog.com/game/diablo'
ARCHIVE_BASE_5_TYPE='innosetup'
ARCHIVE_BASE_5_MD5='e70187d92fa120771db99dfa81679cfc'
ARCHIVE_BASE_5_VERSION='1.09-gog30038'
ARCHIVE_BASE_5_SIZE='850000'

ARCHIVE_BASE_4='setup_diablo_1.09_v6_(28378).exe'
ARCHIVE_BASE_4_TYPE='innosetup'
ARCHIVE_BASE_4_MD5='588ab50c1ef25abb682b86ea4306ea50'
ARCHIVE_BASE_4_VERSION='1.09-gog28378'
ARCHIVE_BASE_4_SIZE='670000'

ARCHIVE_BASE_3='setup_diablo_1.09_v4_(27989).exe'
ARCHIVE_BASE_3_TYPE='innosetup'
ARCHIVE_BASE_3_MD5='8dac74a616646fa41d5d73f4765cef40'
ARCHIVE_BASE_3_VERSION='1.09-gog27989'
ARCHIVE_BASE_3_SIZE='670000'

ARCHIVE_BASE_2='setup_diablo_1.09_v3_(27965).exe'
ARCHIVE_BASE_2_TYPE='innosetup'
ARCHIVE_BASE_2_MD5='38d654af858d7a2591711f0e6324fcd0'
ARCHIVE_BASE_2_VERSION='1.09-gog27695'
ARCHIVE_BASE_2_SIZE='670000'

ARCHIVE_BASE_1='setup_diablo_1.09_v2_(27882).exe'
ARCHIVE_BASE_1_TYPE='innosetup'
ARCHIVE_BASE_1_MD5='83b2d6b8551a9825a426dac7b9302654'
ARCHIVE_BASE_1_VERSION='1.09-gog27882'
ARCHIVE_BASE_1_SIZE='670000'

ARCHIVE_BASE_0='setup_diablo_1.09_(27873).exe'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_MD5='bf57594f5218a794a284b5e2a0f5ba14'
ARCHIVE_BASE_0_VERSION='1.09-gog27873'
ARCHIVE_BASE_0_SIZE='680000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.pdf license.txt patch.txt readme.txt update.txt README.txt'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='diabdat.mpq'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='devilutionx'
APP_MAIN_ICON='diablo.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc sdl2_mixer sdl2 glx libudev1"
PKG_BIN_DEPS_ARCH='sdl2_ttf'
PKG_BIN_DEPS_DEB='libsdl2-ttf-2.0-0'
PKG_BIN_DEPS_GENTOO='media-libs/sdl2-ttf'

# DevilutionX 1.2.1 release

###
# TODO
# Archive type is explicitely set as "tar"
# This will no longer be required once the following update is included in a ./play.it release:
# https://forge.dotslashplay.it/play.it/scripts/-/merge_requests/1309
###

ARCHIVE_REQUIRED_DEVILUTIONX='devilutionx-linux-x86_64.tar.xz'
ARCHIVE_REQUIRED_DEVILUTIONX_MD5='b63937bb282604893be9b66417a143d4'
ARCHIVE_REQUIRED_DEVILUTIONX_TYPE='tar'
ARCHIVE_REQUIRED_DEVILUTIONX_URL='https://github.com/diasurgical/devilutionX/releases/tag/1.2.1'

ARCHIVE_DOC_DEVILUTIONX_DATA_PATH='.'
ARCHIVE_DOC_DEVILUTIONX_DATA_FILES='*.txt'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='devilutionx'

ARCHIVE_GAME_DEVILUTIONX_DATA_PATH='.'
ARCHIVE_GAME_DEVILUTIONX_DATA_FILES='devilutionx.mpq'

ARCHIVE_FONT_DATA_PATH='.'
ARCHIVE_FONT_DATA_FILES='CharisSILB.ttf'

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

# Check presence of devilutionX archive

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_DEVILUTIONX' 'ARCHIVE_REQUIRED_DEVILUTIONX'
[ "$ARCHIVE_DEVILUTIONX" ] || archive_set_error_not_found 'ARCHIVE_REQUIRED_DEVILUTIONX'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

(
	ARCHIVE='ARCHIVE_DEVILUTIONX'
	extract_data_from "$ARCHIVE_DEVILUTIONX"
)
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Include devilutionX-provided CharisSILB font

###
# TODO
# PATH_FONTS should be set by the library
###

PKG='PKG_DATA'
PATH_FONTS="${OPTION_PREFIX}/share/fonts/truetype/${GAME_ID}"
organize_data 'FONT_DATA' "$PATH_FONTS"
APP_MAIN_OPTIONS="${APP_MAIN_OPTIONS} --ttf-dir ${PATH_FONTS}"

# Include devilutionX documentation

PKG='PKG_DATA'
organize_data 'DOC_DEVILUTIONX_DATA' "$PATH_DOC/devilutionx"

# Include devilutionX assets

PKG='PKG_DATA'
organize_data 'GAME_DEVILUTIONX_DATA' "$PATH_GAME"

# Extract icons

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
