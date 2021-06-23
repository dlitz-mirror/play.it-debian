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
# Baldurʼs Gate - Enhanced Edition
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210615.6

# Set game-specific variables

GAME_ID='baldurs-gate-1-enhanced-edition'
GAME_NAME='Baldurʼs Gate - Enhanced Edition'

ARCHIVE_BASE_1='baldur_s_gate_enhanced_edition_2_6_6_0_47291.sh'
ARCHIVE_BASE_1_MD5='6f7be163ebb80a0fbc9d6331f9c6f09c'
ARCHIVE_BASE_1_TYPE='mojosetup'
ARCHIVE_BASE_1_SIZE='3300000'
ARCHIVE_BASE_1_VERSION='2.6.6.0-gog47291'
ARCHIVE_BASE_1_URL='https://www.gog.com/game/baldurs_gate_enhanced_edition'

ARCHIVE_BASE_0='baldur_s_gate_enhanced_edition_2_6_5_0_46477.sh'
ARCHIVE_BASE_0_MD5='a87444f36602b5059e3c885ec2ff50e1'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='3300000'
ARCHIVE_BASE_0_VERSION='2.6.5.0-gog46477'

ARCHIVE_BASE_MULTIARCH_0='baldur_s_gate_enhanced_edition_en_2_5_23121.sh'
ARCHIVE_BASE_MULTIARCH_0_MD5='853f6e66db6cc5a4df0f72d23d65fcf7'
ARCHIVE_BASE_MULTIARCH_0_TYPE='mojosetup'
ARCHIVE_BASE_MULTIARCH_0_SIZE='3300000'
ARCHIVE_BASE_MULTIARCH_0_VERSION='2.5.17.0-gog23121'

ARCHIVE_BASE_32BIT_2='baldur_s_gate_enhanced_edition_en_2_3_67_3_20146.sh'
ARCHIVE_BASE_32BIT_2_MD5='4d08fe21fcdeab51624fa2e0de2f5813'
ARCHIVE_BASE_32BIT_2_TYPE='mojosetup'
ARCHIVE_BASE_32BIT_2_SIZE='3200000'
ARCHIVE_BASE_32BIT_2_VERSION='2.3.67.3-gog20146'

ARCHIVE_BASE_32BIT_1='gog_baldur_s_gate_enhanced_edition_2.5.0.9.sh'
ARCHIVE_BASE_32BIT_1_MD5='224be273fd2ec1eb0246f407dda16bc4'
ARCHIVE_BASE_32BIT_1_TYPE='mojosetup'
ARCHIVE_BASE_32BIT_1_SIZE='3200000'
ARCHIVE_BASE_32BIT_1_VERSION='2.3.67.3-gog2.5.0.9'

ARCHIVE_BASE_32BIT_0='gog_baldur_s_gate_enhanced_edition_2.5.0.7.sh'
ARCHIVE_BASE_32BIT_0_MD5='37ece59534ca63a06f4c047d64b82df9'
ARCHIVE_BASE_32BIT_0_TYPE='mojosetup'
ARCHIVE_BASE_32BIT_0_SIZE='3200000'
ARCHIVE_BASE_32BIT_0_VERSION='2.3.67.3-gog2.5.0.7'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='BaldursGate'

ARCHIVE_GAME_L10N_CS_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_CS_FILES='lang/cs_CZ'

ARCHIVE_GAME_L10N_DE_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_DE_FILES='lang/de_DE'

ARCHIVE_GAME_L10N_ES_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_ES_FILES='lang/es_ES'

ARCHIVE_GAME_L10N_FR_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_FR_FILES='lang/fr_FR'

ARCHIVE_GAME_L10N_HU_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_HU_FILES='lang/hu_HU'

ARCHIVE_GAME_L10N_IT_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_IT_FILES='lang/it_IT'

ARCHIVE_GAME_L10N_JA_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_JA_FILES='lang/ja_JP'

