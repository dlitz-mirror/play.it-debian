#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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
# Crypt of the Necrodancer
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200930.1

# Set game-specific variables

GAME_ID='crypt-of-the-necrodancer'
GAME_NAME='Crypt of the NecroDancer'

ARCHIVES_LIST='
ARCHIVE_GOG_3
ARCHIVE_GOG_2
ARCHIVE_GOG_1
ARCHIVE_GOG_0'

ARCHIVE_GOG_3='crypt_of_the_necrodancer_en_1_29_14917.sh'
ARCHIVE_GOG_3_URL='https://www.gog.com/game/crypt_of_the_necrodancer'
ARCHIVE_GOG_3_MD5='70d3e29a2a48901d02541d8b1c6326ba'
ARCHIVE_GOG_3_SIZE='1600000'
ARCHIVE_GOG_3_VERSION='1.29-gog14917'
ARCHIVE_GOG_3_TYPE='mojosetup'

ARCHIVE_GOG_2='gog_crypt_of_the_necrodancer_2.4.0.7.sh'
ARCHIVE_GOG_2_MD5='a8c21ce12e7e4c769aaddd76321672e4'
ARCHIVE_GOG_2_SIZE='1700000'
ARCHIVE_GOG_2_VERSION='1.28-gog2.4.0.7'

ARCHIVE_GOG_1='gog_crypt_of_the_necrodancer_2.3.0.6.sh'
ARCHIVE_GOG_1_MD5='bece155772937aa32d2b4eba3aac0dd0'
ARCHIVE_GOG_1_SIZE='1500000'
ARCHIVE_GOG_1_VERSION='1.27-gog2.3.0.6'

ARCHIVE_GOG_0='gog_crypt_of_the_necrodancer_2.3.0.5.sh'
ARCHIVE_GOG_0_MD5='8a6e7c3d26461aa2fa959b8607e676f7'
ARCHIVE_GOG_0_SIZE='1500000'
ARCHIVE_GOG_0_VERSION='1.27-gog2.3.0.5'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game/'
ARCHIVE_DOC1_DATA_FILES='license.txt'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='NecroDancer essentia* fmod libavcodec.so.53 libavformat.so.53 libavutil.so.51 libfftw3f.so.3 libglfw.so.2 libgsm.so.1 libsamplerate.so.0 libschroedinger-1.0.so.0 libtag.so.1 libyaml-0.so.2'

ARCHIVE_GAME_MUSIC_PATH='data/noarch/game'
ARCHIVE_GAME_MUSIC_FILES='data/music'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='data'

DATA_DIRS='./data/custom_music ./downloaded_dungeons ./downloaded_mods ./logs ./mods ./replays'
DATA_FILES='data/save_data.xml data/played.dat'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='.'
APP_MAIN_EXE='NecroDancer'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_MUSIC PKG_DATA PKG_BIN'

PKG_MUSIC_ID="${GAME_ID}-music"
PKG_MUSIC_DESCRIPTION='music'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_PROVIDE="${GAME_ID}-video"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_MUSIC_ID $PKG_DATA_ID glibc libstdc++ glx libxrandr openal vorbis"

# Optional icons pack

ARCHIVE_OPTIONAL_ICONS='crypt-of-the-necrodancer_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_MD5='04d2bb19adc13dbadce6161bd92bf59a'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/resources/crypt-of-the-necrodancer/'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 32x32 128x128 256x256'

# Load common functions

target_version='2.12'

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

# Include optional icons pack

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
if [ -n "$ARCHIVE_ICONS" ]; then
	unset APP_MAIN_ICON
	PKG='PKG_DATA'
	(
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
	organize_data 'ICONS' "$PATH_ICON_BASE"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Include game icon

if [ -z "$ARCHIVE_ICONS" ]; then
	PKG='PKG_DATA'
	icons_get_from_workdir 'APP_MAIN'
fi

# Clean up temporary files

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
