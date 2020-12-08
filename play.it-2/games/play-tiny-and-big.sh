#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c)      2020, HS-157
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
# Tiny and Big: Grandpa's Leftovers
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200715.2

# Set game-specific variables

GAME_ID='tiny-and-big'
GAME_NAME="Tiny and Big: Grandpa's Leftovers"

ARCHIVE_GOG='tiny_and_big_grandpa_s_leftovers_en_1_4_2_15616.sh'
ARCHIVE_GOG_TYPE='mojosetup'
ARCHIVE_GOG_URL='https://www.gog.com/game/tiny_and_big_grandpas_leftovers'
ARCHIVE_GOG_MD5='bdcc1ea8366dedcfe00b50c439fd5ec9'
ARCHIVE_GOG_VERSION='1.4.2-gog15616'
ARCHIVE_GOG_SIZE='2400000'

ARCHIVE_HUMBLE='tinyandbig_grandpasleftovers-retail-linux-1.4.1_1370968537.tar.bz2'
ARCHIVE_HUMBLE_TYPE='tar'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/tiny-big-grandpas-leftovers'
ARCHIVE_HUMBLE_MD5='c6c2bc286f11e4a232211c5176105890'
ARCHIVE_HUMBLE_VERSION='1.4.1-humble1370968537'
ARCHIVE_HUMBLE_SIZE='2400000'

# Optional icons pack
ARCHIVE_OPTIONAL_ICONS='tiny-and-big_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_MD5='043fa61c838ba6b2ef301c52660352b1'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/games/tiny-and-big/'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 24x24 32x32 48x48 64x64'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='tinyandbig'
ARCHIVE_GAME_BIN32_FILES='bin32'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='tinyandbig'
ARCHIVE_GAME_BIN64_FILES='bin64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='tinyandbig'
ARCHIVE_GAME_DATA_FILES='assets'

CONFIG_FILES='options.txt'
DATA_FILES='*.save'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='bin32/tinyandbig'
APP_MAIN_EXE_BIN64='bin64/tinyandbig'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glx glibc libstdc++ openal sdl2"
PKG_BIN32_DEPS_ARCH='lib32-libx11'
PKG_BIN32_DEPS_DEB='libx11-6'
PKG_BIN32_DEPS_GENTOO='x11-libs/libX11[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libx11'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/libX11'

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

# Include optional icons pack

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
if [ -n "$ARCHIVE_ICONS" ]; then
	PKG='PKG_DATA'
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

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers
for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
