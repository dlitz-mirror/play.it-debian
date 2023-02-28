# Print the name of the renderer to use for Direct3D
# USAGE: wine_renderer_name
wine_renderer_name() {
	# Fetch the preferred renderer from the game script,
	# if it is explicitely set.
	local direct3d_renderer
	direct3d_renderer="${WINE_DIRECT3D_RENDERER:-}"
	## Fall back to using the default renderer
	if [ -z "$direct3d_renderer" ]; then
		direct3d_renderer='default'
	fi

	# Convert "wined3d" alias to "wined3d/gl"
	if [ "$direct3d_renderer" = 'wined3d' ]; then
		direct3d_renderer='wined3d/gl'
	fi

	# Check that an allowed value has been set
	case "$direct3d_renderer" in
		( \
			'default' | \
			'wined3d/gl' | \
			'wined3d/gdi' | \
			'wined3d/vulkan' | \
			'dxvk' | \
			'vkd3d' \
		)
			printf '%s' "$direct3d_renderer"
			return 0
		;;
		(*)
			error_unknown_wine_renderer "$direct3d_renderer"
			return 1
		;;
	esac
}

# Print the snippet to include to launchers to set the correct Direct3D renderer
# USAGE: wine_renderer_launcher_snippet
wine_renderer_launcher_snippet() {
	local direct3d_renderer
	direct3d_renderer=$(wine_renderer_name)

	case "$direct3d_renderer" in
		('default')
			# Nothing to do here.
		;;
		( \
			'wined3d/gl' | \
			'wined3d/gdi' | \
			'wined3d/vulkan' \
		)
			local wined3d_backend
			wined3d_backend=$(printf '%s' "$direct3d_renderer" | cut --delimiter='/' --fields=2)
			wine_renderer_launcher_snippet_wined3d "$wined3d_backend"
		;;
		('dxvk')
			wine_renderer_launcher_snippet_dxvk
		;;
		('vkd3d')
			wine_renderer_launcher_snippet_vkd3d
		;;
	esac
}

# Print the snippet to include to launchers to use WinieD3D with a specific backend
# USAGE: wine_renderer_launcher_snippet_wined3d $wined3d_backend
wine_renderer_launcher_snippet_wined3d() {
	local wined3d_backend
	wined3d_backend="$1"
	cat <<- EOF
	# Use WineD3D for Direct3D rendering, with the "$wined3d_backend" backend
	wined3d_backend="$wined3d_backend"
	EOF
	cat <<- 'EOF'
	if command -v winetricks >/dev/null 2>&1; then
	    winetricks_wrapper renderer=$wined3d_backend
	else
	    message="\\033[1;33mWarning:\\033[0m\\n"
	    message="${message}WineD3D backend could not be set to ${wined3d_backend}.\\n"
	    message="${message}The game might run with display or performance issues.\\n"
	    printf "\\n${message}\\n"
	fi
	# Wait a bit to ensure there is no lingering wine process
	sleep 1s
	EOF

	# Automatically add required dependencies to the current package
	local package dependency_library
	package=$(context_package)
	case "$wined3d_backend" in
		('gl')
			dependency_library='libGL.so.1'
		;;
		('vulkan')
			dependency_library='libvulkan.so.1'
		;;
	esac
	dependencies_add_native_libraries "$package" "$dependency_library"
	dependencies_add_generic "$package" 'winetricks'
}

# Print the snippet to include to launchers to use DXVK as the Direct3D renderer
# USAGE: wine_renderer_launcher_snippet_dxvk
wine_renderer_launcher_snippet_dxvk() {
	cat <<- 'EOF'
	# Use DXVK for Direct3D 9/10/11 rendering
	if \
	    command -v dxvk-setup >/dev/null 2>&1 && \
	    command -v wine-development >/dev/null 2>&1
	then
	    ## Run dxvk-setup, spawning a terminal if required
	    ## to ensure it is not silently running in the background.
	    if [ ! -t 0 ] && command -v xterm >/dev/null; then
	        xterm -e dxvk-setup install --development
	    else
	        dxvk-setup install --development
	    fi
	elif command -v winetricks >/dev/null 2>&1; then
	    winetricks_wrapper dxvk
	else
	    message="\\033[1;33mWarning:\\033[0m\\n"
	    message="${message}DXVK patches could not be installed in the WINE prefix.\\n"
	    message="${message}The game might run with display or performance issues.\\n"
	    printf "\\n${message}\\n"
	fi
	# Wait a bit to ensure there is no lingering wine process
	sleep 1s
	EOF

	# Automatically add required dependencies to the current package
	local package
	package=$(context_package)
	dependencies_add_native_libraries "$package" 'libvulkan.so.1'
	dependencies_add_generic "$package" 'winetricks'
}

# Print the snippet to include to launchers to use vkd3d as the Direct3D renderer
# USAGE: wine_renderer_launcher_snippet_vkd3d
wine_renderer_launcher_snippet_vkd3d() {
	cat <<- 'EOF'
	# Install vkd3d on first launch
	if command -v winetricks >/dev/null 2>&1; then
	    winetricks_wrapper vkd3d
	else
	    message="\\033[1;33mWarning:\\033[0m\\n"
	    message="${message}vkd3d patches could not be installed in the WINE prefix.\\n"
	    message="${message}The game might run with display or performance issues.\\n"
	    printf "\\n${message}\\n"
	fi
	# Wait a bit to ensure there is no lingering wine process
	sleep 1s
	EOF

	# Automatically add required dependencies to the current package
	local package
	package=$(context_package)
	dependencies_add_native_libraries "$package" 'libvulkan.so.1'
	dependencies_add_generic "$package" 'winetricks'
}
