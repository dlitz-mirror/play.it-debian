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
# Batman: Arkham City
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210223.19

# Set game-specific variables

GAME_ID='batman-arkham-2'
GAME_NAME='Batman: Arkham City'

ARCHIVE_GOG='setup_batman_arkham_city_goty_1.1_(38264).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/batman_arkham_city_goty'
ARCHIVE_GOG_MD5='e8bfd823cfcfec2147f736bb696a85c8'
ARCHIVE_GOG_VERSION='1.1-gog38264'
ARCHIVE_GOG_SIZE='20000000'
ARCHIVE_GOG_TYPE='innosetup_nolowercase'

ARCHIVE_GOG_PART1='setup_batman_arkham_city_goty_1.1_(38264)-1.bin'
ARCHIVE_GOG_PART1_MD5='5e1213208d59a42ec0fd808bfee2f189'
ARCHIVE_GOG_PART1_TYPE='innosetup_nolowercase'

ARCHIVE_GOG_PART2='setup_batman_arkham_city_goty_1.1_(38264)-2.bin'
ARCHIVE_GOG_PART2_MD5='fa9fcbaf8ef9de81dc1638bbc9db0353'
ARCHIVE_GOG_PART2_TYPE='innosetup_nolowercase'

ARCHIVE_GOG_PART2='setup_batman_arkham_city_goty_1.1_(38264)-3.bin'
ARCHIVE_GOG_PART2_MD5='685be8b8bbd0fe3f831fb5cf0506a735'
ARCHIVE_GOG_PART2_TYPE='innosetup'

ARCHIVE_GOG_PART2='setup_batman_arkham_city_goty_1.1_(38264)-4.bin'
ARCHIVE_GOG_PART2_MD5='0ccafb2161130774710b470692ba8b39'
ARCHIVE_GOG_PART2_TYPE='innosetup'

ARCHIVE_GOG_PART2='setup_batman_arkham_city_goty_1.1_(38264)-5.bin'
ARCHIVE_GOG_PART2_MD5='2122f11dc24618e8c902e6706c26f7c2'
ARCHIVE_GOG_PART2_TYPE='innosetup'

ARCHIVE_DOC_MAIN_DE_PATH='.'
ARCHIVE_DOC_MAIN_DE_FILES='readme_DEU.rtf'

ARCHIVE_DOC_MAIN_EN_PATH='.'
ARCHIVE_DOC_MAIN_EN_FILES='readme.rtf'

ARCHIVE_DOC_MAIN_ES_PATH='.'
ARCHIVE_DOC_MAIN_ES_FILES='readme_ESN.rtf'

ARCHIVE_DOC_MAIN_FR_PATH='.'
ARCHIVE_DOC_MAIN_FR_FILES='readme_FRA.rtf'

ARCHIVE_DOC_MAIN_IT_PATH='.'
ARCHIVE_DOC_MAIN_IT_FILES='readme_ITA.rtf'

ARCHIVE_DOC_MAIN_PL_PATH='.'
ARCHIVE_DOC_MAIN_PL_FILES='readme_POL.rtf'

ARCHIVE_DOC_MAIN_PT_PATH='.'
ARCHIVE_DOC_MAIN_PT_FILES='readme_POR.rtf'

ARCHIVE_DOC_MAIN_RU_PATH='.'
ARCHIVE_DOC_MAIN_RU_FILES='readme_RUS.rtf'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='*.dll Binaries Setup BmGame/Config engine/config'

ARCHIVE_GAME_MAIN_DE_PATH='.'
ARCHIVE_GAME_MAIN_DE_FILES='BmGame/Localization/DEU'

ARCHIVE_GAME_MAIN_EN_PATH='.'
ARCHIVE_GAME_MAIN_EN_FILES='BmGame/Localization/INT'

ARCHIVE_GAME_MAIN_ES_PATH='.'
ARCHIVE_GAME_MAIN_ES_FILES='BmGame/Localization/ESN'

ARCHIVE_GAME_MAIN_FR_PATH='.'
ARCHIVE_GAME_MAIN_FR_FILES='BmGame/Localization/FRA'

ARCHIVE_GAME_MAIN_IT_PATH='.'
ARCHIVE_GAME_MAIN_IT_FILES='BmGame/Localization/ITA'

