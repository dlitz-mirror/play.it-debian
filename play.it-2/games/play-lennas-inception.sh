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
# Lenna’s Inception
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210418.7

# Set game-specific variables

GAME_ID='lennas-inception'
GAME_NAME='Lennaʼs Inception'

ARCHIVES_LIST='
ARCHIVE_BASE_1
ARCHIVE_BASE_0'

ARCHIVE_BASE_1='lennas-inception-linux-amd64-stable.zip'
ARCHIVE_BASE_1_MD5='5f7ff7b389777b00519144df1cc98cc9'
ARCHIVE_BASE_1_VERSION='1.1.5-itch.2020.11.22'
ARCHIVE_BASE_1_SIZE='310000'
ARCHIVE_BASE_1_URL='https://tccoxon.itch.io/lennas-inception'

###
# TODO
# Currently (./play.it 2.12) our library is not able to handle multiple archives with a same file name
# This archive is always ignored due to another with the same file name being set before it
###
ARCHIVE_BASE_0='lennas-inception-linux-amd64-stable.zip'
ARCHIVE_BASE_0_MD5='e701126a913c2c63c89e79875dd89e86'
ARCHIVE_BASE_0_VERSION='1.0.10-itch1'
ARCHIVE_BASE_0_SIZE='310000'

ARCHIVE_DOC_MAIN_PATH='.'
ARCHIVE_DOC_MAIN_FILES='COPYRIGHT.txt README.txt'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='assets launch-config.json lib'

APP_MAIN_TYPE='java'
APP_MAIN_EXE='lib/libloader.jar'
APP_MAIN_JAVA_OPTIONS='-Dsun.java2d.opengl=True -Djava.library.path=./lib -Xms1024m -Xmx3072m'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='java'

# Since this game seems to be broken on OpenJDK ≥ 11, we build an extra package allowing to use the shipped OpenJDK 1.8

ARCHIVE_GAME_BIN_SHIPPED_PATH='.'
ARCHIVE_GAME_BIN_SHIPPED_FILES='launch-config.json jre'

PACKAGES_LIST="${PACKAGES_LIST} PKG_BIN_SYSTEM PKG_BIN_SHIPPED"

PKG_BIN_ID="${GAME_ID}-bin"
PKG_BIN_PROVIDE="$PKG_BIN_ID"

PKG_BIN_SYSTEM_ID="${PKG_BIN_ID}-system"
PKG_BIN_SYSTEM_PROVIDE="$PKG_BIN_PROVIDE"
PKG_BIN_SYSTEM_DESCRIPTION='Using system-provided Java'

PKG_BIN_SHIPPED_ID="${PKG_BIN_ID}-shipped"
PKG_BIN_SHIPPED_PROVIDE="$PKG_BIN_PROVIDE"
PKG_BIN_SHIPPED_DESCRIPTION='Using shipped Java binaries'
PKG_BIN_SHIPPED_ARCH='64'

PKG_MAIN_DEPS="${PKG_MAIN_DEPS} ${PKG_BIN_ID}"

# Explicitely set the requirements used for the icon inclusion

SCRIPT_DEPS="${SCRIPT_DEPS} unzip identify"

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
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get game icon from the inner Java archive

APP_MAIN_ICON='icon.png'

PKG='PKG_MAIN'
icon_archive="${PKG_MAIN_PATH}${PATH_GAME}/assets/lennasinception.jar"
unzip -q -d "$PLAYIT_WORKDIR/gamedata" "$icon_archive" "$APP_MAIN_ICON"
icons_get_from_workdir 'APP_MAIN'

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

###
# TODO
# Work around the binary file presence check
# Current library (./play.it 2.12) does not check all packages for the binary presence
###

dummy_file_system="${PKG_BIN_SHIPPED_PATH}${PATH_GAME}/${APP_MAIN_EXE}"
dummy_file_shipped="${PKG_BIN_SYSTEM_PATH}${PATH_GAME}/${APP_MAIN_EXE}"
mkdir --parents "$(dirname "$dummy_file_system")"
mkdir --parents "$(dirname "$dummy_file_shipped")"
touch "$dummy_file_system"
touch "$dummy_file_shipped"

PKG='PKG_BIN_SYSTEM'
launchers_write 'APP_MAIN'

###
# TODO
# When generating launchers for Java games, we should use ${PLAYIT_JAVA_BINARY:-java} instead of hardcoded "java"
###

PKG='PKG_BIN_SHIPPED'
launchers_write 'APP_MAIN'

shipped_java_binary='jre/bin/java'
chmod 755 "${PKG_BIN_SHIPPED_PATH}${PATH_GAME}/${shipped_java_binary}"

launcher_file="${PKG_BIN_SHIPPED_PATH}${PATH_BIN}/${GAME_ID}"
pattern='^java '
replacement="./${shipped_java_binary} "
expression="s#${pattern}#${replacement}#"
sed --in-place --expression="$expression" "$launcher_file"

rm "$dummy_file_system"
rm "$dummy_file_shipped"
rmdir --parents --ignore-fail-on-non-empty "$(dirname "$dummy_file_system")"
rmdir --parents --ignore-fail-on-non-empty "$(dirname "$dummy_file_shipped")"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

case "${LANG%_*}" in
	('fr')
		message='Utilisation des binaires fournis par %s :'
		bin_shipped='les développeurs'
		bin_system='le système'
	;;
	('en'|*)
		message='Using binaries provided by %s:'
		bin_shipped='the developers'
		bin_system='the system'
	;;
esac
printf '\n'
printf "$message" "$bin_system"
print_instructions 'PKG_MAIN' 'PKG_BIN_SYSTEM'
printf "$message" "$bin_shipped"
print_instructions 'PKG_MAIN' 'PKG_BIN_SHIPPED'

exit 0
