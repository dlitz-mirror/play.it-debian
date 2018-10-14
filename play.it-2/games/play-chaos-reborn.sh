#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# Chaos Reborn
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180926.3

# Set game-specific variables

GAME_ID='chaos-reborn'
GAME_NAME='Chaos Reborn'

ARCHIVE_GOG='chaos_reborn_en_1_13_3_23004.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/chaos_reborn'
ARCHIVE_GOG_MD5='283d60b5adf91640679d2fe1c7962300'
ARCHIVE_GOG_SIZE='1700000'
ARCHIVE_GOG_TYPE='mojosetup'
ARCHIVE_GOG_VERSION='1.13.3-gog23004'

ARCHIVE_GOG_OLD3='chaos_reborn_en_1_13_2_17223.sh'
ARCHIVE_GOG_OLD3_MD5='edb60d98710c87c0adea06f55be99567'
ARCHIVE_GOG_OLD3_SIZE='1700000'
ARCHIVE_GOG_OLD3_TYPE='mojosetup'
ARCHIVE_GOG_OLD3_VERSION='1.13.2-gog17223'

ARCHIVE_GOG_OLD2='chaos_reborn_en_1_131_14290.sh'
ARCHIVE_GOG_OLD2_MD5='fcfea11ad6a6cbdda2290c4f29bbeb2b'
ARCHIVE_GOG_OLD2_SIZE='1700000'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'
ARCHIVE_GOG_OLD2_VERSION='1.13.1-gog14290'

ARCHIVE_GOG_OLD1='gog_chaos_reborn_2.14.0.16.sh'
ARCHIVE_GOG_OLD1_MD5='97dbfc0a679a7fd104c744b6aa46db36'
ARCHIVE_GOG_OLD1_SIZE='1700000'
ARCHIVE_GOG_OLD1_VERSION='1.13-gog2.14.0.16'

ARCHIVE_GOG_OLD0='gog_chaos_reborn_2.13.0.15.sh'
ARCHIVE_GOG_OLD0_MD5='a2abf12572eea8b43059a9bb8d5d3171'
ARCHIVE_GOG_OLD0_SIZE='1700000'
ARCHIVE_GOG_OLD0_VERSION='1.12.2-gog2.13.0.15'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game'
ARCHIVE_DOC1_DATA_FILES='*.txt'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='*.x86 *_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='*.x86_64 *_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='*_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='file="$HOME/.config/unity3d/Snapshot Games Inc_/Chaos Reborn/prefs"
if [ ! -e "$file" ]; then
	mkdir --parents "${file%/*}"
	cat > "$file" <<- EOF
		<unity_prefs version_major="1" version_minor="1">
		<pref name="Screenmanager Is Fullscreen mode" type="int">0</pref>
		</unity_prefs>
	EOF
fi'
APP_MAIN_EXE_BIN32='ChaosRebornLinux.x86'
APP_MAIN_EXE_BIN64='ChaosRebornLinux.x86_64'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='ChaosRebornLinux_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glu gtk2"

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
