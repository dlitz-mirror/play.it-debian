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
# Just One Must Choose
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210411.2

# Set game-specific variables

GAME_ID='just-one-must-choose'
GAME_NAME='Just One Must Choose'

ARCHIVES_LIST='
ARCHIVE_BASE_0'

ARCHIVE_BASE_0='Just one, must choose - Linux.zip'
ARCHIVE_BASE_0_MD5='1a93360c282cee3b8e11a6f04698a2dd'
ARCHIVE_BASE_0_SIZE='5100'
ARCHIVE_BASE_0_VERSION='1.0-itch.2019.08.04'
ARCHIVE_BASE_0_URL='https://gooonzalo.itch.io/just-one-must-choose'

ARCHIVE_GAME_MAIN_PATH='application.linux64'
ARCHIVE_GAME_MAIN_FILES='source lib'

###
# TODO
# "java-class" is not a real supported application type
###
APP_MAIN_TYPE='java-class'
APP_MAIN_EXE='Only_One'
APP_MAIN_JAVA_OPTIONS='-Djna.nosys=true -Djava.library.path="lib" -cp "lib/Only_One.jar:lib/core.jar:lib/jogl-all.jar:lib/gluegen-rt.jar:lib/jogl-all-natives-linux-amd64.jar:lib/gluegen-rt-natives-linux-amd64.jar"'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS="java"

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

# Write launchers

target_file="${PKG_MAIN_PATH}${PATH_BIN}/${GAME_ID}"
if [ $DRY_RUN -eq 0 ]; then
	mkdir --parents "$(dirname "$target_file")"
	touch "$target_file"
	chmod 755 "$target_file"
	launcher_write_script_headers "$target_file"
	launcher_write_script_java_application_variables 'APP_MAIN' "$target_file"
	launcher_write_script_game_variables "$target_file"
	launcher_write_script_user_files "$target_file"
	launcher_write_script_prefix_variables "$target_file"
	launcher_write_script_prefix_functions "$target_file"
	launcher_write_script_prefix_build "$target_file"
	cat >> "$target_file" <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"

	JAVA_OPTIONS="$(eval printf -- '%b' \"$JAVA_OPTIONS\")"
	java $JAVA_OPTIONS "$APP_EXE" $APP_OPTIONS "$@"

	EOF
fi
launcher_write_desktop 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
