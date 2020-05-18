#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Icewind Dale - Enhanced Edition
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200203.6

# Set game-specific variables

GAME_ID='icewind-dale-1-enhanced-edition'
GAME_NAME='Icewind Dale - Enhanced Edition'

ARCHIVE_GOG='icewind_dale_enhanced_edition_en_2_5_17_23121.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/icewind_dale_enhanced_edition'
ARCHIVE_GOG_MD5='bdfcd244568916123c243fb95de1d08b'
ARCHIVE_GOG_SIZE='2900000'
ARCHIVE_GOG_VERSION='2.5.17.0-gog23121'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='icewind_dale_enhanced_edition_en_2_5_16_3_20626.sh'
ARCHIVE_GOG_OLD1_MD5='f237e9506f046862e8d1c2d21c8fd588'
ARCHIVE_GOG_OLD1_SIZE='2900000'
ARCHIVE_GOG_OLD1_VERSION='2.5.16.3-gog20626'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_icewind_dale_enhanced_edition_2.1.0.5.sh'
ARCHIVE_GOG_OLD0_MD5='fc7244f4793eec365b8ac41d91a4edbb'
ARCHIVE_GOG_OLD0_SIZE='2900000'
ARCHIVE_GOG_OLD0_VERSION='1.4.0-gog2.1.0.5'

ARCHIVE_OPTIONAL_LIBSSL32='libssl_1.0.0_32-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBSSL32_URL='https://downloads.dotslashplay.it/resources/libssl/'
ARCHIVE_OPTIONAL_LIBSSL32_MD5='9443cad4a640b2512920495eaf7582c4'

ARCHIVE_OPTIONAL_LIBSSL64='libssl_1.0.0_64-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBSSL64_URL='https://downloads.dotslashplay.it/resources/libssl/'
ARCHIVE_OPTIONAL_LIBSSL64_MD5='89917bef5dd34a2865cb63c2287e0bd4'

ARCHIVE_OPTIONAL_ICONS='icewind-dale-1-enhanced-edition_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/resources/icewind-dale-1-enhanced-edition/'
ARCHIVE_OPTIONAL_ICONS_MD5='2e7db406aca79f9182c4efa93df80bf4'

ARCHIVE_DOC_PATH='data/noarch/docs'
ARCHIVE_DOC_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='IcewindDale'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='IcewindDale64'

ARCHIVE_GAME_L10N_CS_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_CS_FILES='lang/cs_CZ'

ARCHIVE_GAME_L10N_DE_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_DE_FILES='lang/de_DE'

ARCHIVE_GAME_L10N_ES_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_ES_FILES='lang/es_ES'

ARCHIVE_GAME_L10N_FR_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_FR_FILES='lang/fr_FR'

ARCHIVE_GAME_L10N_IT_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_IT_FILES='lang/it_IT'

ARCHIVE_GAME_L10N_KO_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_KO_FILES='lang/ko_KR'

ARCHIVE_GAME_L10N_PL_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_PL_FILES='lang/pl_PL'

ARCHIVE_GAME_L10N_RU_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_RU_FILES='lang/ru_RU'

ARCHIVE_GAME_L10N_TR_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_TR_FILES='lang/tr_TR'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='chitin.key engine.lua data movies music scripts lang/en_US'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 32x32 48x48 64x64 128x128 256x256'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='libs'
APP_MAIN_EXE_BIN32='IcewindDale'
APP_MAIN_EXE_BIN64='IcewindDale64'
APP_MAIN_ICON_GOG='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_L10N_CS PKG_L10N_DE PKG_L10N_ES PKG_L10N_FR PKG_L10N_IT PKG_L10N_KO PKG_L10N_PL PKG_L10N_RU PKG_L10N_TR PKG_DATA'
# Keep compatibility with old archives
PACKAGES_LIST_GOG_OLD0='PKG_BIN32 PKG_L10N_CS PKG_L10N_DE PKG_L10N_ES PKG_L10N_FR PKG_L10N_IT PKG_L10N_KO PKG_L10N_PL PKG_L10N_RU PKG_L10N_TR PKG_DATA'

PKG_L10N_ID="${GAME_ID}-l10n-extra"

