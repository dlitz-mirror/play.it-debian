#!/bin/sh -e
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
# send your bug reports to mopi@dotslashplay.it
###

script_version=20190120.3

# Set game-specific variables

GAME_ID='gathering-sky'
GAME_NAME='Gathering Sky'

ARCHIVE_HUMBLE='GatheringSky_Linux_64bit.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/gathering-sky'
ARCHIVE_HUMBLE_MD5='c590edce835070a1ac2ae47ac620dc48'
ARCHIVE_HUMBLE_SIZE='1200000'
ARCHIVE_HUMBLE_VERSION='1.0-humble1'
ARCHIVE_HUMBLE_TYPE='zip_unclean'

ARCHIVE_GAME_MAIN_PATH='packr/linux/GatheringSky'
ARCHIVE_GAME_MAIN_FILES='desktop-0.1.jar'

APP_MAIN_TYPE='java'
APP_MAIN_JAVA_OPTIONS='-Xmx1G'
APP_MAIN_EXE='desktop-0.1.jar'
APP_MAIN_ICONS_LIST='APP_MAIN_ICON_16 APP_MAIN_ICON_32 APP_MAIN_ICON_128'
APP_MAIN_ICON_16='images/Icon_16.png'
APP_MAIN_ICON_32='images/Icon_32.png'
APP_MAIN_ICON_128='images/Icon_128.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='java'
# Easier upgrade from packages generated with pre-20190120.3 scripts
PKG_MAIN_PROVIDE='gathering-sky-data'

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
#shellcheck source=play.it-2/lib/libplayit2.sh
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
	ARCHIVE_JAR="${PKG_MAIN_PATH}${PATH_GAME}/desktop-0.1.jar"
	ARCHIVE_JAR_TYPE='zip'
	ARCHIVE='ARCHIVE_JAR'
	extract_data_from "$ARCHIVE_JAR"
)
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
