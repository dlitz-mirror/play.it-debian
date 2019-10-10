#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
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
# Stellaris
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20191024.3

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris'

ARCHIVES_LIST='ARCHIVE_GOG ARCHIVE_GOG_OLD4 ARCHIVE_GOG_OLD3 ARCHIVE_GOG_OLD2 ARCHIVE_GOG_OLD1 ARCHIVE_GOG_OLD0 ARCHIVE_GOG_LIBATOMIC_OLD2 ARCHIVE_GOG_LIBATOMIC_OLD1 ARCHIVE_GOG_LIBATOMIC_OLD0 ARCHIVE_GOG_32BIT_LIBATOMIC_OLD2 ARCHIVE_GOG_32BIT_LIBATOMIC_OLD1 ARCHIVE_GOG_32BIT_LIBATOMIC_OLD0'

ARCHIVE_GOG='stellaris_2_5_0_5_33395.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/stellaris'
ARCHIVE_GOG_MD5='e3a627b94cfbb58fdcc30c8856bedda8'
ARCHIVE_GOG_SIZE='8800000'
ARCHIVE_GOG_VERSION='2.5.0.5-gog33395'
ARCHIVE_GOG_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD4='stellaris_2_4_1_1_33112.sh'
ARCHIVE_GOG_OLD4_MD5='a3b1a3651f633877bbc148dbc87292f1'
ARCHIVE_GOG_OLD4_SIZE='8200000'
ARCHIVE_GOG_OLD4_VERSION='2.4.1.1-gog33112'
ARCHIVE_GOG_OLD4_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD3='stellaris_2_4_1_33088.sh'
ARCHIVE_GOG_OLD3_MD5='41baecc3ae2c896bf1e7576536cb505c'
ARCHIVE_GOG_OLD3_SIZE='8200000'
ARCHIVE_GOG_OLD3_VERSION='2.4.1-gog33088'
ARCHIVE_GOG_OLD3_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD2='stellaris_2_4_0_7_33057.sh'
ARCHIVE_GOG_OLD2_MD5='8099b6e35224ccccf8b53b2318e0d613'
ARCHIVE_GOG_OLD2_SIZE='8200000'
ARCHIVE_GOG_OLD2_VERSION='2.4.0.7-gog33057'
ARCHIVE_GOG_OLD2_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD1='stellaris_2_3_3_1_30901.sh'
ARCHIVE_GOG_OLD1_MD5='9ae0066b06a9db81838b9d101cc6c0c8'
ARCHIVE_GOG_OLD1_SIZE='8100000'
ARCHIVE_GOG_OLD1_VERSION='2.3.3.1-gog30901'
ARCHIVE_GOG_OLD1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD0='stellaris_2_3_3_30733.sh'
ARCHIVE_GOG_OLD0_MD5='66f6274980184448230c0dfae13c6ecf'
ARCHIVE_GOG_OLD0_SIZE='8100000'
ARCHIVE_GOG_OLD0_VERSION='2.3.3-gog30733'
ARCHIVE_GOG_OLD0_TYPE='mojosetup_unzip'

ARCHIVE_GOG_LIBATOMIC_OLD2='stellaris_2_3_2_1_30253.sh'
ARCHIVE_GOG_LIBATOMIC_OLD2_MD5='a8853c2c3f6a4fbfc373f5a83c09186d'
ARCHIVE_GOG_LIBATOMIC_OLD2_SIZE='8300000'
ARCHIVE_GOG_LIBATOMIC_OLD2_VERSION='2.3.2.1-gog30253'
ARCHIVE_GOG_LIBATOMIC_OLD2_TYPE='mojosetup_unzip'