ARCHIVE_GAME_MAIN_PL_PATH='.'
ARCHIVE_GAME_MAIN_PL_FILES='BmGame/Localization/POL'

ARCHIVE_GAME_MAIN_PT_PATH='.'
ARCHIVE_GAME_MAIN_PT_FILES='BmGame/Localization/POR'

ARCHIVE_GAME_MAIN_RU_PATH='.'
ARCHIVE_GAME_MAIN_RU_FILES='BmGame/Localization/RUS'

ARCHIVE_GAME_L10N_VOICES_DE_PATH='.'
ARCHIVE_GAME_L10N_VOICES_DE_FILES='BmGame/CookedPCConsole/German'

ARCHIVE_GAME_L10N_VOICES_EN_PATH='.'
ARCHIVE_GAME_L10N_VOICES_EN_FILES='BmGame/CookedPCConsole/English(US)'

ARCHIVE_GAME_L10N_VOICES_ES_PATH='.'
ARCHIVE_GAME_L10N_VOICES_ES_FILES='BmGame/CookedPCConsole/Spanish(Spain)'

ARCHIVE_GAME_L10N_VOICES_FR_PATH='.'
ARCHIVE_GAME_L10N_VOICES_FR_FILES='BmGame/CookedPCConsole/French(France)'

ARCHIVE_GAME_L10N_VOICES_IT_PATH='.'
ARCHIVE_GAME_L10N_VOICES_IT_FILES='BmGame/CookedPCConsole/Italian'

ARCHIVE_GAME_DATA_MOVIES_PATH='.'
ARCHIVE_GAME_DATA_MOVIES_FILES='BmGame/Movies BmGame/MoviesStereo'

ARCHIVE_GAME_DATA_TEXTURES_PATH='.'
ARCHIVE_GAME_DATA_TEXTURES_FILES='BmGame/CookedPCConsole/*.tfc'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='BmGame engine'

APP_MAIN_TYPE='wine'
APP_WINETRICKS='physx'
APP_MAIN_EXE='Binaries/Win32/BmLauncher.exe'
APP_MAIN_ICON='Binaries/Win32/BmLauncher.exe'

PACKAGES_LIST='PKG_MAIN_DE PKG_MAIN_EN PKG_MAIN_ES PKG_MAIN_FR PKG_MAIN_IT PKG_MAIN_PL PKG_MAIN_PT PKG_MAIN_RU PKG_BIN PKG_L10N_VOICES_DE PKG_L10N_VOICES_EN PKG_L10N_VOICES_ES PKG_L10N_VOICES_FR PKG_L10N_VOICES_IT PKG_DATA_MOVIES PKG_DATA_TEXTURES PKG_DATA'

PKG_L10N_VOICES_ID="${GAME_ID}-l10n-voices"
PKG_L10N_VOICES_PROVIDE="$PKG_L10N_VOICES_ID"
PKG_L10N_VOICES_DESCRIPTION='localization - voices'

PKG_L10N_VOICES_DE_ID="${PKG_L10N_VOICES_ID}-de"
PKG_L10N_VOICES_DE_PROVIDE="$PKG_L10N_VOICES_PROVIDE"
PKG_L10N_VOICES_DE_DESCRIPTION="${PKG_L10N_VOICES_DESCRIPTION} - German"

PKG_L10N_VOICES_EN_ID="${PKG_L10N_VOICES_ID}-en"
PKG_L10N_VOICES_EN_PROVIDE="$PKG_L10N_VOICES_PROVIDE"
PKG_L10N_VOICES_EN_DESCRIPTION="${PKG_L10N_VOICES_DESCRIPTION} - English"

PKG_L10N_VOICES_ES_ID="${PKG_L10N_VOICES_ID}-es"
PKG_L10N_VOICES_ES_PROVIDE="$PKG_L10N_VOICES_PROVIDE"
PKG_L10N_VOICES_ES_DESCRIPTION="${PKG_L10N_VOICES_DESCRIPTION} - Spanish"