PKG_L10N_CS_ID="${PKG_L10N_ID}-cs"
PKG_L10N_CS_PROVIDE="$PKG_L10N_ID"
PKG_L10N_CS_DESCRIPTION='Czech localization'
PKG_L10N_CS_DEPS="$GAME_ID"

PKG_L10N_DE_ID="${PKG_L10N_ID}-de"
PKG_L10N_DE_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DE_DESCRIPTION='German localization'
PKG_L10N_DE_DEPS="$GAME_ID"

PKG_L10N_ES_ID="${PKG_L10N_ID}-es"
PKG_L10N_ES_PROVIDE="$PKG_L10N_ID"
PKG_L10N_ES_DESCRIPTION='Spanish localization'
PKG_L10N_ES_DEPS="$GAME_ID"

PKG_L10N_FR_ID="${PKG_L10N_ID}-fr"
PKG_L10N_FR_PROVIDE="$PKG_L10N_ID"
PKG_L10N_FR_DESCRIPTION='French localization'
PKG_L10N_FR_DEPS="$GAME_ID"

PKG_L10N_IT_ID="${PKG_L10N_ID}-it"
PKG_L10N_IT_PROVIDE="$PKG_L10N_ID"
PKG_L10N_IT_DESCRIPTION='Italian localization'
PKG_L10N_IT_DEPS="$GAME_ID"

PKG_L10N_KO_ID="${PKG_L10N_ID}-ko"
PKG_L10N_KO_PROVIDE="$PKG_L10N_ID"
PKG_L10N_KO_DESCRIPTION='Korean localization'
PKG_L10N_KO_DEPS="$GAME_ID"

PKG_L10N_PL_ID="${PKG_L10N_ID}-pl"
PKG_L10N_PL_PROVIDE="$PKG_L10N_ID"
PKG_L10N_PL_DESCRIPTION='Polish localization'
PKG_L10N_PL_DEPS="$GAME_ID"

PKG_L10N_RU_ID="${PKG_L10N_ID}-ru"
PKG_L10N_RU_PROVIDE="$PKG_L10N_ID"
PKG_L10N_RU_DESCRIPTION='Russian localization'
PKG_L10N_RU_DEPS="$GAME_ID"

PKG_L10N_TR_ID="${PKG_L10N_ID}-tr"
PKG_L10N_TR_PROVIDE="$PKG_L10N_ID"
PKG_L10N_TR_DESCRIPTION='Turkish localization'
PKG_L10N_TR_DEPS="$GAME_ID"

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# Easier upgrade from packages generated with pre-20200203.5 scripts
PKG_DATA_PROVIDE='icewind-dale-1-enhanced-edition-l10n'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx openal libxrandr"
PKG_BIN32_DEPS_ARCH='lib32-openssl-1.0'
# Easier upgrade from packages generated with pre-20180926.2 scripts
PKG_BIN32_PROVIDE='icewind-dale-enhanced-edition'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='openssl-1.0'
# Easier upgrade from packages generated with pre-20180926.2 scripts
PKG_BIN64_PROVIDE='icewind-dale-enhanced-edition'

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

# Set packages list based on source archive

use_archive_specific_value 'PACKAGES_LIST'
# shellcheck disable=SC2086
set_temp_directories $PACKAGES_LIST

# Load icons archive if available

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
ARCHIVE="$ARCHIVE_MAIN"

# Use libSSL 1.0.0 archives (Debian packages only)

if [ "$OPTION_PACKAGE" = 'deb' ]; then
	ARCHIVE_MAIN="$ARCHIVE"
	archive_set 'ARCHIVE_LIBSSL32' 'ARCHIVE_OPTIONAL_LIBSSL32'
	case "$ARCHIVE_MAIN" in
		('ARCHIVE_GOG_OLD0')
			# No 64-bit binary provided, 64-bit libSSL 1.0.0 is not required
		;;
		(*)
			archive_set 'ARCHIVE_LIBSSL64' 'ARCHIVE_OPTIONAL_LIBSSL64'
		;;
	esac
	ARCHIVE="$ARCHIVE_MAIN"
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icons

PKG='PKG_DATA'
if [ "$ARCHIVE_ICONS" ]; then
	ARCHIVE='ARCHIVE_ICONS' \
		extract_data_from "$ARCHIVE_ICONS"
	organize_data 'ICONS' "$PATH_ICON_BASE"
