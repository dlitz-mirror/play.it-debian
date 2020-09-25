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
# 1365
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200912.2

# Set game-specific variables

GAME_ID='1365-game'
GAME_NAME='1365'

ARCHIVES_LIST='
ARCHIVE_ITCH_0
'

ARCHIVE_ITCH_0='1365 Linux 1.0'
ARCHIVE_ITCH_0_MD5='8cb8fb11a2df4af72154f2909238c09c'
ARCHIVE_ITCH_0_URL='https://shadybug.itch.io/1365'
ARCHIVE_ITCH_0_SIZE='32000'
ARCHIVE_ITCH_0_VERSION='1.0.0-itch1'
ARCHIVE_ITCH_0_TYPE='file'

# Optional icons pack
ARCHIVE_OPTIONAL_ICONS='1356_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_MD5='f820888c924fed091c5d64d9aaa2d467'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/games/1365/'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='256x256 512x512'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='1365 Linux 1.0'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ARCH='32'
PKG_MAIN_DEPS="glibc glx xcursor libxrandr alsa"
PKG_MAIN_DEPS_ARCH='lib32-libx11 lib32-libxinerama lib32-libpulse'
PKG_MAIN_DEPS_DEB='libx11-6, libxinerama1, libpulse0, libxi6'
PKG_MAIN_DEPS_GENTOO='x11-libs/libX11[abi_x86_32] x11-libs/libXinerama[abi_x86_32] media-sound/pulseaudio[abi_x86_32]'

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
	(
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
	organize_data 'ICONS' "$PATH_ICON_BASE"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
else
	case "${LANG%_*}" in
		('fr')
			message='Lʼarchive suivante nʼayant pas été fournie, lʼentrée de menu utilisera une icône générique : %s\n'
			message="$message"'Cette archive peut être téléchargée depuis %s\n'
		;;
		('en'|*)
			message='Due to the following archive missing, the menu entry will use a generic icon: %s\n'
			message="$message"'This archive can be downloaded from %s\n'
		;;
	esac
	print_warning
	printf "$message" "$ARCHIVE_OPTIONAL_ICONS" "$ARCHIVE_OPTIONAL_ICONS_URL"
	printf '\n'
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

mkdir --parents "${PKG_MAIN_PATH}${PATH_GAME}"
cp "$SOURCE_ARCHIVE" "${PKG_MAIN_PATH}${PATH_GAME}/1365 Linux 1.0"

# Write launchers

launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
