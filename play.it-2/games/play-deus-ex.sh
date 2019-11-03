#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2017-2019, Phil Morrell
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
# Deus Ex
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20191103.1

# Set game-specific variables

GAME_ID='deus-ex'
GAME_NAME='Deus Ex'

ARCHIVE_GOG='setup_deus_ex_goty_1.112fm(revision_1.4)_(21273).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/deus_ex'
ARCHIVE_GOG_MD5='9ec295ecad72e96fb7b9f0109dd90324'
ARCHIVE_GOG_VERSION='1.112fm-gog21273'
ARCHIVE_GOG_SIZE='750000'
ARCHIVE_GOG_TYPE='innosetup1.7'

ARCHIVE_GOG_OLD4='setup_deus_ex_goty_1.112fm(revision_1.3.1)_(17719).exe'
ARCHIVE_GOG_OLD4_MD5='92e9e6a33642f9e6c41cb24055df9b3c'
ARCHIVE_GOG_OLD4_VERSION='1.112fm-gog17719'
ARCHIVE_GOG_OLD4_SIZE='750000'

ARCHIVE_GOG_OLD3='setup_deus_ex_goty_1.112fm(revision_1.3.0.1)_(16231).exe'
ARCHIVE_GOG_OLD3_MD5='eaaf7c7c3052fbf71f5226e2d4495268'
ARCHIVE_GOG_OLD3_VERSION='1.112fm-gog16231'
ARCHIVE_GOG_OLD3_SIZE='750000'

ARCHIVE_GOG_OLD2='setup_deus_ex_goty_1.112fm(revision_1.2.2)_(15442).exe'
ARCHIVE_GOG_OLD2_MD5='573582142424ba1b5aba1f6727276450'
ARCHIVE_GOG_OLD2_VERSION='1.112fm-gog15442'
ARCHIVE_GOG_OLD2_SIZE='750000'

ARCHIVE_GOG_OLD1='setup_deus_ex_2.1.0.12.exe'
ARCHIVE_GOG_OLD1_MD5='cc2c6e43b2e8e67c7586bbab5ef492ee'
ARCHIVE_GOG_OLD1_VERSION='1.112fm-gog2.1.0.12'
ARCHIVE_GOG_OLD1_SIZE='750000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='./manual.pdf ./system/*.txt'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_OLD1='app'
ARCHIVE_DOC_DATA_PATH_GOG_OLD2='app'
ARCHIVE_DOC_DATA_PATH_GOG_OLD3='app'
ARCHIVE_DOC_DATA_PATH_GOG_OLD4='app'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='./system/*.dll ./system/*.exe ./system/*.ini ./system/*.int'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_OLD1='app'
ARCHIVE_GAME_BIN_PATH_GOG_OLD2='app'
ARCHIVE_GAME_BIN_PATH_GOG_OLD3='app'
ARCHIVE_GAME_BIN_PATH_GOG_OLD4='app'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='./system/*.u ./help ./maps ./music ./sounds ./textures'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_GOG_OLD1='app'
ARCHIVE_GAME_DATA_PATH_GOG_OLD2='app'
ARCHIVE_GAME_DATA_PATH_GOG_OLD3='app'
ARCHIVE_GAME_DATA_PATH_GOG_OLD4='app'

CONFIG_FILES='./system/*.ini'
DATA_DIRS='./save'
DATA_FILES='./system/*.log'

APP_MAIN_TYPE='wine'
APP_MAIN_PRERUN="# store gamma values to restore them after quitting the game
rgamma=\$(xgamma 2>&1|sed 's/->//'|cut -d',' -f1|awk '{print \$2}')
ggamma=\$(xgamma 2>&1|sed 's/->//'|cut -d',' -f2|awk '{print \$2}')
bgamma=\$(xgamma 2>&1|sed 's/->//'|cut -d',' -f3|awk '{print \$2}')"
# shellcheck disable=SC2016
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# run the game binary from its container directory
cd "${APP_EXE%/*}"
APP_EXE="${APP_EXE##*/}"'
# shellcheck disable=SC2016
APP_MAIN_POSTRUN='xgamma -rgamma $rgamma -ggamma $ggamma -bgamma $bgamma'
APP_MAIN_EXE='system/deusex.exe'
APP_MAIN_ICON='system/deusex.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine xgamma glx libxrandr"

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

# Extract icons

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