PKG_L10N_VOICES_FR_ID="${PKG_L10N_VOICES_ID}-fr"
PKG_L10N_VOICES_FR_PROVIDE="$PKG_L10N_VOICES_PROVIDE"
PKG_L10N_VOICES_FR_DESCRIPTION="${PKG_L10N_VOICES_DESCRIPTION} - French"

PKG_L10N_VOICES_IT_ID="${PKG_L10N_VOICES_ID}-it"
PKG_L10N_VOICES_IT_PROVIDE="$PKG_L10N_VOICES_PROVIDE"
PKG_L10N_VOICES_IT_DESCRIPTION="${PKG_L10N_VOICES_DESCRIPTION} - Italian"

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_DATA_MOVIES_ID="${PKG_DATA_ID}-movies"
PKG_DATA_MOVIES_DESCRIPTION="${PKG_DATA_DESCRIPTION} - movies"
PKG_DATA_DEPS="${PKG_DATA_DEPS} ${PKG_DATA_MOVIES_ID}"

PKG_DATA_TEXTURES_ID="${PKG_DATA_ID}-textures"
PKG_DATA_TEXTURES_DESCRIPTION="${PKG_DATA_DESCRIPTION} - textures"
PKG_DATA_DEPS="${PKG_DATA_DEPS} ${PKG_DATA_TEXTURES_ID}"

PKG_BIN_ID="${GAME_ID}-bin"
PKG_BIN_ARCH='32'
PKG_BIN_DESCRIPTION='binaries'

PKG_MAIN_ID="$GAME_ID"
PKG_MAIN_ARCH='32'
PKG_MAIN_PROVIDE="$PKG_MAIN_ID"
PKG_MAIN_DEPS="${PKG_BIN_ID} ${PKG_DATA_ID} ${PKG_L10N_VOICES_ID} wine winetricks xrandr"
PKG_MAIN_DEPS_DEB='dxvk-wine32-development | winetricks, dxvk | winetricks'

PKG_MAIN_DE_ID="${PKG_MAIN_ID}-de"
PKG_MAIN_DE_ARCH="$PKG_MAIN_ARCH"
PKG_MAIN_DE_PROVIDE="$PKG_MAIN_PROVIDE"
PKG_MAIN_DE_DESCRIPTION='German version'
PKG_MAIN_DE_DEPS="$PKG_MAIN_DEPS"
PKG_MAIN_DE_DEPS_DEB="$PKG_MAIN_DEPS_DEB"

PKG_MAIN_EN_ID="${PKG_MAIN_ID}-en"
PKG_MAIN_EN_ARCH="$PKG_MAIN_ARCH"
PKG_MAIN_EN_PROVIDE="$PKG_MAIN_PROVIDE"
PKG_MAIN_EN_DESCRIPTION='English version'
PKG_MAIN_EN_DEPS="$PKG_MAIN_DEPS"
PKG_MAIN_EN_DEPS_DEB="$PKG_MAIN_DEPS_DEB"

PKG_MAIN_ES_ID="${PKG_MAIN_ID}-es"
PKG_MAIN_ES_ARCH="$PKG_MAIN_ARCH"
PKG_MAIN_ES_PROVIDE="$PKG_MAIN_PROVIDE"
PKG_MAIN_ES_DESCRIPTION='Spanish version'
PKG_MAIN_ES_DEPS="$PKG_MAIN_DEPS"
PKG_MAIN_ES_DEPS_DEB="$PKG_MAIN_DEPS_DEB"

PKG_MAIN_FR_ID="${PKG_MAIN_ID}-fr"
PKG_MAIN_FR_ARCH="$PKG_MAIN_ARCH"
PKG_MAIN_FR_PROVIDE="$PKG_MAIN_PROVIDE"
PKG_MAIN_FR_DESCRIPTION='French version'
PKG_MAIN_FR_DEPS="$PKG_MAIN_DEPS"
PKG_MAIN_FR_DEPS_DEB="$PKG_MAIN_DEPS_DEB"

PKG_MAIN_IT_ID="${PKG_MAIN_ID}-it"
PKG_MAIN_IT_ARCH="$PKG_MAIN_ARCH"
PKG_MAIN_IT_PROVIDE="$PKG_MAIN_PROVIDE"
PKG_MAIN_IT_DESCRIPTION='Italian version'
PKG_MAIN_IT_DEPS="$PKG_MAIN_DEPS"
PKG_MAIN_IT_DEPS_DEB="$PKG_MAIN_DEPS_DEB"

