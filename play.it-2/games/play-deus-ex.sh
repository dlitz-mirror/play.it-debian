#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2017-2021, Phil Morrell
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
# Deus Ex
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210313.4

# Set game-specific variables

GAME_ID='deus-ex'
GAME_NAME='Deus Ex'

# sed and unix2dos are required for the edition of a configuration file
SCRIPT_DEPS='sed unix2dos'

ARCHIVES_LIST='
ARCHIVE_GOG_6
ARCHIVE_GOG_5
ARCHIVE_GOG_4
ARCHIVE_GOG_3
ARCHIVE_GOG_2
ARCHIVE_GOG_1
ARCHIVE_GOG_0
ARCHIVE_GOG_OLDTEMPLATE_3
ARCHIVE_GOG_OLDTEMPLATE_2
ARCHIVE_GOG_OLDTEMPLATE_1
ARCHIVE_GOG_OLDTEMPLATE_0'

ARCHIVE_GOG_6='setup_deus_ex_goty_1.112fm(revision_1.6.1.0)_(45326).exe'
ARCHIVE_GOG_6_MD5='688495ac0f2e6f05f1b47bdc40cee198'
ARCHIVE_GOG_6_TYPE='innosetup'
ARCHIVE_GOG_6_VERSION='1.112fm-gog45326'
ARCHIVE_GOG_6_SIZE='880000'
ARCHIVE_GOG_6_URL='https://www.gog.com/game/deus_ex'

ARCHIVE_GOG_5='setup_deus_ex_goty_1.112fm(revision_1.6.0.0)_(42784).exe'
ARCHIVE_GOG_5_MD5='0ff01014f9364c3487a5193f9ac30dc1'
ARCHIVE_GOG_5_TYPE='innosetup'
ARCHIVE_GOG_5_VERSION='1.112fm-gog42784'
ARCHIVE_GOG_5_SIZE='880000'

ARCHIVE_GOG_4='setup_deus_ex_goty_1.112fm(revision_1.5.0.0)_(35268).exe'
ARCHIVE_GOG_4_MD5='3c5693ff82d754d4fe0d6be14e5337dd'
ARCHIVE_GOG_4_TYPE='innosetup'
ARCHIVE_GOG_4_VERSION='1.112fm-gog35268'
ARCHIVE_GOG_4_SIZE='880000'

ARCHIVE_GOG_3='setup_deus_ex_goty_1.112fm_(revision_1.4.0.2)_nglide_fix_(34088).exe'
ARCHIVE_GOG_3_MD5='085d7ea792d002236999dfd3697b85de'
ARCHIVE_GOG_3_TYPE='innosetup'
ARCHIVE_GOG_3_VERSION='1.112fm-gog34088'
ARCHIVE_GOG_3_SIZE='760000'

ARCHIVE_GOG_2='setup_deus_ex_goty_1.112fm(revision_1.4.0.2)_(26650).exe'
ARCHIVE_GOG_2_MD5='ab165b74b26623ccee5bfd7b6f65f734'
ARCHIVE_GOG_2_TYPE='innosetup'
ARCHIVE_GOG_2_VERSION='1.112fm-gog26650'
ARCHIVE_GOG_2_SIZE='760000'

ARCHIVE_GOG_1='setup_deus_ex_goty_1.112fm(revision_1.4.0.1.5)_(24946).exe'
ARCHIVE_GOG_1_MD5='daa330f1e7a427af64b952cd138cfc59'
ARCHIVE_GOG_1_TYPE='innosetup'
ARCHIVE_GOG_1_VERSION='1.112fm-gog24946'
ARCHIVE_GOG_1_SIZE='760000'

ARCHIVE_GOG_0='setup_deus_ex_goty_1.112fm(revision_1.4)_(21273).exe'
ARCHIVE_GOG_0_MD5='9ec295ecad72e96fb7b9f0109dd90324'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_VERSION='1.112fm-gog21273'
ARCHIVE_GOG_0_SIZE='750000'

ARCHIVE_GOG_OLDTEMPLATE_3='setup_deus_ex_goty_1.112fm(revision_1.3.1)_(17719).exe'
ARCHIVE_GOG_OLDTEMPLATE_3_MD5='92e9e6a33642f9e6c41cb24055df9b3c'
ARCHIVE_GOG_OLDTEMPLATE_3_TYPE='innosetup'
ARCHIVE_GOG_OLDTEMPLATE_3_VERSION='1.112fm-gog17719'
ARCHIVE_GOG_OLDTEMPLATE_3_SIZE='750000'

