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

script_version=20210421.4

# Set game-specific variables

GAME_ID='baldurs-gate-1-enhanced-edition'
GAME_NAME='Baldurʼs Gate - Enhanced Edition'

ARCHIVES_LIST='
ARCHIVE_BASE_0
ARCHIVE_BASE_32BIT_2
ARCHIVE_BASE_32BIT_1
ARCHIVE_BASE_32BIT_0'

ARCHIVE_BASE_0='baldur_s_gate_enhanced_edition_en_2_5_23121.sh'
ARCHIVE_BASE_0_MD5='853f6e66db6cc5a4df0f72d23d65fcf7'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='3300000'
ARCHIVE_BASE_0_VERSION='2.5.17.0-gog23121'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/baldurs_gate_enhanced_edition'

ARCHIVE_BASE_32BIT_2='baldur_s_gate_enhanced_edition_en_2_3_67_3_20146.sh'
ARCHIVE_BASE_32BIT_2_MD5='4d08fe21fcdeab51624fa2e0de2f5813'
ARCHIVE_BASE_32BIT_2_SIZE='3200000'
ARCHIVE_BASE_32BIT_2_VERSION='2.3.67.3-gog20146'
ARCHIVE_BASE_32BIT_2_TYPE='mojosetup'

ARCHIVE_BASE_32BIT_1='gog_baldur_s_gate_enhanced_edition_2.5.0.9.sh'
ARCHIVE_BASE_32BIT_1_MD5='224be273fd2ec1eb0246f407dda16bc4'
ARCHIVE_BASE_32BIT_1_SIZE='3200000'
ARCHIVE_BASE_32BIT_1_VERSION='2.3.67.3-gog2.5.0.9'

ARCHIVE_BASE_32BIT_0='gog_baldur_s_gate_enhanced_edition_2.5.0.7.sh'
ARCHIVE_BASE_32BIT_0_MD5='37ece59534ca63a06f4c047d64b82df9'
ARCHIVE_BASE_32BIT_0_SIZE='3200000'
ARCHIVE_BASE_32BIT_0_VERSION='2.3.67.3-gog2.5.0.7'

ARCHIVE_OPTIONAL_ICONS='baldurs-gate-1-enhanced-edition_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_URL='https://downloads.dotslashplay.it/resources/baldurs-gate-1-enhanced-edition/'
ARCHIVE_OPTIONAL_ICONS_MD5='58401cf80bc9f1a9e9a0896f5d74b02a'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='BaldursGate'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='BaldursGate64'

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

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 24x42 32x32 48x48 64x64 256x256'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='BaldursGate'
APP_MAIN_EXE_BIN64='BaldursGate64'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_L10N_CS PKG_L10N_DE PKG_L10N_ES PKG_L10N_FR PKG_L10N_HU PKG_L10N_IT PKG_L10N_JA PKG_L10N_KO PKG_L10N_PL PKG_L10N_PT PKG_L10N_RU PKG_L10N_TR PKG_L10N_UK PKG_L10N_ZH PKG_DATA'

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

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc libstdc++ glx openal libxrandr alsa xcursor"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Keep compatibility with old archives

PACKAGES_LIST_BASE_32BIT='PKG_BIN32 PKG_L10N_CS PKG_L10N_DE PKG_L10N_ES PKG_L10N_FR PKG_L10N_HU PKG_L10N_IT PKG_L10N_JA PKG_L10N_KO PKG_L10N_PL PKG_L10N_PT PKG_L10N_RU PKG_L10N_TR PKG_L10N_UK PKG_L10N_ZH PKG_DATA'

# Easier upgrade from packages generated with pre-20180926.3 scripts

PKG_BIN32_PROVIDE='baldurs-gate-enhanced-edition'
PKG_BIN64_PROVIDE='baldurs-gate-enhanced-edition'
PKG_L10N_PROVIDE='baldurs-gate-enhanced-edition-l10n'

# Easier upgrade from packages generated with pre-20210421.4 scripts

PKG_DATA_PROVIDE='baldurs-gate-1-enhanced-edition-l10n'

# Load common functions

target_version='2.12'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
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

