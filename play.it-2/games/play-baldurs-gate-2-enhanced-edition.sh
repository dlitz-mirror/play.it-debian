#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
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
# Baldur's Gate 2 - Enhanced Edition
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210722.1

# Set game-specific variables

GAME_ID='baldurs-gate-2-enhanced-edition'
GAME_NAME='Baldurʼs Gate Ⅱ - Enhanced Edition'

ARCHIVE_BASE_0='baldur_s_gate_2_enhanced_edition_en_2_5_21851.sh'
ARCHIVE_BASE_0_MD5='4508edf93d6b138a7e91aa0f2f82605a'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='3700000'
ARCHIVE_BASE_0_VERSION='2.5.16.6-gog21851'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/baldurs_gate_2_enhanced_edition'

ARCHIVE_BASE_32BIT_0='gog_baldur_s_gate_2_enhanced_edition_2.6.0.11.sh'
ARCHIVE_BASE_32BIT_0_MD5='b9ee856a29238d4aec65367377d88ac4'
ARCHIVE_BASE_32BIT_0_TYPE='mojosetup'
ARCHIVE_BASE_32BIT_0_SIZE='2700000'
ARCHIVE_BASE_32BIT_0_VERSION='2.3.67.3-gog2.6.0.11'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='BaldursGateII64'

ARCHIVE_GAME_L10N_DE_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_DE_FILES='lang/de_DE'

ARCHIVE_GAME_L10N_ES_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_ES_FILES='lang/es_ES'

ARCHIVE_GAME_L10N_IT_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_IT_FILES='lang/it_IT'

ARCHIVE_GAME_L10N_KO_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_KO_FILES='lang/ko_KR'

ARCHIVE_GAME_L10N_PL_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_PL_FILES='lang/pl_PL'

ARCHIVE_GAME_L10N_RU_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_RU_FILES='lang/ru_RU'

ARCHIVE_GAME_L10N_ZH_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_ZH_FILES='lang/zh_CN'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='chitin.key engine.lua Manuals movies music scripts data lang/en_US'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='BaldursGateII64'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST_COMMON='PKG_L10N_DE PKG_L10N_ES PKG_L10N_IT PKG_L10N_KO PKG_L10N_PL PKG_L10N_RU PKG_L10N_ZH PKG_DATA'
PACKAGES_LIST="PKG_BIN32 PKG_BIN64 $PACKAGES_LIST_COMMON"

PKG_L10N_ID="${GAME_ID}-l10n-extra"

PKG_L10N_DE_ID="${PKG_L10N_ID}-de"
PKG_L10N_DE_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DE_DESCRIPTION='German localization'
PKG_L10N_DE_DEPS="$GAME_ID"

PKG_L10N_ES_ID="${PKG_L10N_ID}-es"
PKG_L10N_ES_PROVIDE="$PKG_L10N_ID"
PKG_L10N_ES_DESCRIPTION='Spanish localization'
PKG_L10N_ES_DEPS="$GAME_ID"

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

PKG_L10N_ZH_ID="${PKG_L10N_ID}-zh"
PKG_L10N_ZH_PROVIDE="$PKG_L10N_ID"
PKG_L10N_ZH_DESCRIPTION='Chinese localization'
PKG_L10N_ZH_DEPS="$GAME_ID"

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_DATA_ID glibc libstdc++ glx libxrandr xcursor libopenal.so.1 libasound.so.2 libX11.so.6"
PKG_BIN64_DEPS_ARCH='expat'
PKG_BIN64_DEPS_DEB='libexpat1'
PKG_BIN64_DEPS_GENTOO='dev-libs/expat'

# Keep compatibility with old archives

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='BaldursGateII'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_BIN64_DEPS"
PKG_BIN32_DEPS_ARCH='lib32-expat'
PKG_BIN32_DEPS_DEB="$PKG_BIN64_DEPS_DEB"
PKG_BIN32_DEPS_GENTOO='dev-libs/expat[abi_x86_32]'

APP_MAIN_EXE_BIN32='BaldursGateII'

