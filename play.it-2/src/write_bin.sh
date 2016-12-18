# write launcher script
# USAGE: write_bin $app
# NEEDED VARS: $app_ID, $app_TYPE, PKG, PATH_BIN, $app_EXE
# CALLS: liberror, write_bin_header, write_bin_set_vars, write_bin_set_exe, write_bin_set_prefix, write_bin_build_userdirs, write_bin_build_prefix, write_bin_run
write_bin() {
	PKG_PATH="$(eval echo \$${PKG}_PATH)"
	local app
	for app in $@; do
		testvar "$app" 'APP' || liberror 'app' 'write_bin'
		local app_id="$(eval echo \$${app}_ID)"
		if [ -z "$app_id" ]; then
			app_id="$GAME_ID"
		fi
		local app_type="$(eval echo \$${app}_TYPE)"
		if [ "$winecfg_launcher" != 'done' ] && [ "$app_type" = 'wine' ]; then
			winecfg_launcher='done'
			write_bin_winecfg
		fi
		local file="${PKG_PATH}${PATH_BIN}/$app_id"
		mkdir --parents "${file%/*}"
		write_bin_header
		write_bin_set_vars
		if [ "$app_type" != 'scummvm' ]; then
			local app_exe="$(eval echo \$${app}_EXE)"
			local app_options="$(eval echo \$${app}_OPTIONS)"
			if [ -e "${PKG_PATH}${PATH_GAME}/$app_exe" ]; then
				chmod +x "${PKG_PATH}${PATH_GAME}/$app_exe"
			fi
			if [ "$app_id" != "${GAME_ID}_winecfg" ]; then
				write_bin_set_exe
			fi
			write_bin_set_prefix
			write_bin_build_userdirs
			write_bin_build_prefix
		fi
		write_bin_run
		sed -i 's/  /\t/g' "$file"
		chmod 755 "$file"
	done
}

# write launcher script header
# USAGE: write_bin_header
# CALLED BY: write_bin
write_bin_header() {
	cat > "$file" <<- EOF
	#!/bin/sh
	set -o errexit
	
	EOF
}

# write winecfg launcher script
# USAGE: write_bin_winecfg
# NEEDED VARS: GAME_ID
# CALLS: write_bin
write_bin_winecfg() {
	APP_WINECFG_ID="${GAME_ID}_winecfg"
	APP_WINECFG_TYPE='wine'
	APP_WINECFG_EXE='winecfg'
	write_bin 'APP_WINECFG'
	sed --in-place 's/# Run the game/# Run WINE configuration/' "${PKG_PATH}${PATH_BIN}/$APP_WINECFG_ID"
	sed --in-place 's|cd "$PATH_PREFIX"||' "${PKG_PATH}${PATH_BIN}/$APP_WINECFG_ID"
	sed --in-place 's|wine "$APP_EXE" $APP_OPTIONS $@|winecfg|' "${PKG_PATH}${PATH_BIN}/$APP_WINECFG_ID"
}

