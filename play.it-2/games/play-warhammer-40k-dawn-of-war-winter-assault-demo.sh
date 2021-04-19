#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2020-2021, Hoël Bézier
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
# Warhammer 40,000: Dawn of War - Winter Assault Demo
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210423.1

# Set game-specific variables

GAME_ID='warhammer-40k-dawn-of-war-winter-assault-demo'
GAME_NAME='Warhammer 40,000: Dawn of War - Winter Assault Demo'

SCRIPT_DEPS='cabextract unix2dos'

ARCHIVES_LIST='
ARCHIVE_BASE_0'

ARCHIVE_BASE_0='Dawn of War - Winter Assault.rar'
ARCHIVE_BASE_0_MD5='555f5b3844c80866b0cb9fa536692380'
ARCHIVE_BASE_0_VERSION='1.0-archiveorg1'
ARCHIVE_BASE_0_SIZE='480000'
ARCHIVE_BASE_0_URL='https://archive.org/details/DawnOfWarWinterAssault_201404'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='bugreport drivers *.dll *.exe *.ini'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='badges banners engine graphicsoptions logfiles patch playback profiles screenshots stats w40k wxp *.module'

CONFIG_DIRS='./drivers'
CONFIG_FILES='./*.ini'
DATA_DIRS='./badges ./banners ./playback ./profiles ./screenshots ./stats'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='winterassault.exe'
APP_MAIN_ICON='winterassault.exe'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_NAME="$GAME_NAME - graphics configuration"
APP_CONFIG_CAT='Settings'
APP_CONFIG_TYPE='wine'
APP_CONFIG_EXE='graphicsconfig.exe'
APP_CONFIG_ICON='graphicsconfig.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

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

# Extract installer from RAR archive

extract_data_from "$SOURCE_ARCHIVE"
rm "$PLAYIT_WORKDIR"/gamedata/*.exe
rm "$PLAYIT_WORKDIR"/gamedata/*.ini
rm "$PLAYIT_WORKDIR"/gamedata/*.msi

# Extract game data from cabinet installer

ARCHIVE_INNER="$PLAYIT_WORKDIR/gamedata/WinterAssaultDemo1.cab"
ARCHIVE_INNER_TYPE='cabinet'
ARCHIVE='ARCHIVE_INNER' \
	extract_data_from "$ARCHIVE_INNER"
if [ $DRY_RUN -eq 0 ]; then
	rm "$ARCHIVE_INNER"
fi
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"

# Create expected game arborescence

(
	# Skip this step in dry-run mode
	test $DRY_RUN -eq 1 && exit 0

	cd "$PLAYIT_WORKDIR/gamedata"
	mkdir --parents 'badges'
	mkdir --parents 'banners'
	mkdir --parents 'bugreport/english'
	mkdir --parents 'drivers'
	mkdir --parents 'engine'
	mkdir --parents 'engine/data'
	mkdir --parents 'engine/locale/english'
	mkdir --parents 'engine/movies'
	mkdir --parents 'graphicsoptions/data'
	mkdir --parents 'graphicsoptions/locale/english'
	mkdir --parents 'logfiles'
	mkdir --parents 'patch'
	mkdir --parents 'playback'
	mkdir --parents 'profiles'
	mkdir --parents 'screenshots'
	mkdir --parents 'stats'
	mkdir --parents 'w40k'
	mkdir --parents 'w40k/data'
	mkdir --parents 'w40k/locale/english'
	mkdir --parents 'wxp'
	mkdir --parents 'wxp/data'
	mkdir --parents 'wxp/locale/english'
	mkdir --parents 'wxp/movies'
	mv 'bugreport.exe'                  'bugreport/bugreport.exe'
	mv 'bugreport.ini'                  'bugreport/bugreport.ini'
	mv 'bugreport.ucs'                  'bugreport/english/bugreport.ucs'
	mv 'ati.txt'                        'drivers/ati.txt'
	mv 'nvidia.txt'                     'drivers/nvidia.txt'
	mv 'shader.txt'                     'drivers/shader.txt'
	mv 'spdx9_config.txt'               'drivers/spdx9_config.txt'
	mv 'engine.sga'                     'engine/engine.sga'
	mv 'engine.ucs'                     'engine/locale/english/engine.ucs'
	mv 'enginloc.sga'                   'engine/locale/english/enginloc.sga'
	mv 'dow_intro.avi'                  'engine/movies/dow_intro.avi'
	mv 'dow_intro.lua'                  'engine/movies/dow_intro.lua'
	mv 'dxp_relic_intro.avi'            'engine/movies/dxp_relic_intro.avi'
	mv 'dxp_relic_intro.lua'            'engine/movies/dxp_relic_intro.lua'
	mv 'gotdata.sga'                    'graphicsoptions/gotdata.sga'
	mv 'graphicsoptionsutility.ucs'     'graphicsoptions/locale/english/graphicsoptionsutility.ucs'
	mv 'w40k.ucs'                       'w40k/locale/english/w40k.ucs'
	mv 'w40kdatasoundspeech.sga'        'w40k/locale/english/w40kdata-sound-speech.sga'
	mv 'w40kdatakeys.sga'               'w40k/locale/english/w40kdatakeys.sga'
	mv 'w40kdataloc.sga'                'w40k/locale/english/w40kdataloc.sga'
	mv 'w40kdata.sga'                   'w40k/w40kdata.sga'
	mv 'w40kdatasharedtexturesfull.sga' 'w40k/w40kdata-sharedtextures-full.sga'
	mv 'w40kdatasoundmed.sga'           'w40k/w40kdata-sound-med.sga'
	mv 'w40kdatawhmmedium.sga'          'w40k/w40kdata-whm-medium.sga'
	mv 'wxp.ucs'                        'wxp/locale/english/wxp.ucs'
	mv 'wxpdatasoundspeech.sga'         'wxp/locale/english/wxpdata-sound-speech.sga'
	mv 'wxpdatakeys.sga'                'wxp/locale/english/wxpdatakeys.sga'
	mv 'wxpdataloc.sga'                 'wxp/locale/english/wxpdataloc.sga'
	mv 'wxp_order.avi'                  'wxp/movies/wxp_order.avi'
	mv 'wxp_order.lua'                  'wxp/movies/wxp_order.lua'
	mv 'wxpdata.sga'                    'wxp/wxpdata.sga'
	mv 'wxpdatamusic.sga'               'wxp/wxpdata-music.sga'
	mv 'wxpdatasharedtexturesfull.sga'  'wxp/wxpdata-sharedtextures-full.sga'
	mv 'wxpdatasoundmed.sga'            'wxp/wxpdata-sound-med.sga'
	mv 'wxpdatawhmmedium.sga'           'wxp/wxpdata-whm-medium.sga'
)

# Work around mouse cursor rendering issues

pattern='^allowhwcursor.*$'
replacement='allowhwcursor 0'
file="$PLAYIT_WORKDIR/gamedata/drivers/spdx9_config.txt"
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place "s/$pattern/$replacement/" "$file"
fi

# Generate required configuration file

file="$PLAYIT_WORKDIR/gamedata/regions.ini"
if [ $DRY_RUN -eq 0 ]; then
	cat > "$file" <<- 'EOF'
	[mods]
	wxp=english
	[global]
	lang=english
	EOF
	unix2dos "$file" 2>/dev/null
fi

# Prepare package arborescence

prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_CONFIG'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_CONFIG'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
