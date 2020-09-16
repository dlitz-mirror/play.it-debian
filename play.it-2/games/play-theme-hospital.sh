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
# Theme Hospital
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200827.11

# Set game-specific variables

GAME_ID='theme-hospital'
GAME_NAME='Theme Hospital'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='setup_theme_hospital_2.1.0.8.exe'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/theme_hospital'
ARCHIVE_GOG_0_MD5='c1dc6cd19a3e22f7f7b31a72957babf7'
ARCHIVE_GOG_0_SIZE='210000'
ARCHIVE_GOG_0_VERSION='1.0-gog2.0.0.7'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='*.txt *.pdf'

ARCHIVE_GAME_DOSBOX_PATH='app'
ARCHIVE_GAME_DOSBOX_FILES='*.bat *.cfg *.exe *.ini sound/*.exe sound/*.ini sound/midi/*.bat sound/midi/*.exe'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='anims cfg data datam intro levels qdata qdatam save sound'

CONFIG_FILES='./*.ini ./*.cfg'
DATA_DIRS='./save'

# Game launchers — common properties
APP_MAIN_ICON='app/goggame-1207659026.ico'
# Game launcher — DOSBox
APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='hospital.exe'

PACKAGES_LIST='PKG_DOSBOX PKG_CORSIXTH PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

# Engine packages — common properties
PKG_ENGINE_ID="$GAME_ID"
# Engine package — DOSBox
PKG_DOSBOX_ID="${PKG_ENGINE_ID}-dosbox"
PKG_DOSBOX_PROVIDE="$PKG_ENGINE_ID"
PKG_DOSBOX_DEPS="$PKG_DATA_ID dosbox"
# Engine package — CorsixTH
PKG_CORSIXTH_ID="${PKG_ENGINE_ID}-corsixth"
PKG_CORSIXTH_PROVIDE="$PKG_ENGINE_ID"
PKG_CORSIXTH_DEPS="$PKG_DATA_ID"
PKG_CORSIXTH_DEPS_ARCH='corsix-th'
PKG_CORSIXTH_DEPS_DEB='corsix-th'

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

# Set path to CorsixTH depending on target system

case "$OPTION_PACKAGE" in
	('arch')
		PATH_CORSIXTH='/usr/share/CorsixTH'
	;;
	('deb')
		PATH_CORSIXTH='/usr/share/games/corsix-th'
	;;
	(*)
		liberror 'OPTION_PACKAGE' "$0"
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launcher for DOSBox version

PKG='PKG_DOSBOX'
launchers_write 'APP_MAIN'

# Write launcher for CorsixTH version

PKG='PKG_CORSIXTH'
target_file="${PKG_CORSIXTH_PATH}${PATH_BIN}/$GAME_ID"
mkdir --parents "$(dirname "$target_file")"
touch "$target_file"
chmod 755 "$target_file"
launcher_write_script_headers "$target_file"
cat >> "$target_file" << EOF
corsix-th "\$@"

exit 0
EOF
launcher_write_desktop 'APP_MAIN'

# Build package

###
# TODO
# Maybe this path can be passed through a runtime option instead
###
PKG_CORSIXTH_POSTINST_RUN="# Tweak default path to game data
file='$PATH_CORSIXTH/Lua/config_finder.lua'
pattern='^  theme_hospital_install = .*$'
replacement='  theme_hospital_install = [[$PATH_GAME]],'
sed --in-place \"s#\${pattern}#\${replacement}#\" \"\$file\""

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

printf '\n'
printf 'CorsixTH:'
print_instructions 'PKG_DATA' 'PKG_CORSIXTH'
printf 'DOSBox:'
print_instructions 'PKG_DATA' 'PKG_DOSBOX'

exit 0