ARCHIVE_GOG_OLDTEMPLATE_2='setup_deus_ex_goty_1.112fm(revision_1.3.0.1)_(16231).exe'
ARCHIVE_GOG_OLDTEMPLATE_2_MD5='eaaf7c7c3052fbf71f5226e2d4495268'
ARCHIVE_GOG_OLDTEMPLATE_2_TYPE='innosetup'
ARCHIVE_GOG_OLDTEMPLATE_2_VERSION='1.112fm-gog16231'
ARCHIVE_GOG_OLDTEMPLATE_2_SIZE='750000'

ARCHIVE_GOG_OLDTEMPLATE_1='setup_deus_ex_goty_1.112fm(revision_1.2.2)_(15442).exe'
ARCHIVE_GOG_OLDTEMPLATE_1_MD5='573582142424ba1b5aba1f6727276450'
ARCHIVE_GOG_OLDTEMPLATE_1_TYPE='innosetup'
ARCHIVE_GOG_OLDTEMPLATE_1_VERSION='1.112fm-gog15442'
ARCHIVE_GOG_OLDTEMPLATE_1_SIZE='750000'

ARCHIVE_GOG_OLDTEMPLATE_0='setup_deus_ex_2.1.0.12.exe'
ARCHIVE_GOG_OLDTEMPLATE_0_MD5='cc2c6e43b2e8e67c7586bbab5ef492ee'
ARCHIVE_GOG_OLDTEMPLATE_0_TYPE='innosetup'
ARCHIVE_GOG_OLDTEMPLATE_0_VERSION='1.112fm-gog2.1.0.12'
ARCHIVE_GOG_OLDTEMPLATE_0_SIZE='750000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='manual.pdf system/*.txt'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='system/*.dll system/*.exe system/*.ini system/*.int'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='system/*.u help maps music sounds textures'

# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_OLDTEMPLATE='app'
ARCHIVE_GAME_BIN_PATH_GOG_OLDTEMPLATE='app'
ARCHIVE_GAME_DATA_PATH_GOG_OLDTEMPLaTE='app'

CONFIG_FILES='./system/*.ini'
DATA_DIRS='./save'
DATA_FILES='./system/*.log'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='system/deusex.exe'
APP_MAIN_ICON='system/deusex.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine glx libxrandr"

# Run the game binary from its directory

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Run the game binary from its directory
cd "$(dirname "$APP_EXE")"
APP_EXE=$(basename "$APP_EXE")'

# Prevent the game from messing up desktop gamma values

PKG_BIN_DEPS="${PKG_BIN_DEPS} xrandr"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store current gamma values
SCREENS_ID=$(LANG=C xrandr | sed -n "s/^\\([^ ]*\\) connected\\( primary\\)\\? [0-9x+]\\+ .*$/\\1/p")
GAMMA_VALUE=$(LANG=C xrandr --verbose | sed -n "s/^\\s*Gamma:\\s*\\([0-9:.]*\\).*$/\\1/p" | head --lines=1)'
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'
# Restore previous gamma values
for screen_id in $SCREENS_ID; do
	xrandr --output $screen_id --gamma $GAMMA_VALUE
done'

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Set OpenGL as default rendering engine

config_file="${PKG_BIN_PATH}${PATH_GAME}/system/deusex.ini"
pattern='^GameRenderDevice=.*$'
replacement='GameRenderDevice=OpenGLDrv.OpenGLRenderDevice'
expression="s/${pattern}/${replacement}/"
pattern='^FirstRun=.*$'
replacement='FirstRun=1100'
expression="${expression};s/${pattern}/${replacement}/"
sed --in-place --expression="$expression" "$config_file"
unix2dos --quiet "$config_file"

# Work around a random crash on launch
# cf. https://www.gamingonlinux.com/2020/02/the-sad-case-of-unreal-engine-1-on-mesa-and-linux-in-2020/page=2#r174041

PKG_BIN_DEPS="${PKG_BIN_DEPS} winetricks"
APP_WINETRICKS="${APP_WINETRICKS} csmt=off"
launcher_write_script_wine_run() {
	# parse arguments
	# shellcheck disable=SC2039
	local application file
	application="$1"
	file="$2"

	cat >> "$file" <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"

	EOF

	launcher_write_script_prerun "$application" "$file"

	cat >> "$file" <<- 'EOF'
	taskset --cpu-list 0 wine "$APP_EXE" $APP_OPTIONS $@

	EOF

	launcher_write_script_postrun "$application" "$file"

	return 0
}

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