# Ensure availability of 32-bit libssl.so.1.0.0

case "$OPTION_PACKAGE" in
	('arch')
		# Use package from official repositories
		PKG_BIN32_DEPS_ARCH="$PKG_BIN32_DEPS_ARCH lib32-openssl-1.0"
	;;
	('deb')
		# Use archive provided by ./play.it
		ARCHIVE_OPTIONAL_LIBSSL32='libssl_1.0.0_32-bit.tar.gz'
		ARCHIVE_OPTIONAL_LIBSSL32_URL='https://downloads.dotslashplay.it/resources/libssl/'
		ARCHIVE_OPTIONAL_LIBSSL32_MD5='9443cad4a640b2512920495eaf7582c4'
		ARCHIVE_MAIN="$ARCHIVE"
		set_archive 'ARCHIVE_LIBSSL32' 'ARCHIVE_OPTIONAL_LIBSSL32'
		if [ "$ARCHIVE_LIBSSL32" ]; then
			extract_data_from "$ARCHIVE_LIBSSL32"
			mkdir --parents "${PKG_BIN32_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
			mv "$PLAYIT_WORKDIR"/gamedata/* "${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
			rm --recursive "$PLAYIT_WORKDIR/gamedata"
		else
			case "${LANG%_*}" in
				('fr')
					message='Lʼarchive suivante nʼayant pas été fournie, libssl.so.1.0.0 ne sera pas inclus dans les paquets : %s\n'
					message="$message"'Cette archive peut être téléchargée depuis %s\n'
				;;
				('en'|*)
					message='Due to the following archive missing, the packages will not include libssl.so.1.0.0: %s\n'
					message="$message"'This archive can be downloaded from %s\n'
				;;
			esac
			print_warning
			printf "$message" "$ARCHIVE_OPTIONAL_LIBSSL32" "$ARCHIVE_OPTIONAL_LIBSSL32_URL"
			printf '\n'
		fi
		ARCHIVE="$ARCHIVE_MAIN"
	;;
	('gentoo')
		# Use package from official repositories
		PKG_BIN32_DEPS_GENTOO="$PKG_BIN32_DEPS_GENTOO dev-libs/openssl-compat[abi_x86_32]"
	;;
	(*)
		# Unsupported package type, throw an error
		liberror 'OPTION_PACKAGE' "$0"
	;;
esac

# Ensure availability of 64-bit libssl.so.1.0.0
# This library is not required for the older archives only providing 32-bit binaries

if [ -z "${PACKAGES_LIST##*PKG_BIN64*}" ]; then
	case "$OPTION_PACKAGE" in
		('arch')
			# Use package from official repositories
			PKG_BIN64_DEPS_ARCH="$PKG_BIN64_DEPS_ARCH openssl-1.0"
		;;
		('deb')
			# Use archive provided by ./play.it
			ARCHIVE_OPTIONAL_LIBSSL64='libssl_1.0.0_64-bit.tar.gz'
			ARCHIVE_OPTIONAL_LIBSSL64_URL='https://downloads.dotslashplay.it/resources/libssl/'
			ARCHIVE_OPTIONAL_LIBSSL64_MD5='89917bef5dd34a2865cb63c2287e0bd4'
			ARCHIVE_MAIN="$ARCHIVE"
			set_archive 'ARCHIVE_LIBSSL64' 'ARCHIVE_OPTIONAL_LIBSSL64'
			if [ "$ARCHIVE_LIBSSL64" ]; then
				extract_data_from "$ARCHIVE_LIBSSL64"
				mkdir --parents "${PKG_BIN64_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
				mv "$PLAYIT_WORKDIR"/gamedata/* "${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
				rm --recursive "$PLAYIT_WORKDIR/gamedata"
			else
				case "${LANG%_*}" in
					('fr')
						message='Lʼarchive suivante nʼayant pas été fournie, libssl.so.1.0.0 ne sera pas inclus dans les paquets : %s\n'
						message="$message"'Cette archive peut être téléchargée depuis %s\n'
					;;
					('en'|*)
						message='Due to the following archive missing, the packages will not include libssl.so.1.0.0: %s\n'
						message="$message"'This archive can be downloaded from %s\n'
					;;
				esac
				print_warning
				printf "$message" "$ARCHIVE_OPTIONAL_LIBSSL64" "$ARCHIVE_OPTIONAL_LIBSSL64_URL"
				printf '\n'
			fi
			ARCHIVE="$ARCHIVE_MAIN"
		;;
		('gentoo')
			# Use package from official repositories
			PKG_BIN64_DEPS_GENTOO="$PKG_BIN64_DEPS_GENTOO dev-libs/openssl-compat"
		;;
		(*)
			# Unsupported package type, throw an error
			liberror 'OPTION_PACKAGE' "$0"
		;;
	esac
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icons

PKG='PKG_DATA'
if [ "$ARCHIVE_ICONS" ]; then
	ARCHIVE_MAIN="$ARCHIVE"
	ARCHIVE='ARCHIVE_ICONS'
	extract_data_from "$ARCHIVE_ICONS"
	ARCHIVE="$ARCHIVE_MAIN"
	organize_data 'ICONS' "$PATH_ICON_BASE"
else
	icons_get_from_workdir 'APP_MAIN'
fi
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN32'
launchers_write 'APP_MAIN'
case "$ARCHIVE" in
	('ARCHIVE_BASE_32BIT'*)
		# No 64-bit binary provided
	;;
	(*)
		PKG='PKG_BIN64'
		launchers_write 'APP_MAIN'
	;;
esac

# Build package

case "$ARCHIVE" in
	('ARCHIVE_BASE_32BIT'*)
		# Old 32-bit version depends on libjson.so.0
		PKG_BIN32_DEPS="$PKG_BIN32_DEPS json"
		case "$OPTION_PACKAGE" in
			('arch'|'gentoo')
				LIB_PATH='/usr/lib32'
			;;
			('deb')
				LIB_PATH='/lib/i386-linux-gnu'
			;;
			(*)
				# Unsupported package type, throw an error
				liberror 'OPTION_PACKAGE' "$0"
			;;
		esac
		cat > "$postinst" <<- EOF
		if \
		    [ ! -e "$LIB_PATH/libjson.so.0" ] && \
		    [ ! -e "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0" ]
		then
		    for file in \
		        libjson-c.so \
		        libjson-c.so.2 \
		        libjson-c.so.3
		    do
		        if [ -e "$LIB_PATH/\$file" ] ; then
		            mkdir --parents "$PATH_GAME/${APP_MAIN_LIBS:=libs}"
		            ln --symbolic "$LIB_PATH/\$file" "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
		            break
		        fi
		    done
		fi
		EOF
		cat > "$prerm" <<- EOF
		if [ -e "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0" ]; then
		    rm "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
		fi
		EOF
		write_metadata 'PKG_BIN32'
		write_metadata 'PKG_L10N_CS' 'PKG_L10N_DE' 'PKG_L10N_ES' 'PKG_L10N_FR' 'PKG_L10N_HU' 'PKG_L10N_IT' 'PKG_L10N_JA' 'PKG_L10N_KO' 'PKG_L10N_PL' 'PKG_L10N_PT' 'PKG_L10N_RU' 'PKG_L10N_TR' 'PKG_L10N_UK' 'PKG_L10N_ZH' 'PKG_DATA'
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
printf "$lang_string" "$lang_hu"
print_instructions 'PKG_L10N_HU' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_it"
print_instructions 'PKG_L10N_IT' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_ja"
print_instructions 'PKG_L10N_JA' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_ko"
print_instructions 'PKG_L10N_KO' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_pl"
print_instructions 'PKG_L10N_PL' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_pt"
print_instructions 'PKG_L10N_PT' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_ru"
print_instructions 'PKG_L10N_RU' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_tr"
print_instructions 'PKG_L10N_TR' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_uk"
print_instructions 'PKG_L10N_UK' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'
# shellcheck disable=SC2059
printf "$lang_string" "$lang_zh"
print_instructions 'PKG_L10N_ZH' 'PKG_DATA' 'PKG_BIN32' 'PKG_BIN64'

exit 0