ARCHIVE_GOG_LIBATOMIC_OLD1='stellaris_2_3_1_2_30059.sh'
ARCHIVE_GOG_LIBATOMIC_OLD1_MD5='c7b9337ff20f0480dbbc73824970da00'
ARCHIVE_GOG_LIBATOMIC_OLD1_SIZE='8300000'
ARCHIVE_GOG_LIBATOMIC_OLD1_VERSION='2.3.1.2-gog30059'
ARCHIVE_GOG_LIBATOMIC_OLD1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_LIBATOMIC_OLD0='stellaris_2_3_0_4x_30009.sh'
ARCHIVE_GOG_LIBATOMIC_OLD0_MD5='304e1947c98af6efc7c3ca520971f2d6'
ARCHIVE_GOG_LIBATOMIC_OLD0_SIZE='8300000'
ARCHIVE_GOG_LIBATOMIC_OLD0_VERSION='2.3.0.4x-gog30009'
ARCHIVE_GOG_LIBATOMIC_OLD0_TYPE='mojosetup_unzip'

ARCHIVE_GOG_32BIT_OLD2='stellaris_2_2_7_2_28548.sh'
ARCHIVE_GOG_32BIT_OLD2_MD5='b94f2d07b5a81e864582d24701d6f7f1'
ARCHIVE_GOG_32BIT_OLD2_SIZE='8100000'
ARCHIVE_GOG_32BIT_OLD2_VERSION='2.2.7.2-gog28548'
ARCHIVE_GOG_32BIT_OLD2_TYPE='mojosetup_unzip'

ARCHIVE_GOG_32BIT_OLD1='stellaris_2_2_6_4_28215.sh'
ARCHIVE_GOG_32BIT_OLD1_MD5='ede0f1b747db3cb36b2826b6400a11dd'
ARCHIVE_GOG_32BIT_OLD1_SIZE='8100000'
ARCHIVE_GOG_32BIT_OLD1_VERSION='2.2.6.4-gog28215'
ARCHIVE_GOG_32BIT_OLD1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_32BIT_OLD0='stellaris_2_2_4_26846.sh'
ARCHIVE_GOG_32BIT_OLD0_MD5='1773c3e91920b7b335c8962882b108e3'
ARCHIVE_GOG_32BIT_OLD0_SIZE='8100000'
ARCHIVE_GOG_32BIT_OLD0_VERSION='2.2.4-gog26846'
ARCHIVE_GOG_32BIT_OLD0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='*.dll *.dylib *.py *.so *.so.* stellaris pdx_browser pdx_launcher pdx_online_assets'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='*.txt common dlc events flags fonts gfx interface licenses locales localisation localisation_synced map music prescripted_countries previewer_assets sound tweakergui_assets'

APP_MAIN_TYPE='native_no-prefix'
APP_MAIN_EXE='stellaris'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx"
PKG_BIN_DEPS_ARCH='util-linux libx11 zlib'
PKG_BIN_DEPS_DEB='libuuid1, libx11-6, zlib1g, libgcc1'
PKG_BIN_DEPS_GENTOO='sys-apps/util-linux x11-libs/libX11 sys-libs/zlib'
# Keep support for old archives (dependency on libatomic.so.1)
PKG_BIN_DEPS_DEB_GOG_LIBATOMIC='libuuid1, libx11-6, zlib1g, libgcc1, libatomic1'
PKG_BIN_DEPS_GENTOO_GOG_LIBATOMIC='sys-apps/util-linux x11-libs/libX11 sys-libs/zlib sys-devel/gcc'
# Keep support for old archives (32-bit build)
PKG_BIN_ARCH_GOG_32BIT='32'
PKG_BIN_DEPS_GOG_32BIT="$PKG_DATA_ID glibc libstdc++ glu glx alsa xcursor"
PKG_BIN_DEPS_ARCH_GOG_32BIT='lib32-util-linux lib32-libx11 lib32-zlib'
PKG_BIN_DEPS_DEB_GOG_32BIT='libuuid1, libx11-6, zlib1g, libgcc1'
PKG_BIN_DEPS_GENTOO_GOG_32BIT='sys-apps/util-linux[abi_x86_32] x11-libs/libX11[abi_x86_32] sys-libs/zlib[abi_x86_32] sys-devel/gcc[abi_x86_32]'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launcher_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
