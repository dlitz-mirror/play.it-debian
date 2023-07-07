# WINE launcher - Print the script content
# USAGE: wine_launcher $application
wine_launcher() {
	local application
	application="$1"

	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('symlinks')
			launcher_headers
			wine_launcher_environment "$application"

			# Generate the game prefix
			launcher_prefix_symlinks_functions
			launcher_prefix_symlinks_build

			# Set up the paths diversion to persistent storage
			persistent_storage_initialization
			persistent_storage_common
			persistent_path_diversion
			persistent_storage_update_directories
			persistent_storage_update_files

			# Generate the WINE prefix
			wine_launcher_wineprefix_environment
			wine_launcher_wineprefix_generate
			wine_launcher_wineprefix_persistent

			# Handle persistent storage of registry keys
			wine_launcher_regedit_environment
			wine_launcher_regedit_load

			wine_launcher_run "$application"

			# Handle persistent storage of registry keys
			wine_launcher_regedit_store

			# Update persistent storage with files from the current prefix
			persistent_storage_update_files_from_prefix

			launcher_exit
		;;
		(*)
			error_launchers_prefix_type_unsupported "$application"
			return 1
		;;
	esac

	# Automatically add required dependencies to the current package
	if ! variable_is_empty 'APP_WINETRICKS'; then
		local package
		package=$(context_package)
		dependencies_add_command "$package" 'winetricks'
	fi
}

# WINE launcher - Set the environment
# USAGE: wine_launcher_environment $application
wine_launcher_environment() {
	local application
	application="$1"

	local game_id path_game application_exe application_options
	game_id=$(game_id)
	path_game=$(path_game_data)
	application_exe=$(application_exe_escaped "$application")
	application_options=$(application_options "$application")

	cat <<- EOF
	# Set the environment

	GAME_ID='$game_id'
	PATH_GAME='$path_game'
	APP_EXE='$application_exe'
	APP_OPTIONS="$application_options"

	EOF
	{
		cat <<- 'EOF'
		## Print the path to the `wine` command
		wine_command() {
		    if [ -z "$PLAYIT_WINE_CMD" ]; then
		        command -v wine
		        return 0
		    fi
		    printf '%s' "$PLAYIT_WINE_CMD"
		}
		wineboot_command() {
		    wine_command | sed 's#/wine$#/wineboot#'
		}

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'
	## The `wineserver` command is only used by winetricks
	if \
		[ -n "${APP_WINETRICKS:-}" ] || \
		[ -n "${WINE_DIRECT3D_RENDERER:-}" ]
	then
		{
			cat <<- 'EOF'
			wineserver_command() {
			    wine_command | sed 's#/wine$#/wineserver#'
			}

			EOF
		} | sed --regexp-extended 's/( ){4}/\t/g'
	fi
	## Include the path to the `regedit` command only if it is going to be used
	if \
		[ -n "${APP_REGEDIT:-}" ] || \
		[ -n "${WINE_REGEDIT_PERSISTENT_KEYS:-}" ]
	then
		{
			cat <<- 'EOF'
			regedit_command() {
			    wine_command | sed 's#/wine$#/regedit#'
			}

			EOF
		} | sed --regexp-extended 's/( ){4}/\t/g'
	fi

	# Include the winetricks wrapper function only if it is going to be used
	if \
		[ -n "${APP_WINETRICKS:-}" ] || \
		[ -n "${WINE_DIRECT3D_RENDERER:-}" ]
	then
		{
			cat <<- 'EOF'
			## Apply winetricks verbs, spawning a terminal if required
			winetricks_wrapper() {
			    ## Export custom paths to WINE commands
			    ## so winetricks use them instead of the default paths
			    WINE=$(wine_command)
			    WINESERVER=$(wineserver_command)
			    WINEBOOT=$(wineboot_command)
			    export WINE WINESERVER WINEBOOT

			    ## Run winetricks, spawning a terminal if required
			    ## to ensure it is not silently running in the background
			    if [ -t 0 ] || command -v zenity kdialog >/dev/null; then
			        winetricks "$@"
			    elif command -v xterm >/dev/null; then
			        xterm -e winetricks "$@"
			    else
			        winetricks "$@"
			    fi

			    ## Wait a bit for lingering WINE processes to terminate
			    sleep 1s
			}

			EOF
		} | sed --regexp-extended 's/( ){4}/\t/g'
	fi
}

# WINE - Print the snippet handling the actual run of the game
# USAGE: wine_launcher_run $application
wine_launcher_run() {
	local application
	application="$1"

	local application_type_variant
	application_type_variant=$(application_type_variant "$application")

	cat <<- 'EOF'
	# Run the game

	cd "${WINEPREFIX}/drive_c/${GAME_ID}"

	EOF

	case "$application_type_variant" in
		('unity3d')
			# Use a dedicated log file for the current game session
			launcher_unity3d_dedicated_log
		;;
	esac

	application_prerun "$application"

	cat <<- 'EOF'

	## Do not exit on application failure,
	## to ensure post-run commands are run.
	set +o errexit
	## Silence ShellCheck false-positive
	## Double quote to prevent globbing and word splitting.
	# shellcheck disable=SC2086
	$(wine_command) "$APP_EXE" $APP_OPTIONS "$@"
	game_exit_status=$?
	set -o errexit

	EOF

	application_postrun "$application"
}