ARCHIVE_GAME_L10N_KO_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_KO_FILES='lang/ko_KR'

ARCHIVE_GAME_L10N_PL_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_PL_FILES='lang/pl_PL'

ARCHIVE_GAME_L10N_PT_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_PT_FILES='lang/pt_BR'

ARCHIVE_GAME_L10N_RU_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_RU_FILES='lang/ru_RU'

ARCHIVE_GAME_L10N_TR_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_TR_FILES='lang/tr_TR'

ARCHIVE_GAME_L10N_UK_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_UK_FILES='lang/uk_UA'

ARCHIVE_GAME_L10N_ZH_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_ZH_FILES='lang/zh_CN'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='movies music chitin.key Manuals scripts data engine.lua lang/en_US'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='BaldursGate'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST_COMMON='PKG_L10N_CS PKG_L10N_DE PKG_L10N_ES PKG_L10N_FR PKG_L10N_HU PKG_L10N_IT PKG_L10N_JA PKG_L10N_KO PKG_L10N_PL PKG_L10N_PT PKG_L10N_RU PKG_L10N_TR PKG_L10N_UK PKG_L10N_ZH PKG_DATA'
PACKAGES_LIST="PKG_BIN64 ${PACKAGES_LIST_COMMON}"

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

PKG_L10N_HU_ID="${PKG_L10N_ID}-hu"
PKG_L10N_HU_PROVIDE="$PKG_L10N_ID"
PKG_L10N_HU_DESCRIPTION='Hungarian localization'
PKG_L10N_HU_DEPS="$GAME_ID"

PKG_L10N_IT_ID="${PKG_L10N_ID}-it"
PKG_L10N_IT_PROVIDE="$PKG_L10N_ID"
PKG_L10N_IT_DESCRIPTION='Italian localization'
PKG_L10N_IT_DEPS="$GAME_ID"

PKG_L10N_JA_ID="${PKG_L10N_ID}-ja"
PKG_L10N_JA_PROVIDE="$PKG_L10N_ID"
PKG_L10N_JA_DESCRIPTION='Japanese localization'
PKG_L10N_JA_DEPS="$GAME_ID"

PKG_L10N_KO_ID="${PKG_L10N_ID}-ko"
PKG_L10N_KO_PROVIDE="$PKG_L10N_ID"
PKG_L10N_KO_DESCRIPTION='Korean localization'
PKG_L10N_KO_DEPS="$GAME_ID"

PKG_L10N_PL_ID="${PKG_L10N_ID}-pl"
PKG_L10N_PL_PROVIDE="$PKG_L10N_ID"
PKG_L10N_PL_DESCRIPTION='Polish localization'
PKG_L10N_PL_DEPS="$GAME_ID"

PKG_L10N_PT_ID="${PKG_L10N_ID}-pt"
PKG_L10N_PT_PROVIDE="$PKG_L10N_ID"
PKG_L10N_PT_DESCRIPTION='Portuguese localization'
PKG_L10N_PT_DEPS="$GAME_ID"

PKG_L10N_RU_ID="${PKG_L10N_ID}-ru"
PKG_L10N_RU_PROVIDE="$PKG_L10N_ID"
PKG_L10N_RU_DESCRIPTION='Russian localization'
PKG_L10N_RU_DEPS="$GAME_ID"

PKG_L10N_TR_ID="${PKG_L10N_ID}-tr"
PKG_L10N_TR_PROVIDE="$PKG_L10N_ID"
PKG_L10N_TR_DESCRIPTION='Turkish localization'
PKG_L10N_TR_DEPS="$GAME_ID"

PKG_L10N_UK_ID="${PKG_L10N_ID}-uk"
PKG_L10N_UK_PROVIDE="$PKG_L10N_ID"
PKG_L10N_UK_DESCRIPTION='Ukrainian localization'
PKG_L10N_UK_DEPS="$GAME_ID"

