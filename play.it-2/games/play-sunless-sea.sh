#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
# Copyright (c) 2018-2019, BetaRays
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
# Sunless Sea + Zubmariner
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190119.1

# Set game-specific variables

GAME_ID='sunless-sea'
GAME_NAME='Sunless Sea'

ARCHIVES_LIST='ARCHIVE_GOG_ZUBMARINER ARCHIVE_GOG_ZUBMARINER_OLD0 ARCHIVE_GOG_ZUBMARINER_OLD1 ARCHIVE_GOG ARCHIVE_GOG_OLD1 ARCHIVE_GOG_OLD0 ARCHIVE_HUMBLE ARCHIVE_HUMBLE_OLD0'

ARCHIVE_GOG_ZUBMARINER='sunless_sea_zubmariner_2_2_6_3150_24613.sh'
ARCHIVE_GOG_ZUBMARINER_URL='https://www.gog.com/game/sunless_sea_zubmariner'
ARCHIVE_GOG_ZUBMARINER_TYPE='mojosetup'
ARCHIVE_GOG_ZUBMARINER_MD5='427440ff2f5e57e5e556bbaa1ffcfa7c'
ARCHIVE_GOG_ZUBMARINER_VERSION='2.2.6.3150-gog24613'
ARCHIVE_GOG_ZUBMARINER_SIZE='930000'

ARCHIVE_GOG_ZUBMARINER_OLD1='sunless_sea_zubmariner_en_v2_2_4_3141_21326.sh'
ARCHIVE_GOG_ZUBMARINER_OLD1_MD5='438471f35119ca0131971082f6eb805c'
ARCHIVE_GOG_ZUBMARINER_OLD1_VERSION='2.2.4.3141-gog21326'
ARCHIVE_GOG_ZUBMARINER_OLD1_TYPE='mojosetup'
ARCHIVE_GOG_ZUBMARINER_OLD1_SIZE='930000'

ARCHIVE_GOG_ZUBMARINER_OLD0='gog_sunless_sea_zubmariner_2.5.0.6.sh'
ARCHIVE_GOG_ZUBMARINER_OLD0_MD5='692cd0dac832d5254bd38d7e1a05b918'
ARCHIVE_GOG_ZUBMARINER_OLD0_VERSION='2.2.2.3130-gog2.5.0.6'
ARCHIVE_GOG_ZUBMARINER_OLD0_SIZE='870000'

ARCHIVE_GOG='sunless_sea_2_2_6_3150_24613.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/sunless_sea'
ARCHIVE_GOG_MD5='1ea56377e7636f354656c1f791f29a5c'
ARCHIVE_GOG_VERSION='2.2.6.3150-gog24613'
ARCHIVE_GOG_TYPE='mojosetup'
ARCHIVE_GOG_SIZE='760000'

ARCHIVE_GOG_OLD1='sunless_sea_en_v2_2_4_3141_21326.sh'
ARCHIVE_GOG_OLD1_MD5='df453a83ac1fb2767bdeafafb40f037a'
ARCHIVE_GOG_OLD1_VERSION='2.2.4.3141-gog21326'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'
ARCHIVE_GOG_OLD1_SIZE='760000'

ARCHIVE_GOG_OLD0='gog_sunless_sea_2.8.0.11.sh'
ARCHIVE_GOG_OLD0_MD5='1cf6bb7a440ce796abf8e7afcb6f7a54'
ARCHIVE_GOG_OLD0_VERSION='2.2.2.3129-gog2.8.0.11'
ARCHIVE_GOG_OLD0_SIZE='700000'

ARCHIVE_HUMBLE='Sunless_Sea_Setup_V2.2.4.3141_LINUX.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/sunless-sea'
ARCHIVE_HUMBLE_MD5='076c6784bb96e4189f675f114c98ae85'
ARCHIVE_HUMBLE_VERSION='2.2.4.3141-humble180606'
ARCHIVE_HUMBLE_SIZE='760000'

ARCHIVE_HUMBLE_OLD0='Sunless_Sea_Setup_V2.2.2.3129_LINUX.zip'
ARCHIVE_HUMBLE_OLD0_MD5='bdb37932e56fd0655a2e4263631e2582'
ARCHIVE_HUMBLE_OLD0_VERSION='2.2.2.3129-humble170131'
ARCHIVE_HUMBLE_OLD0_SIZE='700000'

ARCHIVE_DOC0_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_DOC0_DATA_PATH_HUMBLE='data/noarch'
ARCHIVE_DOC0_DATA_FILES='README.linux'

ARCHIVE_DOC1_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC1_DATA_FILES_GOG='*'

ARCHIVE_GAME0_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME0_BIN32_PATH_HUMBLE='data/noarch'
ARCHIVE_GAME0_BIN32_FILES='Sunless?Sea.x86 Sunless?Sea_Data/*/x86'

ARCHIVE_GAME1_BIN32_PATH_HUMBLE='data/x86'
ARCHIVE_GAME1_BIN32_FILES_HUMBLE='Sunless?Sea.x86 Sunless?Sea_Data/*/x86'

ARCHIVE_GAME0_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME0_BIN64_PATH_HUMBLE='data/noarch'
ARCHIVE_GAME0_BIN64_FILES='Sunless?Sea.x86_64 Sunless?Sea_Data/*/x86_64'

ARCHIVE_GAME1_BIN64_PATH_HUMBLE='data/x86_64'
ARCHIVE_GAME1_BIN64_FILES_HUMBLE='Sunless?Sea.x86_64 Sunless?Sea_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='data/noarch'
ARCHIVE_GAME_DATA_FILES='*'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Sunless Sea.x86'
APP_MAIN_EXE_BIN64='Sunless Sea.x86_64'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICONS_LIST='APP_MAIN_ICON1 APP_MAIN_ICON2'
APP_MAIN_ICON1='Sunless Sea_Data/Resources/UnityPlayer.png'
APP_MAIN_ICON2='Icon.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_PROVIDE="$PKG_DATA_ID"
PKG_DATA_DESCRIPTION='data'
# Use different package name and description when including Zubmariner DLC
PKG_DATA_ID_GOG_ZUBMARINER="${GAME_ID}-zubmariner-data"
PKG_DATA_DESCRIPTION_GOG_ZUBMARINER='data (including Zubmariner DLC)'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glu xcursor"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	: ${XDG_DATA_HOME:="$HOME/.local/share"}
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
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
case "$ARCHIVE" in
	('ARCHIVE_HUMBLE'*)
		eval ${ARCHIVE}_TYPE=\'mojosetup\'
		archive="$PLAYIT_WORKDIR/gamedata/Sunless Sea.sh"
		extract_data_from "$archive"
		rm "$archive"
	;;
esac
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
