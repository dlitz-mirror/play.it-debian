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
# Neverwinter Nights
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180904.1

# Set game-specific variables

GAME_ID='neverwinter-nights'
GAME_NAME='Neverwinter Nights'

ARCHIVES_LIST='ARCHIVE_GOG_DE ARCHIVE_GOG_EN ARCHIVE_GOG_ES ARCHIVE_GOG_FR ARCHIVE_GOG_PL'

ARCHIVE_GOG_DE='setup_nwn_diamond_german_2.1.0.21.exe'
ARCHIVE_GOG_DE_URL='https://www.gog.com/game/neverwinter_nights_diamond_edition'
ARCHIVE_GOG_DE_MD5='63a32f4fdb2939e73ac40d80f5798e28'
ARCHIVE_GOG_DE_TYPE='rar'
ARCHIVE_GOG_DE_SIZE='4400000'
ARCHIVE_GOG_DE_VERSION='1.68-gog2.1.0.21'
ARCHIVE_GOG_DE_PART1='setup_nwn_diamond_german_2.1.0.21-1.bin'
ARCHIVE_GOG_DE_PART1_MD5='e6c50d030b046c05ccf87601844ccc23'
ARCHIVE_GOG_DE_PART1_TYPE='rar'

ARCHIVE_GOG_EN='setup_nwn_diamond_2.1.0.21.exe'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/neverwinter_nights_diamond_edition'
ARCHIVE_GOG_EN_MD5='cd809b9d22022adb01b0d1d70c5afa8e'
ARCHIVE_GOG_EN_TYPE='rar'
ARCHIVE_GOG_EN_SIZE='5100000'
ARCHIVE_GOG_EN_VERSION='1.69-gog2.1.0.21'
ARCHIVE_GOG_EN_PART1='setup_nwn_diamond_2.1.0.21-1.bin'
ARCHIVE_GOG_EN_PART1_MD5='ce60bf104cc6082fe79d6f0bd7b48f51'
ARCHIVE_GOG_EN_PART1_TYPE='rar'

ARCHIVE_GOG_ES='setup_nwn_diamond_spanish_2.1.0.21.exe'
ARCHIVE_GOG_ES_URL='https://www.gog.com/game/neverwinter_nights_diamond_edition'
ARCHIVE_GOG_ES_MD5='70448f984b66a814bda712ecfef5977e'
ARCHIVE_GOG_ES_TYPE='rar'
ARCHIVE_GOG_ES_SIZE='4400000'
ARCHIVE_GOG_ES_VERSION='1.68-gog2.1.0.21'
ARCHIVE_GOG_ES_PART1='setup_nwn_diamond_spanish_2.1.0.21-1.bin'
ARCHIVE_GOG_ES_PART1_MD5='3b6dee19655a1280273c5d0652f74ab5'
ARCHIVE_GOG_ES_PART1_TYPE='rar'

ARCHIVE_GOG_FR='setup_nwn_diamond_french_2.1.0.21.exe'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/neverwinter_nights_diamond_edition'
ARCHIVE_GOG_FR_MD5='caadc0f809e10ddf781cacbebd1b25d9'
ARCHIVE_GOG_FR_TYPE='rar'
ARCHIVE_GOG_FR_SIZE='4300000'
ARCHIVE_GOG_FR_VERSION='1.68-gog2.1.0.21'
ARCHIVE_GOG_FR_PART1='setup_nwn_diamond_french_2.1.0.21-1.bin'
ARCHIVE_GOG_FR_PART1_MD5='aeb4b99635bdc046560477b2b11307e3'
ARCHIVE_GOG_FR_PART1_TYPE='rar'

ARCHIVE_GOG_PL='setup_nwn_diamond_polish_2.1.0.21.exe'
ARCHIVE_GOG_PL_URL='https://www.gog.com/game/neverwinter_nights_diamond_edition'
ARCHIVE_GOG_PL_MD5='5779b5c690984a79c617efc7649e66a3'
ARCHIVE_GOG_PL_TYPE='rar'
ARCHIVE_GOG_PL_SIZE='4400000'
ARCHIVE_GOG_PL_VERSION='1.68-gog2.1.0.21'
ARCHIVE_GOG_PL_PART1='setup_nwn_diamond_polish_2.1.0.21-1.bin'
ARCHIVE_GOG_PL_PART1_MD5='540c20cd68079c7a214af65296b4a8b1'
ARCHIVE_GOG_PL_PART1_TYPE='rar'

ARCHIVE_LINUX_COMMON='nwn-linux-common.tar.gz'
ARCHIVE_LINUX_COMMON_URL='https://www.dotslashplay.it/ressources/neverwinter-nights/'
ARCHIVE_LINUX_COMMON_MD5='9aa7dae2ba9111c96b10679fa085c66e'