PKG_L10N_ZH_ID="${PKG_L10N_ID}-zh"
PKG_L10N_ZH_PROVIDE="$PKG_L10N_ID"
PKG_L10N_ZH_DESCRIPTION='Chinese localization'
PKG_L10N_ZH_DEPS="$GAME_ID"

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="${PKG_DATA_ID} glibc libstdc++ glx libxrandr xcursor libopenal.so.1 libasound.so.2"
PKG_BIN64_DEPS_ARCH='expat'
PKG_BIN64_DEPS_DEB='libexpat1'
PKG_BIN64_DEPS_GENTOO='dev-libs/expat'

# Keep compatibility with old archives

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='BaldursGate'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_BIN64_DEPS"
PKG_BIN32_DEPS_ARCH='lib32-expat'
PKG_BIN32_DEPS_DEB="$PKG_BIN64_DEPS_DEB"
PKG_BIN32_DEPS_GENTOO='dev-libs/expat[abi_x86_32]'

APP_MAIN_EXE_BIN32='BaldursGate'

## 64-bit + 32-bit

ARCHIVE_GAME_BIN64_FILES_MULTIARCH='BaldursGate64'

APP_MAIN_EXE_BIN64_MULTIARCH='BaldursGate64'

PACKAGES_LIST_MULTIARCH="PKG_BIN32 PKG_BIN64 ${PACKAGES_LIST_COMMON}"

PKG_BIN32_DEPS_MULTIARCH="${PKG_BIN32_DEPS} libX11.so.6"
PKG_BIN64_DEPS_MULTIARCH="${PKG_BIN64_DEPS} libX11.so.6"

## 32-bit only

PACKAGES_LIST_32BIT="PKG_BIN32 ${PACKAGES_LIST_COMMON}"

PKG_BIN32_DEPS_32BIT="${PKG_BIN32_DEPS} libX11.so.6"

# Easier upgrade from packages generated with pre-20180926.3 scripts

PKG_BIN32_PROVIDE='baldurs-gate-enhanced-edition'
PKG_BIN64_PROVIDE='baldurs-gate-enhanced-edition'
PKG_L10N_PROVIDE='baldurs-gate-enhanced-edition-l10n'

# Easier upgrade from packages generated with pre-20210421.4 scripts

PKG_DATA_PROVIDE='baldurs-gate-1-enhanced-edition-l10n'

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

# Load icons archive if available

ARCHIVE_OPTIONAL_ICONS='baldurs-gate-1-enhanced-edition_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/resources/baldurs-gate-1-enhanced-edition/'
ARCHIVE_OPTIONAL_ICONS_MD5='58401cf80bc9f1a9e9a0896f5d74b02a'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 24x42 32x32 48x48 64x64 256x256'

archive_initialize_optional \
	'ARCHIVE_ICONS' \
	'ARCHIVE_OPTIONAL_ICONS'
if [ -z "$ARCHIVE_ICONS" ]; then
	case "${LANG%_*}" in
		('fr')
			message='Lʼarchive suivante nʼayant pas été fournie, lʼicône spécifique à GOG sera utilisée au lieu de lʼicône originale : %s\n'
			message="$message"'Cette archive peut être téléchargée depuis %s\n'
		;;
		('en'|*)
			message='Due to the following archive missing, the GOG-specific icon will be used instead of the original one: %s\n'
			message="$message"'This archive can be downloaded from %s\n'
		;;
	esac
	print_warning
	printf "$message" "$ARCHIVE_OPTIONAL_ICONS" "$ARCHIVE_OPTIONAL_ICONS_URL"
	printf '\n'
fi

# Ensure availability of libSSL 1.0.0 (32-bit)

PKG='PKG_BIN32'
if packages_get_list | grep --quiet "$PKG"; then
	case "$OPTION_PACKAGE" in
		('arch'|'gentoo')
			# Use package from official repositories
			PKG_BIN32_DEPS_ARCH="${PKG_BIN32_DEPS_ARCH} lib32-openssl-1.0"
			PKG_BIN32_DEPS_GENTOO="${PKG_BIN32_DEPS_GENTOO} dev-libs/openssl-compat[abi_x86_32]"
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
			PKG_BIN64_DEPS_ARCH="${PKG_BIN64_DEPS_ARCH} openssl-1.0"
			PKG_BIN64_DEPS_GENTOO="${PKG_BIN64_DEPS_GENTOO} dev-libs/openssl-compat"
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

