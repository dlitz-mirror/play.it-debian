#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
# Copyright (c) 2018-2019, BetaRays
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
# Q.U.B.E. 2
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20191207.1

# Set game-specific variables

GAME_ID='qube-2'
GAME_NAME='Q.U.B.E. 2'

ARCHIVE_GOG='setup_q.u.b.e._2_1.8_(64bit)_(33108).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/qube_2'
ARCHIVE_GOG_MD5='38e53c42845f1ea44ca2939d2d48571b'
ARCHIVE_GOG_SIZE='3800000'
ARCHIVE_GOG_VERSION='1.8-gog33108'
ARCHIVE_GOG_TYPE='innosetup' #5.6.2
ARCHIVE_GOG_PART1='setup_q.u.b.e._2_1.8_(64bit)_(33108)-1.bin'
ARCHIVE_GOG_PART1_MD5='838dbb204cd6eca9488d502ec16f28d0'
ARCHIVE_GOG_PART1_TYPE='innosetup' #5.6.2

ARCHIVE_GOG_OLD='setup_q.u.b.e._2_1.6_with_overlay_(64bit)_(23818).exe'
ARCHIVE_GOG_OLD_MD5='b62f5e18bff2e9abcb591e1921538989'
ARCHIVE_GOG_OLD_SIZE='3700000'
ARCHIVE_GOG_OLD_VERSION='1.6-gog23818'
ARCHIVE_GOG_OLD_TYPE='innosetup' #5.6.2
ARCHIVE_GOG_OLD_PART1='setup_q.u.b.e._2_1.6_with_overlay_(64bit)_(23818)-1.bin'
ARCHIVE_GOG_OLD_PART1_MD5='7a397b6e7c20a13c00af2ee964952609'
ARCHIVE_GOG_OLD_PART1_TYPE='innosetup' #5.6.2


ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='qube/binaries/win64/qube-win64-shipping.exe qube/binaries/win64/galaxy64.dll qube/plugins engine/binaries/thirdparty/nvidia/nvaftermath/win64/*.dll engine/binaries/thirdparty/ogg/win64/vs2015/*.dll engine/binaries/thirdparty/physx/win64/vs2015/*.dll engine/binaries/thirdparty/steamworks/steamv139/win64/*.dll engine/binaries/thirdparty/vorbis/win64/vs2015/*.dll engine/binaries/thirdparty/windows/directx/x64/*.dll'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='qube/content'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='qube/binaries/win64/qube-win64-shipping.exe'
APP_MAIN_ICON='qube/binaries/win64/qube-win64-shipping.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine-staging glx openal"

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
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launcher_write 'APP_MAIN'

# Build package

case "$OPTION_PACKAGE" in
	('gentoo')
		cat > "$postinst" <<- EOF
		ewarn 'You might need to compile wine with the openal or faudio USE flag'
		EOF
		write_metadata 'PKG_BIN'
		write_metadata 'PKG_DATA'
	;;
	(*)
		write_metadata
	;;
esac

build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