else
	icons_get_from_workdir 'APP_MAIN'
fi
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include libSSL 1.0.0 (Debian packages only)

if [ "$ARCHIVE_LIBSSL32" ]; then
	ARCHIVE='ARCHIVE_LIBSSL32' \
		extract_data_from "$ARCHIVE_LIBSSL32"
	mkdir --parents "${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi
if [ "$ARCHIVE_LIBSSL64" ]; then
	ARCHIVE='ARCHIVE_LIBSSL64' \
		extract_data_from "$ARCHIVE_LIBSSL64"
	mkdir --parents "${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Write launchers

PKG='PKG_BIN32'
launchers_write 'APP_MAIN'
case "$ARCHIVE" in
	('ARCHIVE_GOG_OLD0')
		# No 64-bit binary provided
	;;
	(*)
		PKG='PKG_BIN64'
		launchers_write 'APP_MAIN'
	;;
esac

# Build package

case "$ARCHIVE" in
	('ARCHIVE_GOG_OLD0')
		# No 64-bit binary provided
		# Old 32-bit version depends on libjson.so.0
		PKG_BIN32_DEPS="$PKG_BIN32_DEPS json"
		case "$OPTION_PACKAGE" in
			('arch')
				cat > "$postinst" <<- EOF
				if [ ! -e /usr/lib32/libjson.so.0 ] && [ -e /usr/lib32/libjson-c.so ] ; then
				    mkdir --parents "$PATH_GAME/$APP_MAIN_LIBS"
				    ln --symbolic /usr/lib32/libjson-c.so "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
				fi
				EOF
			;;
			('deb')
				cat > "$postinst" <<- EOF
				if [ ! -e /lib/i386-linux-gnu/libjson.so.0 ]; then
				    mkdir --parents "$PATH_GAME/$APP_MAIN_LIBS"
				    for file in\
				        libjson-c.so\
				        libjson-c.so.2\
				        libjson-c.so.3
				    do
				        if [ -e "/lib/i386-linux-gnu/\$file" ] ; then
				            ln --symbolic "/lib/i386-linux-gnu/\$file" "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
				            break
				        fi
				    done
				fi
				EOF
			;;
		esac
		cat > "$prerm" <<- EOF
		if [ -e "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0" ]; then
		    rm "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
		fi
		EOF
		write_metadata 'PKG_BIN32'
		write_metadata 'PKG_L10N_CS' 'PKG_L10N_DE' 'PKG_L10N_ES' 'PKG_L10N_FR' 'PKG_L10N_IT' 'PKG_L10N_KO' 'PKG_L10N_PL' 'PKG_L10N_RU' 'PKG_L10N_TR' 'PKG_DATA'
	;;
	(*)
		write_metadata
	;;
esac
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

case "${LANG%_*}" in
	('fr')
		lang_string='version %s :'
		lang_en='anglaise'
		lang_cs='tchèque'
		lang_de='allemande'
		lang_es='espagnole'
		lang_fr='française'
		lang_it='italienne'
		lang_ko='coréenne'
		lang_pl='polonaise'
		lang_ru='russe'
		lang_tr='turque'
	;;
	('en'|*)
		lang_string='%s version:'
		lang_en='English'
		lang_cs='Czech'
		lang_de='German'
		lang_es='Spanish'
		lang_fr='French'
		lang_it='Italian'
		lang_ko='Korean'
		lang_pl='Polish'
		lang_ru='Russian'
		lang_tr='Turkish'
	;;
esac
printf '\n'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_en"
print_instructions 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_cs"
print_instructions 'PKG_L10N_CS' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_de"
print_instructions 'PKG_L10N_DE' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_es"
print_instructions 'PKG_L10N_ES' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_fr"
print_instructions 'PKG_L10N_FR' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_it"
print_instructions 'PKG_L10N_IT' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_ko"
print_instructions 'PKG_L10N_KO' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_pl"
print_instructions 'PKG_L10N_PL' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_ru"
print_instructions 'PKG_L10N_RU' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_tr"
print_instructions 'PKG_L10N_TR' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'

exit 0
