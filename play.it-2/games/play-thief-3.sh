#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2017-2020, Jacek Szafarkiewicz
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
# Thief 3: Deadly Shadows
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201031.16

# Set game-specific variables

GAME_ID='thief-3'
GAME_NAME='Thief 3: Deadly Shadows'

ARCHIVES_LIST='
ARCHIVE_GOG_0'

ARCHIVE_GOG_0='setup_thief3_2.0.0.6.exe'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/thief_3'
ARCHIVE_GOG_0_MD5='e5b84de58a1037f3e8aa3a1bb2a982be'
ARCHIVE_GOG_0_VERSION='1.1-gog2.0.0.6'
ARCHIVE_GOG_0_SIZE='2300000'
ARCHIVE_GOG_0_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='*.pdf eula.txt readme.rtf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.dll *.reg system/*.exe system/*.dll'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='*.ini system content'

APP_REGEDIT='thief.reg'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='system/t3.exe'
APP_MAIN_ICON='gfw_high.ico'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Ensure smooth upgrade from pre-20201031.16 packages
PKG_BIN_PROVIDE='thief3'
PKG_DATA_PROVIDE='thief3-data'

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

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Set up required registry keys

registry_file="${PKG_BIN_PATH}${PATH_GAME}/thief.reg"
cat > "$registry_file" << 'EOF'
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\Software\Ion Storm]

[HKEY_LOCAL_MACHINE\Software\Ion Storm\Thief - Deadly Shadows]
EOF
cat >> "$registry_file" << EOF
"ION_ROOT"="C:\\\\$GAME_ID"
"SaveGamePath"="C:\\\\$GAME_ID\\\\saves"
EOF
cat >> "$registry_file" << 'EOF'
[HKEY_LOCAL_MACHINE\Software\Ion Storm\Thief - Deadly Shadows\SecuROM]

[HKEY_LOCAL_MACHINE\Software\Ion Storm\Thief - Deadly Shadows\SecuROM\Locale]
"ADMIN_RIGHTS"="Application requires Windows administrator rights."
"ANALYSIS_DISCLAIMER"="Dear Software User,\\n\\nThis test program has been developed with your personal interest in mind to check for possible hardware and/or software incompatibility on your PC. To shorten the analysis time, system information is collected (similar to the Microsoft's msinfo32.exe program).\\n\\nData will be compared with our knowledge base to discover hardware/software conflicts. Submitting the log file is totally voluntary. The collected data is for evaluation purposes only and is not used in any other manner.\\n\\nYour Support Team\\n\\nDo you want to start?"
"ANALYSIS_DONE"="The Information was successfully collected and stored to the following file:\\n\\n\\\"%FILE%\\\"\\n\\nPlease contact Customer Support for forwarding instructions."
"AUTH_TIMEOUT"="Unable to authenticate original disc within time limit."
"EMULATION_DETECTED"="Conflict with Disc Emulator Software detected."
"NO_DISC"="No disc inserted."
"NO_DRIVE"="No CD or DVD drive found."
"NO_ORIG_FOUND"="Please insert the original disc instead of a backup."
"TITLEBAR"="Thief: Deadly Shadows"
"WRONG_DISC"="Wrong Disc inserted.  Please insert the Thief: Deadly Shadows disc into your CD/DVD drive."
EOF

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