# Use original game icon if provided,
# falls back on GOG-provided icon.

PKG='PKG_DATA'
if [ -n "$ARCHIVE_ICONS" ]; then
	(
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
	organize_data 'ICONS' "$PATH_ICON_BASE"
else
	icons_get_from_workdir 'APP_MAIN'
fi

# Delete temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	if packages_get_list | grep --quiet "$PKG"; then
		use_archive_specific_value "APP_MAIN_EXE_${PKG#PKG_}"
		launchers_write 'APP_MAIN'
	fi
done

# Old 32-bit only binaries depend on libjson.so.0

PKG_BIN32_DEPS_32BIT="${PKG_BIN32_DEPS} json"
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

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

COMMON_PACKAGES='PKG_DATA PKG_BIN64'
COMMON_PACKAGES_MULTIARCH='PKG_DATA PKG_BIN32 PKG_BIN64'
COMMON_PACKAGES_32BIT='PKG_DATA PKG_BIN32'
use_archive_specific_value 'COMMON_PACKAGES'
case "${LANG%_*}" in
	('fr')
		lang_string='version %s :'
		lang_en='anglaise'
		lang_cs='tchèque'
		lang_de='allemande'
		lang_es='espagnole'
		lang_fr='française'
		lang_hu='hongroise'
		lang_it='italienne'
		lang_ja='japonaise'
		lang_ko='coréenne'
		lang_pl='polonaise'
		lang_pt='portugaise'
		lang_ru='russe'
		lang_tr='turque'
		lang_uk='ukrainienne'
		lang_zh='chinoise'
	;;
	('en'|*)
		lang_string='%s version:'
		lang_en='English'
		lang_cs='Czech'
		lang_de='German'
		lang_es='Spanish'
		lang_fr='French'
		lang_hu='Hungarian'
		lang_it='Italian'
		lang_ja='Japanese'
		lang_ko='Korean'
		lang_pl='Polish'
		lang_pt='Portuguese'
		lang_ru='Russian'
		lang_tr='Turkish'
		lang_uk='Ukrainian'
		lang_zh='Chinese'
	;;
esac
printf '\n'
printf "$lang_string" "$lang_en"
# shellcheck disable=SC2086
print_instructions $COMMON_PACKAGES
printf "$lang_string" "$lang_cs"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_CS' $COMMON_PACKAGES
printf "$lang_string" "$lang_de"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_DE' $COMMON_PACKAGES
printf "$lang_string" "$lang_es"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_ES' $COMMON_PACKAGES
printf "$lang_string" "$lang_fr"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_FR' $COMMON_PACKAGES
printf "$lang_string" "$lang_hu"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_HU' $COMMON_PACKAGES
printf "$lang_string" "$lang_it"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_IT' $COMMON_PACKAGES
printf "$lang_string" "$lang_ja"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_JA' $COMMON_PACKAGES
printf "$lang_string" "$lang_ko"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_KO' $COMMON_PACKAGES
printf "$lang_string" "$lang_pl"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_PL' $COMMON_PACKAGES
printf "$lang_string" "$lang_pt"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_PT' $COMMON_PACKAGES
printf "$lang_string" "$lang_ru"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_RU' $COMMON_PACKAGES
printf "$lang_string" "$lang_tr"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_TR' $COMMON_PACKAGES
printf "$lang_string" "$lang_uk"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_UK' $COMMON_PACKAGES
printf "$lang_string" "$lang_zh"
# shellcheck disable=SC2086
print_instructions 'PKG_L10N_ZH' $COMMON_PACKAGES

exit 0