PACKAGES_LIST_32BIT="PKG_BIN32 ${PACKAGES_LIST_COMMON}"

# Easier upgrade from packages generated with pre-20180801.3 scripts

PKG_DATA_PROVIDE='baldurs-gate-2-enhanced-edition-areas'

# Load common functions

target_version='2.13'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
		'/usr/share/play.it'
	do
		if [ -e "${path}/libplayit2.sh" ]; then
			PLAYIT_LIB2="${path}/libplayit2.sh"
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

# Ensure availability of libSSL 1.0.0 (32-bit)

PKG='PKG_BIN32'
if packages_get_list | grep --quiet "$PKG"; then
	case "$OPTION_PACKAGE" in
		('arch'|'gentoo')
			# Use package from official repositories
			PKG_BIN32_DEPS_ARCH="$PKG_BIN32_DEPS_ARCH lib32-openssl-1.0"
			PKG_BIN32_DEPS_GENTOO="$PKG_BIN32_DEPS_GENTOO dev-libs/openssl-compat[abi_x86_32]"
		;;
		('deb')
			# Use archive provided by ./play.it
			ARCHIVE_OPTIONAL_LIBSSL32='libssl_1.0.0_32-bit.tar.gz'
			ARCHIVE_OPTIONAL_LIBSSL32_URL='https://downloads.dotslashplay.it/resources/libssl/'
			ARCHIVE_OPTIONAL_LIBSSL32_MD5='9443cad4a640b2512920495eaf7582c4'
			ARCHIVE_LIBSSL32_PATH='.'
			ARCHIVE_LIBSSL32_FILES='*'
			archive_initialize_required \
				'ARCHIVE_LIBSSL32' \
				'ARCHIVE_OPTIONAL_LIBSSL32'
			extract_data_from "$ARCHIVE_LIBSSL32"
			organize_data 'LIBSSL32' "${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
			rm --recursive "${PLAYIT_WORKDIR}/gamedata"
		;;
	esac
fi

# Ensure availability of libSSL 1.0.0 (64-bit)

PKG='PKG_BIN64'
if packages_get_list | grep --quiet "$PKG"; then
	case "$OPTION_PACKAGE" in
		('arch'|'gentoo')
			# Use package from official repositories
			PKG_BIN64_DEPS_ARCH="$PKG_BIN64_DEPS_ARCH openssl-1.0"
			PKG_BIN64_DEPS_GENTOO="$PKG_BIN64_DEPS_GENTOO dev-libs/openssl-compat"
		;;
		('deb')
			# Use archive provided by ./play.it
			ARCHIVE_OPTIONAL_LIBSSL64='libssl_1.0.0_64-bit.tar.gz'
			ARCHIVE_OPTIONAL_LIBSSL64_URL='https://downloads.dotslashplay.it/resources/libssl/'
			ARCHIVE_OPTIONAL_LIBSSL64_MD5='89917bef5dd34a2865cb63c2287e0bd4'
			ARCHIVE_LIBSSL64_PATH='.'
			ARCHIVE_LIBSSL64_FILES='*'
			archive_initialize_required \
				'ARCHIVE_LIBSSL64' \
				'ARCHIVE_OPTIONAL_LIBSSL64'
			extract_data_from "$ARCHIVE_LIBSSL64"
			organize_data 'LIBSSL64' "${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
			rm --recursive "${PLAYIT_WORKDIR}/gamedata"
		;;
	esac
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get game icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

# Work around side-effect of use_package_specific_value
# cf. https://forge.dotslashplay.it/play.it/scripts/-/issues/294
APP_MAIN_EXE_BIN64="$APP_MAIN_EXE"

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	if packages_get_list | grep --quiet "$PKG"; then
		launchers_write 'APP_MAIN'
	fi
done

# Old 32-bit only binaries depend on libjson.so.0