ARCHIVE_LINUX_168='nwn-linux-1.68.tar.gz'
ARCHIVE_LINUX_168_URL='https://www.dotslashplay.it/ressources/neverwinter-nights/'
ARCHIVE_LINUX_168_MD5='7d46737ff2d25470f8d6b389bb53cd1a'

ARCHIVE_LINUX_169='nwn-linux-1.69.tar.gz'
ARCHIVE_LINUX_169_URL='https://www.dotslashplay.it/ressources/neverwinter-nights/'
ARCHIVE_LINUX_169_MD5='b703f017446440e386ae142c1aa74a71'

ARCHIVE_NWMOVIES='nwmovies-mpv.tar.gz'
ARCHIVE_NWMOVIES_URL='https://sites.google.com/site/gogdownloader/nwmovies-mpv.tar.gz'
ARCHIVE_NWMOVIES_MD5='71f3d88db1cd75665b62b77f7604dce1'

ARCHIVE_DOC0_DATA_PATH='game/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='.'
ARCHIVE_DOC1_DATA_FILES='*.txt'

ARCHIVE_GAME0_BIN_PATH='support/app'
ARCHIVE_GAME0_BIN_FILES='nwncdkey.ini'

ARCHIVE_GAME1_BIN_PATH='.'
ARCHIVE_GAME1_BIN_FILES='dmclient fixinstall lib miles nwn nwmain nwserver nwn.ini'

ARCHIVE_GAME2_BIN_PATH='.'
ARCHIVE_GAME2_BIN_FILES='nwmovies nwmovies_install.pl'

ARCHIVE_GAME0_DATA_PATH='game'
ARCHIVE_GAME0_DATA_FILES='*.key *.tlk ambient data dmvault hak localvault modules movies music nwm override texturepacks'

ARCHIVE_GAME1_DATA_PATH='.'
ARCHIVE_GAME1_DATA_FILES='override'

CONFIG_FILES='./*.ini'
DATA_DIRS='./portraits ./saves ./servervault'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN_NWMOVIES='LD_PRELOAD=nwmovies/nwmovies.so
export LD_PRELOAD'
APP_MAIN_EXE='nwn'
APP_MAIN_ICON='game/nwn.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_ID_GOG_DE="${PKG_DATA_ID}-de"
PKG_DATA_ID_GOG_EN="${PKG_DATA_ID}-en"
PKG_DATA_ID_GOG_ES="${PKG_DATA_ID}-es"
PKG_DATA_ID_GOG_FR="${PKG_DATA_ID}-fr"
PKG_DATA_ID_GOG_PL="${PKG_DATA_ID}-pl"
PKG_DATA_PROVIDE="$PKG_DATA_ID"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ID="$GAME_ID"
PKG_BIN_ID_GOG_DE="${PKG_BIN_ID}-de"
PKG_BIN_ID_GOG_EN="${PKG_BIN_ID}-en"
PKG_BIN_ID_GOG_ES="${PKG_BIN_ID}-es"
PKG_BIN_ID_GOG_FR="${PKG_BIN_ID}-fr"
PKG_BIN_ID_GOG_PL="${PKG_BIN_ID}-pl"
PKG_BIN_PROVIDE="$PKG_BIN_ID"
PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glu sdl1.2"
PKG_BIN_DEPS_NWMOVIES='gcc32'
PKG_BIN_DEPS_NWMOVIES_ARCH='lib32-libelf sdl mpv'
PKG_BIN_DEPS_NWMOVIES_DEB='libelf-dev, libsdl1.2-dev:amd64 | libsdl1.2-dev, mpv:amd64 | mpv'
PKG_BIN_DEPS_NWMOVIES_GENTOO='' # TODO

# Load common functions

target_version='2.10'

