#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Solène "Mopi" Huault
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
# Never Alone
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200204.3

# Set game-specific variables

GAME_ID='never-alone'
GAME_NAME='Never Alone'

ARCHIVE_HUMBLE='NeverAlone_ArcticCollection_Linux.1.04.tar.gz'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/never-alone-arctic-collection'
ARCHIVE_HUMBLE_MD5='3da062abaaa9e3e6ff97d4c82c8ea3c3'
ARCHIVE_HUMBLE_SIZE='4900000'
ARCHIVE_HUMBLE_VERSION='1.04-humble161008'

ARCHIVE_OPTIONAL_MESAFIX='neveralonefix.c'
ARCHIVE_OPTIONAL_MESAFIX_URL='https://github.com/dscharrer/void/blob/master/hacks/neveralonefix.c'
ARCHIVE_OPTIONAL_MESAFIX_MD5='61898247276ec22c30ff83a887aff819'
ARCHIVE_OPTIONAL_MESAFIX_TYPE='file'

ARCHIVE_GAME_BIN_PATH='NeverAlone_ArcticCollection_Linux.1.04'
ARCHIVE_GAME_BIN_FILES='Never_Alone.x64 Never_Alone_Data/Mono Never_Alone_Data/Plugins'

ARCHIVE_GAME_VIDEOS_PATH='NeverAlone_ArcticCollection_Linux.1.04'
ARCHIVE_GAME_VIDEOS_FILES='Never_Alone_Data/StreamingAssets/Videos'

ARCHIVE_GAME_DATA_PATH='NeverAlone_ArcticCollection_Linux.1.04'
ARCHIVE_GAME_DATA_FILES='Never_Alone_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN_MESAFIX='# Load dscharrerʼs hack to work around shadows rendering issue
APP_OPTIONS="./$APP_EXE $APP_OPTIONS"
APP_EXE="neveralonefix.c"
if [ -h "neveralonefix.c" ]; then
	hack_path=$(realpath "neveralonefix.c")
	rm "neveralonefix.c"
	cp "$hack_path" "neveralonefix.c"
fi'
APP_MAIN_EXE='Never_Alone.x64'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='Never_Alone_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_VIDEOS PKG_DATA PKG_BIN'

PKG_VIDEOS_ID="$GAME_ID-videos"
PKG_VIDEOS_DESCRIPTION='videos'

PKG_DATA_ID="$GAME_ID-data"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DEPS="$PKG_VIDEOS_ID"

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glu glx xcursor"
PKG_BIN_DEPS_ARCH='libx11'
PKG_BIN_DEPS_DEB='libx11-6'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11'
# Extra dependencies required to build dscharrerʼs Mesa hack
PKG_BIN_DEPS_ARCH_MESAFIX="$PKG_BIN_DEPS_ARCH gcc mesa pkgconf"
PKG_BIN_DEPS_DEB_MESAFIX="$PKG_BIN_DEPS_DEB, gcc, libgl-dev | libgl1-mesa-dev, libglvnd-dev | libgl1-mesa-dev, pkg-config"
PKG_BIN_DEPS_GENTOO_MESAFIX="$PKG_BIN_DEPS_GENTOO sys-devel/gcc media-libs/mesa dev-util/pkgconfig"

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

# Load dscharrerʼs Mesa fix if available

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_MESAFIX' 'ARCHIVE_OPTIONAL_MESAFIX'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Include dscharrerʼs Mesa fix

if [ -n "$ARCHIVE_MESAFIX" ]; then
	cp "$ARCHIVE_MESAFIX" "${PKG_BIN_PATH}${PATH_GAME}/neveralonefix.c"
	chmod 755 "${PKG_BIN_PATH}${PATH_GAME}/neveralonefix.c"
	APP_MAIN_PRERUN="$APP_MAIN_PRERUN_MESAFIX"
	PKG_BIN_DEPS_ARCH="$PKG_BIN_DEPS_ARCH_MESAFIX"
	PKG_BIN_DEPS_DEB="$PKG_BIN_DEPS_DEB_MESAFIX"
	PKG_BIN_DEPS_GENTOO="$PKG_BIN_DEPS_GENTOO_MESAFIX"
fi

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
