#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2020, Mopi
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
# Faster Than Light
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201123.1

# Set game-specific variables

GAME_ID='faster-than-light'
GAME_NAME='Faster Than Light'

ARCHIVES_LIST='
ARCHIVE_GOG_6
ARCHIVE_GOG_5
ARCHIVE_GOG_4
ARCHIVE_GOG_3
ARCHIVE_GOG_2
ARCHIVE_GOG_1
ARCHIVE_GOG_0
ARCHIVE_HUMBLE_2
ARCHIVE_HUMBLE_1
ARCHIVE_HUMBLE_0
ARCHIVE_SDL1_GOG_0
ARCHIVE_SDL1_HUMBLE_0
'

ARCHIVE_GOG_6='ftl_advanced_edition_1_6_12_2_35269.sh'
ARCHIVE_GOG_6_URL='https://www.gog.com/game/faster_than_light'
ARCHIVE_GOG_6_MD5='fc012e9ac7515f0b7b119a73ccfd7190'
ARCHIVE_GOG_6_SIZE='410000'
ARCHIVE_GOG_6_VERSION='1.6.12.2-gog35269'
ARCHIVE_GOG_6_TYPE='mojosetup'

ARCHIVE_GOG_5='ftl_advanced_edition_1_6_12_2_34795.sh'
ARCHIVE_GOG_5_MD5='d62355fc9339cd901242fc1828e8c248'
ARCHIVE_GOG_5_SIZE='410000'
ARCHIVE_GOG_5_VERSION='1.6.12.2-gog34795'
ARCHIVE_GOG_5_TYPE='mojosetup'

ARCHIVE_GOG_4='ftl_advanced_edition_1_6_9_25330.sh'
ARCHIVE_GOG_4_MD5='c3598ab0c07d1f038eb1642da066b6a5'
ARCHIVE_GOG_4_SIZE='230000'
ARCHIVE_GOG_4_VERSION='1.6.9-gog25330'
ARCHIVE_GOG_4_TYPE='mojosetup'

ARCHIVE_GOG_3='ftl_advanced_edition_1_6_8_24110.sh'
ARCHIVE_GOG_3_MD5='4d654aeca32de557c109fa5c642ff455'
ARCHIVE_GOG_3_SIZE='230000'
ARCHIVE_GOG_3_VERSION='1.6.8-gog24110'
ARCHIVE_GOG_3_TYPE='mojosetup'

ARCHIVE_GOG_2='ftl_advanced_edition_1_6_7_24012.sh'
ARCHIVE_GOG_2_MD5='43392da0d11548b1c16f1263fc5fad65'
ARCHIVE_GOG_2_SIZE='230000'
ARCHIVE_GOG_2_VERSION='1.6.8-gog24012'
ARCHIVE_GOG_2_TYPE='mojosetup'

ARCHIVE_GOG_1='ftl_advanced_edition_en_1_6_7_18662.sh'
ARCHIVE_GOG_1_MD5='2c5254547639b7718dac7a06dabd1d82'
ARCHIVE_GOG_1_SIZE='210000'
ARCHIVE_GOG_1_VERSION='1.6.7-gog18662'
ARCHIVE_GOG_1_TYPE='mojosetup'

ARCHIVE_GOG_0='ftl_advanced_edition_en_1_6_3_17917.sh'
ARCHIVE_GOG_0_MD5='b64692d5302a1ab60d912c5eb5fbc5e4'
ARCHIVE_GOG_0_SIZE='210000'
ARCHIVE_GOG_0_VERSION='1.6.3-gog17917'
ARCHIVE_GOG_0_TYPE='mojosetup'

ARCHIVE_HUMBLE_2='FTL.1.6.12.Linux.zip'
ARCHIVE_HUMBLE_2_URL='https://www.humblebundle.com/store/ftl-faster-than-light'
ARCHIVE_HUMBLE_2_MD5='4ee7ea561d7753c8a003570364e15311'
ARCHIVE_HUMBLE_2_SIZE='410000'
ARCHIVE_HUMBLE_2_VERSION='1.6.12-humble191220'

ARCHIVE_HUMBLE_1='FTL.1.6.9.tar.gz'
ARCHIVE_HUMBLE_1_MD5='c70d9cbc55217a5f83e0d51189240ec2'
ARCHIVE_HUMBLE_1_SIZE='230000'
ARCHIVE_HUMBLE_1_VERSION='1.6.9-humble181120'

ARCHIVE_HUMBLE_0='FTL-linux-1.6.8.tar.gz'
ARCHIVE_HUMBLE_0_MD5='5898d476dae289dae20d93ecfc1b8390'
ARCHIVE_HUMBLE_0_SIZE='230000'
ARCHIVE_HUMBLE_0_VERSION='1.6.8-humble180928'

