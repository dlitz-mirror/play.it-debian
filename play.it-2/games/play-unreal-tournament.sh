#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2017-2020, Phil Morrell
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
# Unreal Tournament
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200221.1

# Set game-specific variables

GAME_ID='unreal-tournament'
GAME_NAME='Unreal Tournament'

ARCHIVE_GOG='setup_ut_goty_2.0.0.5.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/unreal_tournament_goty'
ARCHIVE_GOG_MD5='0d25ec835648710a098aff7106187f38'
ARCHIVE_GOG_TYPE='innosetup_nolowercase'
ARCHIVE_GOG_SIZE='640000'
ARCHIVE_GOG_VERSION='451-gog2.0.0.5'

ARCHIVE_REQUIRED_ENGINE='ut99v451-linux.2019-07-21.tar.gz'
ARCHIVE_REQUIRED_ENGINE_URL='https://downloads.dotslashplay.it/resources/unreal-tournament/'
ARCHIVE_REQUIRED_ENGINE_MD5='6cf7b84c8ce719a74d1c7724152d5c70'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='Help/* Manual/manual.pdf'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='System/*-bin System/*.so*'

ARCHIVE_GAME0_DATA_PATH='app'
ARCHIVE_GAME0_DATA_FILES='Maps Music Sounds Textures Web System/*.ini System/*.u System/*.int'

ARCHIVE_GAME1_DATA_PATH='.'
ARCHIVE_GAME1_DATA_FILES='Web System/*.ini System/*.u System/*.int'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Make sure game configuration is set to an user-owned existing directory
export UT_PREFS="$HOME/.loki/ut"
mkdir --parents "$UT_PREFS/System"'
# shellcheck disable=SC2016
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Run the game binary from its parent directory
cd "$(dirname "$APP_EXE")"
APP_EXE="$(basename "$APP_EXE")"'
APP_MAIN_EXE='System/ut-bin'
APP_MAIN_ICON='app/System/UnrealTournament.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ sdl1.2 glx"
PKG_BIN_DEPS_ARCH='pulseaudio lib32-libpulse'
PKG_BIN_DEPS_DEB='pulseaudio:amd64 | pulseaudio, libpulsedsp'

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

# Check presence of native engine archive

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_ENGINE' 'ARCHIVE_REQUIRED_ENGINE'
[ "$ARCHIVE_ENGINE" ] || archive_set_error_not_found 'ARCHIVE_REQUIRED_ENGINE'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include native engine

ARCHIVE='ARCHIVE_ENGINE' \
	extract_data_from "$ARCHIVE_ENGINE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
case $OPTION_PACKAGE in
	('arch')
		APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
		# Start pulseaudio
		pulseaudio --start
		export LD_PRELOAD="/usr/lib32/pulseaudio/libpulsedsp.so"'
	;;
	('deb')
		APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
		# Start pulseaudio
		pulseaudio --start
		export LD_PRELOAD="/usr/lib/i386-linux-gnu/pulseaudio/libpulsedsp.so"'
	;;
	('gentoo')
		# Nothing to do here, Gentoo use the basic pre-run script
	;;
	(*)
		liberror 'OPTION_PACKAGE' "$0"
	;;
esac
launchers_write 'APP_MAIN'

# Work around a crash of the host of multiplayer games on map transitions

pattern='s/\(^bWorldLog\)=.*/\1=False/'
file="${PKG_DATA_PATH}${PATH_GAME}/System/UnrealTournament.ini"
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place "$pattern" "$file"
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
