#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dtoslashplay.it>
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
# Litil Divil
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210326.1

# Set game-specific variables

GAME_ID='litil-divil'
GAME_NAME='Litil Divil'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0'

ARCHIVE_GOG_1='gog_litil_divil_2.0.0.22.sh'
ARCHIVE_GOG_1_MD5='89a1a0cedbf13d8e6aed285780b69def'
ARCHIVE_GOG_1_TYPE='mojosetup'
ARCHIVE_GOG_1_SIZE='45000'
ARCHIVE_GOG_1_VERSION='1.0-gog2.0.0.22'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/litil_divil'

ARCHIVE_GOG_0='gog_litil_divil_2.0.0.21.sh'
ARCHIVE_GOG_0_MD5='1258be406cb4b40c912c4846df2ac92b'
ARCHIVE_GOG_0_TYPE='mojosetup'
ARCHIVE_GOG_0_SIZE='44000'
ARCHIVE_GOG_0_VERSION='1.0-gog2.0.0.21'

ARCHIVE_DOC0_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC0_MAIN_FILES='*.txt *.pdf'

ARCHIVE_DOC1_MAIN_PATH='data/noarch/data'
ARCHIVE_DOC1_MAIN_FILES='config.doc'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='*.cfg *.exe data gfx'

CONFIG_FILES='./divils.cfg'

GAME_IMAGE='data'
GAME_IMAGE_TYPE='cdrom'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='data/divil.exe'
APP_MAIN_OPTIONS='c:'
APP_MAIN_ICON='data/noarch/support/icon.png'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_NAME="${GAME_NAME} - configuration"
APP_CONFIG_CAT='Settings'
APP_CONFIG_TYPE='dosbox'
APP_CONFIG_EXE='config.exe'
APP_CONFIG_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'

# Ensure smooth updates from pre-20210217.2 scripts

PKG_MAIN_PROVIDE='litil-divil-data'

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
tolower "${PLAYIT_WORKDIR}/gamedata"
prepare_package_layout

# Get game icon

icons_get_from_workdir 'APP_MAIN' 'APP_CONFIG'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

launchers_write 'APP_CONFIG'

# Run the game binary from the CD-ROM directory

###
# TODO
# This function override could be avoided by fixing the special behaviour of APP_xxx_PRERUN with DOSBox games
###
launcher_write_script_dosbox_run() {
	local application file
	application="$1"
	file="$2"
	cat >> "$file" <<- EOF
	# Run the game

	cd "\$PATH_PREFIX"
	APP_EXE=\$(basename "\$APP_EXE")
	"\${PLAYIT_DOSBOX_BINARY:-dosbox}" -c "mount c .
	c:
	mount d $GAME_IMAGE -t cdrom
	d:
	\$APP_EXE \$APP_OPTIONS \$@
	exit"
	EOF
	return 0
}

launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