ARCHIVE_SDL1_GOG_0='gog_ftl_advanced_edition_2.0.0.2.sh'
ARCHIVE_SDL1_GOG_0_MD5='2c24b70b31316acefedc082e9441a69a'
ARCHIVE_SDL1_GOG_0_SIZE='220000'
ARCHIVE_SDL1_GOG_0_VERSION='1.5.13-gog2.0.0.2'

ARCHIVE_SDL1_HUMBLE_0='FTL.1.5.13.tar.gz'
ARCHIVE_SDL1_HUMBLE_0_MD5='791e0bc8de73fcdcd5f461a4548ea2d8'
ARCHIVE_SDL1_HUMBLE_0_SIZE='220000'
ARCHIVE_SDL1_HUMBLE_0_VERSION='1.5.13-humble140602'

ARCHIVE_DOC0_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC0_DATA_PATH_HUMBLE='FTL.1.6.12.Linux'
ARCHIVE_DOC0_DATA_FILES='*.html *.txt'
# Keep compatibility with old archives
ARCHIVE_DOC0_DATA_PATH_HUMBLE_1='FTL-linux'
ARCHIVE_DOC0_DATA_PATH_HUMBLE_0='FTL-linux'
ARCHIVE_DOC0_DATA_PATH_SDL1_HUMBLE='FTL'

ARCHIVE_DOC1_DATA_PATH_GOG='data/noarch/game/data'
ARCHIVE_DOC1_DATA_PATH_HUMBLE='FTL.1.6.12.Linux/data'
ARCHIVE_DOC1_DATA_FILES='licenses'
# Keep compatibility with old archives
ARCHIVE_DOC1_DATA_PATH_HUMBLE_1='FTL-linux/data'
ARCHIVE_DOC1_DATA_PATH_HUMBLE_0='FTL-linux/data'
ARCHIVE_DOC1_DATA_PATH_SDL1_HUMBLE='FTL/data'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game/data'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='FTL.1.6.12.Linux/data'
ARCHIVE_GAME_BIN32_FILES='FTL.x86'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN32_PATH_HUMBLE_1='FTL-linux/data'
ARCHIVE_GAME_BIN32_PATH_HUMBLE_0='FTL-linux/data'
ARCHIVE_GAME_BIN32_PATH_SDL1_HUMBLE='FTL/data'
ARCHIVE_GAME_BIN32_FILES_SDL1='x86'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game/data'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='FTL.1.6.12.Linux/data'
ARCHIVE_GAME_BIN64_FILES='FTL.amd64'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN64_PATH_HUMBLE_1='FTL-linux/data'
ARCHIVE_GAME_BIN64_PATH_HUMBLE_0='FTL-linux/data'
ARCHIVE_GAME_BIN64_PATH_SDL1_HUMBLE='FTL/data'
ARCHIVE_GAME_BIN64_FILES_SDL1='amd64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game/data'
ARCHIVE_GAME_DATA_PATH_HUMBLE='FTL.1.6.12.Linux/data'
ARCHIVE_GAME_DATA_FILES='exe_icon.bmp ftl.dat'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_PATH_HUMBLE_1='FTL-linux/data'
ARCHIVE_GAME_DATA_PATH_HUMBLE_0='FTL-linux/data'
ARCHIVE_GAME_DATA_PATH_SDL1_HUMBLE='FTL/data'
ARCHIVE_GAME_DATA_FILES_SDL1='exe_icon.bmp resources'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='export LANG=C'
APP_MAIN_EXE_BIN32='FTL.x86'
APP_MAIN_EXE_BIN64='FTL.amd64'
APP_MAIN_ICON='exe_icon.bmp'

# Pre-1.6 launcher - common properties
APP_SDL1_ICONS_LIST='APP_SDL1_ICON_0 APP_SDL1_ICON_1'
APP_SDL1_ICON_0='exe_icon.bmp'
APP_SDL1_ICON_1='resources/exe_icon.bmp'

# Pre-1.6 launcher - 32-bit
APP_SDL1_LIBS_BIN32='x86/lib'
APP_SDL1_EXE_BIN32='x86/bin/FTL'

# Pre-1.6 launcher - 64-bit
APP_SDL1_LIBS_BIN64='amd64/lib'
APP_SDL1_EXE_BIN64='amd64/bin/FTL'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc glx alsa"
# Keep compatibility with old archives
PKG_BIN32_DEPS_SDL1="$PKG_DATA_ID glibc sdl glu"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
# Keep compatibility with old archives
PKG_BIN64_DEPS_SDL1="$PKG_BIN32_DEPS_SDL1"

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
case "$ARCHIVE" in
	('ARCHIVE_SDL1_HUMBLE'*|'ARCHIVE_HUMBLE'*)
		set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
	;;
esac
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Set launcher properties based on archive

case "$ARCHIVE" in
	('ARCHIVE_SDL1'*)
		APPLICATION='APP_SDL1'
	;;
	(*)
		APPLICATION='APP_MAIN'
	;;
esac

# Extract icons

PKG='PKG_DATA'
icons_get_from_package "$APPLICATION"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write "$APPLICATION"
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