PKG_MAIN_PL_ID="${PKG_MAIN_ID}-pl"
PKG_MAIN_PL_ARCH="$PKG_MAIN_ARCH"
PKG_MAIN_PL_PROVIDE="$PKG_MAIN_PROVIDE"
PKG_MAIN_PL_DESCRIPTION='Polish version'
PKG_MAIN_PL_DEPS="$PKG_MAIN_DEPS"
PKG_MAIN_PL_DEPS_DEB="$PKG_MAIN_DEPS_DEB"

PKG_MAIN_PT_ID="${PKG_MAIN_ID}-pt"
PKG_MAIN_PT_ARCH="$PKG_MAIN_ARCH"
PKG_MAIN_PT_PROVIDE="$PKG_MAIN_PROVIDE"
PKG_MAIN_PT_DESCRIPTION='Portuguese version'
PKG_MAIN_PT_DEPS="$PKG_MAIN_DEPS"
PKG_MAIN_PT_DEPS_DEB="$PKG_MAIN_DEPS_DEB"

PKG_MAIN_RU_ID="${PKG_MAIN_ID}-ru"
PKG_MAIN_RU_ARCH="$PKG_MAIN_ARCH"
PKG_MAIN_RU_PROVIDE="$PKG_MAIN_PROVIDE"
PKG_MAIN_RU_DESCRIPTION='Russian version'
PKG_MAIN_RU_DEPS="$PKG_MAIN_DEPS"
PKG_MAIN_RU_DEPS_DEB="$PKG_MAIN_DEPS_DEB"

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

# Store saved games in a persistent path

DATA_DIRS="$DATA_DIRS ./saves"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store saved games in a persistent path
saves_path_prefix="$WINEPREFIX/drive_c/users/$USER/My Documents/WB Games/Batman Arkham City GOTY/SaveData"
saves_path_persistent="$PATH_PREFIX/saves"
if [ ! -h "$saves_path_prefix" ]; then
	if [ -d "$saves_path_prefix" ]; then
		# Migrate existing saved games to the persistent path
		mv "$saves_path_prefix"/* "$saves_path_persistent"
		rmdir "$saves_path_prefix"
	fi
	# Create link from prefix to persistent path
	mkdir --parents "$(dirname "$saves_path_prefix")"
	ln --symbolic "$saves_path_persistent" "$saves_path_prefix"
fi'

# Store configuration in a persistent path

CONFIG_DIRS="${CONFIG_DIRS} ./config"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store configuration in a persistent path
config_path_prefix="$WINEPREFIX/drive_c/users/$USER/My Documents/WB Games/Batman Arkham City GOTY/BmGame/Config"
config_path_persistent="$PATH_PREFIX/config"
if [ ! -h "$config_path_prefix" ]; then
	if [ -d "$config_path_prefix" ]; then
		# Migrate existing configuration to the persistent path
		mv "$config_path_prefix"/* "$config_path_persistent"
		rmdir "$config_path_prefix"
	fi
	# Create link from prefix to persistent path
	mkdir --parents "$(dirname "$config_path_prefix")"
	ln --symbolic "$config_path_persistent" "$config_path_prefix"
fi'

# Install .NET 3.5 runtime in the WINE prefix

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Do not disable mscoree library
export WINEDLLOVERRIDES="winemenubuilder.exe,mshtml=d"
# Install .NET 3.5 runtime on first launch
if [ ! -e dotnet35_installed ]; then
	sleep 3s
	winetricks dotnet35
	touch dotnet35_installed
fi'

# Install shipped DirectX in the WINE prefix

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Install shipped DirectX on first launch
if [ ! -e directx9_installed ]; then
	sleep 3s
	wine Setup/DxRedist/DXSETUP.exe
	touch directx9_installed
fi'

# Enable dxvk patches in the WINE prefix

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Install dxvk on first launch
if [ ! -e dxvk_installed ]; then
	sleep 3s
	if command -v dxvk-setup >/dev/null 2>&1; then
		dxvk-setup install --development
	else
		winetricks dxvk
	fi
	touch dxvk_installed
fi'

# Set up a WINE virtual desktop on first launch, using the current desktop resolution

APP_WINETRICKS="${APP_WINETRICKS} vd=\$(xrandr|awk '/\\*/ {print \$1}')"

