#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
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
# SHENZHEN I/O
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190616.1

# Set game-specific variables

GAME_ID='shenzhen-io'
GAME_NAME='SHENZHEN I/O'

ARCHIVE_GOG='shenzhen_io_en_13_02_18613.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/shenzhen_io'
ARCHIVE_GOG_MD5='d7a3ccb58512bdc511d4fe8977480ff9'
ARCHIVE_GOG_VERSION='13.02-gog18613'
ARCHIVE_GOG_SIZE='450000'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='./*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game/Content'
ARCHIVE_DOC1_DATA_FILES='./*.pdf'

ARCHIVE_DOC2_DATA_PATH='data/noarch/game'
ARCHIVE_DOC2_DATA_FILES='LICENSE.txt'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='*.dll Shenzhen.exe Shenzhen.exe.config'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Content PackedContent'

DATA_FILES='Content/textures/desktop/loading.psd Content/textures/buttons/bottom.psd Content/textures/buttons/bottom_disabled.psd Content/textures/buttons/bottom_hover.psd Content/textures/buttons/inset_left.psd Content/textures/buttons/inset_middle.psd Content/textures/buttons/inset_right.psd Content/textures/buttons/top.psd Content/textures/buttons/top_hover.psd Content/textures/buttons/top_selected.psd Content/textures/buttons/virtual.psd Content/textures/buttons/virtual_hover.psd Content/textures/buttons/virtual_orange.psd Content/textures/buttons/virtual_orange_hover.psd Content/textures/buttons/virtual_white.psd Content/textures/buttons/virtual_white_hover.psd Content/textures/control_panel/list_drop.psd Content/textures/control_panel/slider_fill.psd Content/textures/desktop/border.psd Content/textures/desktop/border_no_gap.psd Content/textures/editor/background.psd Content/textures/editor/graph_data.psd Content/textures/editor/graph_data_initial.psd Content/textures/editor/graph_display.psd Content/textures/editor/graph_label.psd Content/textures/editor/panel.psd Content/textures/editor/parts_message.psd Content/textures/editor/parts_slider.psd Content/textures/editor/puzzle_info_left.psd Content/textures/editor/puzzle_info_right.psd Content/textures/editor/score_indicator_background.psd Content/textures/editor/tooltip.psd Content/textures/histograms/border_back.psd Content/textures/histograms/border_front.psd Content/textures/messenger/border_challenge.psd Content/textures/messenger/border_graphs.psd Content/textures/messenger/border_normal.psd Content/textures/messenger/divider_normal.psd Content/textures/messenger/inbox_divider.psd Content/textures/messenger/inbox_highlight.psd Content/textures/parts/hover.psd Content/textures/parts/hover_note.psd Content/textures/solitaire/card_back_upgrade.psd Content/textures/system_bar/body.psd Content/textures/system_bar/edge.psd Content/textures/window/left.psd Content/textures/window/list.psd Content/textures/window/list_with_buttons.psd Content/textures/window/main.psd Content/textures/window/main_alt.psd Content/textures/window/right.psd Content/textures/window/slider.psd PackedContent/fonts/notosans_cjk_regular_12.0_10_v4.packedfont PackedContent/fonts/notosans_cjk_bold_12.0_10_v4.packedfont PackedContent/fonts/notosans_cjk_regular_13.0_10_v4.packedfont PackedContent/fonts/notosans_cjk_bold_13.0_10_v4.packedfont PackedContent/fonts/notosans_cjk_regular_16.0_10_v4.packedfont PackedContent/fonts/notosans_cjk_bold_16.0_10_v4.packedfont PackedContent/fonts/notosans_cjk_regular_17.0_10_v4.packedfont PackedContent/fonts/notosans_cjk_bold_17.0_10_v4.packedfont PackedContent/fonts/notoserif_cjk_regular_32.0_10_v4.packedfont PackedContent/fonts/notosans_mono_cjk_regular_13.0_10_v4.packedfont PackedContent/fonts/roboto_regular_13.0_3_v4.packedfont PackedContent/fonts/roboto_bold_13.0_3_v4.packedfont PackedContent/fonts/roboto_italic_13.0_3_v4.packedfont PackedContent/fonts/roboto_regular_14.0_3_v4.packedfont PackedContent/fonts/roboto_bold_14.0_3_v4.packedfont PackedContent/fonts/roboto_italic_14.0_3_v4.packedfont PackedContent/fonts/roboto_regular_18.0_3_v4.packedfont PackedContent/fonts/roboto_bold_18.0_3_v4.packedfont PackedContent/fonts/roboto_italic_18.0_3_v4.packedfont PackedContent/fonts/glacial_regular_15.0_3_v4.packedfont PackedContent/fonts/glacial_bold_14.0_3_v4.packedfont PackedContent/fonts/glacial_italic_15.0_3_v4.packedfont PackedContent/fonts/glacial_regular_17.0_3_v4.packedfont PackedContent/fonts/glacial_bold_17.0_3_v4.packedfont PackedContent/fonts/glacial_italic_17.0_3_v4.packedfont PackedContent/fonts/sinkin_regular_12.0_3_v4.packedfont PackedContent/fonts/inconsolata_regular_14.0_3_v4.packedfont PackedContent/fonts/inconsolata_bold_14.0_3_v4.packedfont PackedContent/fonts/glacial_bold_22.0_3_v4.packedfont PackedContent/fonts/crimson_regular_36.0_3_v4.packedfont PackedContent/fonts/crimson_italic_36.0_3_v4.packedfont PackedContent/fonts/crimson_regular_44.0_3_v4.packedfont'

APP_MAIN_TYPE='mono'
APP_MAIN_EXE='Shenzhen.exe'
APP_MAIN_ICON='Content/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_DEPS="$PKG_DATA_ID mono"

# Load common functions

target_version='2.12'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	for path in\
		'./'\
		"$XDG_DATA_HOME/play.it/"\
		"$XDG_DATA_HOME/play.it/play.it-2/lib/"\
		'/usr/local/share/games/play.it/'\
		'/usr/local/share/play.it/'\
		'/usr/share/games/play.it/'\
		'/usr/share/play.it/'
	do
		if [ -z "$PLAYIT_LIB2" ] && [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
	if [ -z "$PLAYIT_LIB2" ]; then
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
organize_data 'DOC1_DATA' "$PATH_DOC"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launcher_write 'APP_MAIN'

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
for manual in 'SHENZHEN_IO_Manual_Chinese.pdf' 'SHENZHEN_IO_Manual_English.pdf' 'SHENZHEN_IO_Manual.pdf'; do
	cat >> "$postinst" <<- EOF
	if [ ! -e "$PATH_GAME/$manual" ]; then
	    ln --symbolic "$PATH_DOC/$manual" "$PATH_GAME/Content/"
	fi
	EOF
	cat >> "$prerm" << EOF
	if [ -e "$PATH_GAME/Content/$manual" ]; then
	    rm "$PATH_GAME/Content/$manual"
	fi
EOF
done
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
