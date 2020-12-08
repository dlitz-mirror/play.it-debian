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
# Gathering Sky
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200919.1

# Set game-specific variables

GAME_ID='gathering-sky'
GAME_NAME='Gathering Sky'

ARCHIVES_LIST='
ARCHIVE_HUMBLE_0
'

ARCHIVE_HUMBLE_0='GatheringSky_Linux_64bit.zip'
ARCHIVE_HUMBLE_0_URL='https://www.humblebundle.com/store/gathering-sky'
ARCHIVE_HUMBLE_0_MD5='c590edce835070a1ac2ae47ac620dc48'
ARCHIVE_HUMBLE_0_SIZE='1200000'
ARCHIVE_HUMBLE_0_VERSION='1.0-humble1'
ARCHIVE_HUMBLE_0_TYPE='zip_unclean'

ARCHIVE_GAME_DATA_PATH='packr/linux/GatheringSky'
ARCHIVE_GAME_DATA_FILES='desktop-0.1.jar'

ARCHIVE_GAME_BIN_SHIPPED_PATH='packr/linux/GatheringSky'
ARCHIVE_GAME_BIN_SHIPPED_FILES='config.json GatheringSky jre'

# Common to both launchers
APP_MAIN_PRERUN='# Ensure settings can be stored
mkdir --parents "$HOME/.prefs"'
APP_MAIN_ICONS_LIST='APP_MAIN_ICON_16 APP_MAIN_ICON_32 APP_MAIN_ICON_128'
APP_MAIN_ICON_16='images/Icon_16.png'
APP_MAIN_ICON_32='images/Icon_32.png'
APP_MAIN_ICON_128='images/Icon_128.png'
# Using system-provided Java
APP_MAIN_TYPE_BIN_SYSTEM='java'
APP_MAIN_JAVA_OPTIONS_BIN_SYSTEM='-Xmx1G'
APP_MAIN_EXE_BIN_SYSTEM='desktop-0.1.jar'
# Using shipped binaries
APP_MAIN_TYPE_BIN_SHIPPED='native'
APP_MAIN_EXE_BIN_SHIPPED='GatheringSky'

PACKAGES_LIST='PKG_BIN_SHIPPED PKG_BIN_SYSTEM PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

# Common to both binaries packages
PKG_BIN_ID="$GAME_ID"
# Using system-provided Java
PKG_BIN_SYSTEM_ID="${PKG_BIN_ID}-bin-system"
PKG_BIN_SYSTEM_PROVIDE="$PKG_BIN_ID"
PKG_BIN_SYSTEM_DEPS="$PKG_DATA_ID java"
PKG_BIN_SYSTEM_DESCRIPTION='Using system-provided Java'
# Using shipped binaries
PKG_BIN_SHIPPED_ARCH='64'
PKG_BIN_SHIPPED_ID="${PKG_BIN_ID}-bin-shipped"
PKG_BIN_SHIPPED_PROVIDE="$PKG_BIN_ID"
PKG_BIN_SHIPPED_DEPS="$PKG_DATA_ID glibc libstdc++"
PKG_BIN_SYSTEM_DESCRIPTION='Using shipped binaries'

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
(
	ARCHIVE_INNER="$PLAYIT_WORKDIR/gamedata/GatheringSky.tar.gz"
	ARCHIVE_INNER_TYPE='tar.gz'
	ARCHIVE='ARCHIVE_INNER'
	extract_data_from "$ARCHIVE_INNER"
	rm "$ARCHIVE_INNER"
)
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icons

(
	ARCHIVE_JAR="${PKG_DATA_PATH}${PATH_GAME}/desktop-0.1.jar"
	ARCHIVE_JAR_TYPE='zip'
	ARCHIVE='ARCHIVE_JAR'
	extract_data_from "$ARCHIVE_JAR"
)
PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

###
# TODO
# Using the package specific value of APP_TYPE should always be done by the library
###

PKG='PKG_BIN_SHIPPED'
use_package_specific_value 'APP_MAIN_TYPE'
launchers_write 'APP_MAIN'

###
# TODO
# A file presence check introduced by the 2.11.4 update is bypassed
# The check itself should probably be improved instead
###

PKG='PKG_BIN_SYSTEM'
use_package_specific_value 'APP_MAIN_TYPE'
binary_file="${PKG_BIN_SYSTEM_PATH}${PATH_GAME}/${APP_MAIN_EXE_BIN_SYSTEM}"
if [ $DRY_RUN -eq 0 ]; then
	mkdir --parents "$(dirname "$binary_file")"
	touch "$binary_file"
fi
launchers_write 'APP_MAIN'
if [ $DRY_RUN -eq 0 ]; then
	rm "$binary_file"
	rmdir --ignore-fail-on-non-empty --parents "$(dirname "$binary_file")"
fi

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
# shellcheck disable=SC2059
printf "$message" "$bin_shipped"
print_instructions 'PKG_BIN_SHIPPED' 'PKG_DATA'
# shellcheck disable=SC2059
printf "$message" "$bin_system"
print_instructions 'PKG_BIN_SYSTEM' 'PKG_DATA'

exit 0