[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"

if [ -z "$PLAYIT_LIB2" ]; then
	for path in\
		'./'\
		"$XDG_DATA_HOME/play.it/"\
		"$XDG_DATA_HOME/play.it/play.it-2/lib/"\
		'/usr/local/share/games/play.it/'\
		'/usr/local/share/play.it/'\
		'/usr/share/games/play.it/'\
		'/usr/share/play.it/'
	do
		if [ -z "$PLAYIT_LIB2" ] && [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
	if [ -z "$PLAYIT_LIB2" ]; then
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
. "$PLAYIT_LIB2"

# Check presence of Linux client archive

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_LINUX_CLIENT_COMMON' 'ARCHIVE_LINUX_COMMON'
[ "$ARCHIVE_LINUX_CLIENT_COMMON" ] || archive_set_error_not_found 'ARCHIVE_LINUX_COMMON'
case "$ARCHIVE_MAIN" in
	('ARCHIVE_GOG_EN')
		ARCHIVE_PATCH='ARCHIVE_LINUX_169'
	;;
	(*)
		ARCHIVE_PATCH='ARCHIVE_LINUX_168'
	;;
esac
archive_set 'ARCHIVE_LINUX_CLIENT_PATCH' "$ARCHIVE_PATCH"
[ "$ARCHIVE_LINUX_CLIENT_PATCH" ] || archive_set_error_not_found "$ARCHIVE_PATCH"
ARCHIVE="$ARCHIVE_MAIN"

# Check presence of NWMovies archive
# NWMovies won’t be included in Arch Linux packages until this bug is fixed: https://framagit.org/vv221/play.it-games/issues/45

if [ "$OPTION_PACKAGE" != 'arch' ]; then
	ARCHIVE_MAIN="$ARCHIVE"
	archive_set 'ARCHIVE_MOVIES' 'ARCHIVE_NWMOVIES'
	ARCHIVE="$ARCHIVE_MAIN"
	if [ "$ARCHIVE_MOVIES" ]; then
		APP_MAIN_PRERUN="$APP_MAIN_PRERUN_NWMOVIES"
		PKG_BIN_DEPS="$PKG_BIN_DEPS $PKG_BIN_DEPS_NWMOVIES"
		PKG_BIN_DEPS_ARCH="$PKG_BIN_DEPS_NWMOVIES_ARCH"
		PKG_BIN_DEPS_DEB="$PKG_BIN_DEPS_NWMOVIES_DEB"
		PKG_BIN_DEPS_GENTOO="$PKG_BIN_DEPS_NWMOVIES_GENTOO"
	fi
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE_PART1"
(
	cd "$PLAYIT_WORKDIR/gamedata/game"
	if [ -e 'dialog.TLK' ]; then
		mv 'dialog.TLK' 'dialog.tlk'
	fi
	if [ -e 'dialogF.TLK' ]; then
		mv 'dialogF.TLK' 'dialogf.tlk'
	fi
	for tiles in 'a' 'b' 'c'; do
		if [ -e "texturepacks/Tiles_TP${tiles}.ERF" ]; then
			mv "texturepacks/Tiles_TP${tiles}.ERF" "texturepacks/Tiles_Tp${tiles}.erf"
		fi
	done
)
prepare_package_layout

# Extract icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include Linux client

(
	ARCHIVE='ARCHIVE_LINUX_CLIENT_COMMON'
	extract_data_from "$ARCHIVE_LINUX_CLIENT_COMMON"
	ARCHIVE='ARCHIVE_LINUX_CLIENT_PATCH'
	extract_data_from "$ARCHIVE_LINUX_CLIENT_PATCH"
)
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include NWMovies

if [ "$ARCHIVE_MOVIES" ]; then
	(
		ARCHIVE='ARCHIVE_MOVIES'
		extract_data_from "$ARCHIVE_MOVIES"
	)
	prepare_package_layout
fi

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Tweak launcher to handle NWMovies

if [ "$ARCHIVE_MOVIES" ]; then
	file="${PKG_BIN_PATH}$PATH_BIN/$GAME_ID"
	pattern='s/# Build prefix/&\n'
	pattern="$pattern"'if [ ! -d "$PATH_PREFIX" ]; then\n'
	pattern="$pattern"'\tclean_prefix=1\n'
	pattern="$pattern"'fi/;'
	pattern="$pattern"'s#cp --recursive --remove-destination --symbolic-link "$PATH_GAME"/\* "$PATH_PREFIX"#&\n'
	pattern="$pattern"'if [ "$clean_prefix" = 1 ]; then\n'
	pattern="$pattern"'\tif [ ! -e nwmovies/nwmovies.so ]; then'
	pattern="$pattern"'\t\t(\n'
	pattern="$pattern"'\t\t\tcd "$PATH_PREFIX"\n'
	pattern="$pattern"'\t\t\tsed --in-place "s/mpv /mpv --fs --no-osc /" ./nwmovies/nwplaymovie\n'
	pattern="$pattern"'\t\t\t./nwmovies/nwmovies_install.pl build >/dev/null 2>\&1\n'
	pattern="$pattern"'\t\t\tcp --no-dereference --parents nwmovies/nwmovies.so nwmovies/libdis/libdisasm.so nwmovies/nwplaymovie nwplaymovie "$PATH_DATA"\n'
	pattern="$pattern"'\t\t)\n'
	pattern="$pattern"'\tfi\n'
	pattern="$pattern"'fi#;'
	pattern="$pattern"'s#^"\./$APP_EXE" $APP_OPTIONS $@$#'
	pattern="$pattern"'if [ ! -e nwmovies.ini ]; then\n'
	pattern="$pattern"'\t"./$APP_EXE" $APP_OPTIONS $@\n'
	pattern="$pattern"'fi\n&#'
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