# Run the game binary from its directory

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Run the game binary from its directory
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Set the launcher language based on the installed texts localization

base_config_file_path='BmGame/Config/Launcher.ini'
origin_config_file="${PKG_BIN_PATH}${PATH_GAME}/${base_config_file_path}"
pattern='^\[Launcher\.Settings\]'

for lang in 'DE' 'EN' 'ES' 'FR' 'IT' 'PL' 'PT' 'RU'; do
	package_path=$(get_value "PKG_MAIN_${lang}_PATH")
	destination_config_file="${package_path}${PATH_GAME}/${base_config_file_path}"
	replacement="&\\nForceUseCulture=$(printf '%s' "$lang" | tr '[:upper:]' '[:lower:]')"
	expression="s/${pattern}/${replacement}/"
	mkdir --parents "$(dirname "$destination_config_file")"
	sed --expression="$expression" "$origin_config_file" > "$destination_config_file"
	unix2dos --quiet "$destination_config_file"
done

rm "$origin_config_file"

# Set the game language based on the installed texts localization

base_config_file_path='engine/config/BaseEngine.ini'
origin_config_file="${PKG_BIN_PATH}${PATH_GAME}/${base_config_file_path}"
pattern='^Language=.*$'

destination_config_file="${PKG_MAIN_DE_PATH}${PATH_GAME}/${base_config_file_path}"
replacement='Language=DEU'
expression="s/${pattern}/${replacement}/"
mkdir --parents "$(dirname "$destination_config_file")"
sed --expression="$expression" "$origin_config_file" > "$destination_config_file"
unix2dos --quiet "$destination_config_file"

destination_config_file="${PKG_MAIN_EN_PATH}${PATH_GAME}/${base_config_file_path}"
replacement='Language=INT'
expression="s/${pattern}/${replacement}/"
mkdir --parents "$(dirname "$destination_config_file")"
sed --expression="$expression" "$origin_config_file" > "$destination_config_file"
unix2dos --quiet "$destination_config_file"

destination_config_file="${PKG_MAIN_ES_PATH}${PATH_GAME}/${base_config_file_path}"
replacement='Language=ESN'
expression="s/${pattern}/${replacement}/"
mkdir --parents "$(dirname "$destination_config_file")"
sed --expression="$expression" "$origin_config_file" > "$destination_config_file"
unix2dos --quiet "$destination_config_file"

destination_config_file="${PKG_MAIN_FR_PATH}${PATH_GAME}/${base_config_file_path}"
replacement='Language=FRA'
expression="s/${pattern}/${replacement}/"
mkdir --parents "$(dirname "$destination_config_file")"
sed --expression="$expression" "$origin_config_file" > "$destination_config_file"
unix2dos --quiet "$destination_config_file"

destination_config_file="${PKG_MAIN_IT_PATH}${PATH_GAME}/${base_config_file_path}"
replacement='Language=ITA'
expression="s/${pattern}/${replacement}/"
mkdir --parents "$(dirname "$destination_config_file")"
sed --expression="$expression" "$origin_config_file" > "$destination_config_file"
unix2dos --quiet "$destination_config_file"

destination_config_file="${PKG_MAIN_PL_PATH}${PATH_GAME}/${base_config_file_path}"
replacement='Language=POL'
expression="s/${pattern}/${replacement}/"
mkdir --parents "$(dirname "$destination_config_file")"
sed --expression="$expression" "$origin_config_file" > "$destination_config_file"
unix2dos --quiet "$destination_config_file"

destination_config_file="${PKG_MAIN_PT_PATH}${PATH_GAME}/${base_config_file_path}"
replacement='Language=POR'
expression="s/${pattern}/${replacement}/"
mkdir --parents "$(dirname "$destination_config_file")"
sed --expression="$expression" "$origin_config_file" > "$destination_config_file"
unix2dos --quiet "$destination_config_file"