PKG_BIN32_DEPS_32BIT="$PKG_BIN32_DEPS json"
case "$OPTION_PACKAGE" in
	('arch'|'gentoo'|'egentoo')
		SYSTEM_LIB32_PATH='/usr/lib32'
	;;
	('deb')
		SYSTEM_LIB32_PATH='/lib/i386-linux-gnu'
	;;
	(*)
		# Unsupported package type, throw an error
		error_invalid_argument 'OPTION_PACKAGE' "$0"
	;;
esac
LIBRARY_GAME_DIR="${PATH_GAME}/${APP_MAIN_LIBS=:libs}"
LIBRARY_GAME_FILE="${LIBRARY_GAME_FILE}/libjson.so.0"
# shellcheck disable=SC1004
PKG_BIN32_POSTINST_RUN_32BIT="$PKG_BIN32_POSTINST_RUN

# The game engine expects 32-bit libjson.so.0 to be available
SYSTEM_LIB32_PATH='$SYSTEM_LIB32_PATH'
LIBRARY_GAME_DIR='$LIBRARY_GAME_DIR'
LIBRARY_GAME_FILE='$LIBRARY_GAME_FILE'"'
if \
    [ ! -e "${SYSTEM_LIB32_PATH}/libjson.so.0" ] && \
    [ ! -e "$LIBRARY_GAME_FILE" ]
then
    for library_file in \
        libjson-c.so \
        libjson-c.so.2 \
        libjson-c.so.3
    do
        if [ -e "${SYSTEM_LIB32_PATH}/${library_file}" ]; then
			mkdir --parents "$LIBRARY_GAME_DIR"
            ln --symbolic "${SYSTEM_LIB32_PATH}/${library_file}" "$LIBRARY_GAME_FILE"
            break
        fi
    done
fi'
PKG_BIN32_PRERM_RUN_32BIT="$PKG_BIN32_PRERM_RUN

# The game engine expects 32-bit libjson.so.0 to be available
LIBRARY_GAME_DIR='$LIBRARY_GAME_DIR'
LIBRARY_GAME_FILE='$LIBRARY_GAME_FILE'"'
if [ -e "$LIBRARY_GAME_FILE" ]; then
	rm "$LIBRARY_GAME_FILE"
	rmdir --parents --ignore-fail-on-non-empty "$LIBRARY_GAME_DIR"
fi'
use_archive_specific_value 'PKG_BIN32_DEPS'
use_archive_specific_value 'PKG_BIN32_POSTINST_RUN'
use_archive_specific_value 'PKG_BIN32_PRERM_RUN'

# Build packages

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

COMMON_PACKAGES='PKG_DATA PKG_BIN32 PKG_BIN64'
COMMON_PACKAGES_32BIT='PKG_DATA PKG_BIN32'
use_archive_specific_value 'COMMON_PACKAGES'
case "${LANG%_*}" in
	('fr')
		lang_string='version %s :'
		lang_en='anglaise'
		lang_de='allemande'
		lang_es='espagnole'
		lang_it='italienne'
		lang_ko='coréenne'
		lang_pl='polonaise'
		lang_ru='russe'
		lang_zh='chinoise'
	;;
	('en'|*)
		lang_string='%s version:'
		lang_en='English'
		lang_de='German'
		lang_es='Spanish'
		lang_it='Italian'
		lang_ko='Korean'
		lang_pl='Polish'
		lang_ru='Russian'
		lang_zh='Chinese'
	;;
esac
printf '\n'
printf "$lang_string" "$lang_en"
# shellcheck disable=SC2086
print_instructions $COMMON_PACKAGES
printf "$lang_string" "$lang_de"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_DE' $COMMON_PACKAGES
printf "$lang_string" "$lang_es"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_ES' $COMMON_PACKAGES
printf "$lang_string" "$lang_it"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_IT' $COMMON_PACKAGES
printf "$lang_string" "$lang_ko"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_KO' $COMMON_PACKAGES
printf "$lang_string" "$lang_pl"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_PL' $COMMON_PACKAGES
printf "$lang_string" "$lang_ru"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_RU' $COMMON_PACKAGES
printf "$lang_string" "$lang_zh"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_ZH' $COMMON_PACKAGES

exit 0