destination_config_file="${PKG_MAIN_RU_PATH}${PATH_GAME}/${base_config_file_path}"
replacement='Language=RUS'
expression="s/${pattern}/${replacement}/"
mkdir --parents "$(dirname "$destination_config_file")"
sed --expression="$expression" "$origin_config_file" > "$destination_config_file"
unix2dos --quiet "$destination_config_file"

rm "$origin_config_file"

# Write launchers

prerun_base="$APP_MAIN_PRERUN"
for lang in 'DE' 'EN' 'ES' 'FR' 'IT' 'PL' 'PT' 'RU'; do
	PKG="PKG_MAIN_${lang}"

	# Work around the binary presence check,
	# it is actually included in the binaries package
	package_path=$(get_value "${PKG}_PATH")
	fake_binary="${package_path}${PATH_GAME}/${APP_MAIN_EXE}"
	mkdir --parents "$(dirname "$fake_binary")"
	touch "$fake_binary"

	# Force language environment, to work around the lack of a game setting
	app_lang=$(printf '%s' "$lang" | tr '[:upper:]' '[:lower:]')
	APP_MAIN_PRERUN="$prerun_base
	# Force language environment, to work around the lack of a game setting
	export LANG=${app_lang}"

	launchers_write 'APP_MAIN'

	rm "$fake_binary"
	rmdir --parents --ignore-fail-on-non-empty "$(dirname "$fake_binary")"
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

case "${LANG%_*}" in
	('fr')
		lang_string='version %s :'
		lang_de='allemande'
		lang_en='anglaise'
		lang_es='espagnole'
		lang_fr='française'
		lang_it='italienne'
		lang_pl='polonaise'
		lang_pt='portugaise'
		lang_ru='russe'
	;;
	('en'|*)
		lang_string='%s version:'
		lang_de='German'
		lang_en='English'
		lang_es='Spanish'
		lang_fr='French'
		lang_it='Italian'
		lang_pl='Polish'
		lang_pt='Portuguese'
		lang_ru='Russian'
	;;
esac
printf '\n'
printf "$lang_string" "$lang_de"
print_instructions 'PKG_L10N_VOICES_DE' 'PKG_DATA_MOVIES' 'PKG_DATA_TEXTURES' 'PKG_DATA' 'PKG_BIN' 'PKG_MAIN_DE'
printf "$lang_string" "$lang_en"
print_instructions 'PKG_L10N_VOICES_EN' 'PKG_DATA_MOVIES' 'PKG_DATA_TEXTURES' 'PKG_DATA' 'PKG_BIN' 'PKG_MAIN_EN'
printf "$lang_string" "$lang_es"
print_instructions 'PKG_L10N_VOICES_ES' 'PKG_DATA_MOVIES' 'PKG_DATA_TEXTURES' 'PKG_DATA' 'PKG_BIN' 'PKG_MAIN_ES'
printf "$lang_string" "$lang_fr"
print_instructions 'PKG_L10N_VOICES_FR' 'PKG_DATA_MOVIES' 'PKG_DATA_TEXTURES' 'PKG_DATA' 'PKG_BIN' 'PKG_MAIN_FR'
printf "$lang_string" "$lang_it"
print_instructions 'PKG_L10N_VOICES_IT' 'PKG_DATA_MOVIES' 'PKG_DATA_TEXTURES' 'PKG_DATA' 'PKG_BIN' 'PKG_MAIN_IT'
printf "$lang_string" "$lang_pl"
print_instructions 'PKG_L10N_VOICES_EN' 'PKG_DATA_MOVIES' 'PKG_DATA_TEXTURES' 'PKG_DATA' 'PKG_BIN' 'PKG_MAIN_PL'
printf "$lang_string" "$lang_pt"
print_instructions 'PKG_L10N_VOICES_EN' 'PKG_DATA_MOVIES' 'PKG_DATA_TEXTURES' 'PKG_DATA' 'PKG_BIN' 'PKG_MAIN_PT'
printf "$lang_string" "$lang_ru"
print_instructions 'PKG_L10N_VOICES_EN' 'PKG_DATA_MOVIES' 'PKG_DATA_TEXTURES' 'PKG_DATA' 'PKG_BIN' 'PKG_MAIN_RU'

exit 0
