if [ "${0##*/}" != 'libplayit2.sh' ] && [ -z "$LIB_ONLY" ]; then

	# Set input field separator to default value (space, tab, newline)
	unset IFS

	# Check library version against script target version

	version_major_library="${library_version%%.*}"
	# shellcheck disable=SC2154
	version_major_target="${target_version%%.*}"

	version_minor_library=$(printf '%s' "$library_version" | cut --delimiter='.' --fields=2)
	# shellcheck disable=SC2154
	version_minor_target=$(printf '%s' "$target_version" | cut --delimiter='.' --fields=2)

	if [ $version_major_library -ne $version_major_target ] || [ $version_minor_library -lt $version_minor_target ]; then
		print_error
		case "${LANG%_*}" in
			('fr')
				string1='Mauvaise version de libplayit2.sh\n'
				string2='La version cible est : %s\n'
			;;
			('en'|*)
				string1='Wrong version of libplayit2.sh\n'
				string2='Target version is: %s\n'
			;;
		esac
		printf "$string1"
		# shellcheck disable=SC2154
		printf "$string2" "$target_version"
		exit 1
	fi

	# Set URLs for error messages

	PLAYIT_GAMES_BUG_TRACKER_URL='https://framagit.org/vv221/play.it-games/issues'
	PLAYIT_BUG_TRACKER_URL='https://forge.dotslashplay.it/play.it/scripts/issues'

	# Set allowed values for common options

	# shellcheck disable=SC2034
	ALLOWED_VALUES_ARCHITECTURE='all 32 64 auto'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_CHECKSUM='none md5'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_COMPRESSION='none gzip xz bzip2'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_PACKAGE='arch deb gentoo'

	# Set default values for common options

	# shellcheck disable=SC2034
	DEFAULT_OPTION_ARCHITECTURE='all'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_CHECKSUM='md5'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_COMPRESSION='none'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_PREFIX='/usr/local'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_PACKAGE='deb'
	unset winecfg_desktop
	unset winecfg_launcher

	# Parse arguments given to the script

	unset OPTION_ARCHITECTURE
	unset OPTION_CHECKSUM
	unset OPTION_COMPRESSION
	unset OPTION_PREFIX
	unset OPTION_PACKAGE
	unset SOURCE_ARCHIVE
	DRY_RUN='0'
	NO_FREE_SPACE_CHECK='0'

	while [ $# -gt 0 ]; do
		case "$1" in
			('--help')
				help
				exit 0
			;;
			('--architecture='*|\
			 '--architecture'|\
			 '--checksum='*|\
			 '--checksum'|\
			 '--compression='*|\
			 '--compression'|\
			 '--prefix='*|\
			 '--prefix'|\
			 '--package='*|\
			 '--package')
				if [ "${1%=*}" != "${1#*=}" ]; then
					option="$(printf '%s' "${1%=*}" | sed 's/^--//')"
					value="${1#*=}"
				else
					option="$(printf '%s' "$1" | sed 's/^--//')"
					value="$2"
					shift 1
				fi
				if [ "$value" = 'help' ]; then
					eval help_$option
					exit 0
				else
					# shellcheck disable=SC2046
					eval OPTION_$(printf '%s' "$option" | tr '[:lower:]' '[:upper:]')=\"$value\"
					# shellcheck disable=SC2046
					export OPTION_$(printf '%s' "$option" | tr '[:lower:]' '[:upper:]')
				fi
				unset option
				unset value
			;;
			('--dry-run')
				DRY_RUN='1'
				export DRY_RUN
			;;
			('--skip-free-space-check')
				NO_FREE_SPACE_CHECK='1'
				export NO_FREE_SPACE_CHECK
			;;
			('--'*)
				print_error
				case "${LANG%_*}" in
					('fr')
						string='Option inconnue : %s\n'
					;;
					('en'|*)
						string='Unkown option: %s\n'
					;;
				esac
				printf "$string" "$1"
				return 1
			;;
			(*)
				if [ -f "$1" ]; then
					SOURCE_ARCHIVE="$1"
					export SOURCE_ARCHIVE
				else
					error_not_a_file "$1"
				fi
			;;
		esac
		shift 1
	done

	# Try to detect the host distribution if no package format has been explicitely set

	[ "$OPTION_PACKAGE" ] || packages_guess_format 'OPTION_PACKAGE'

	# Set options not already set by script arguments to default values

	for option in 'ARCHITECTURE' 'CHECKSUM' 'COMPRESSION' 'PREFIX'; do
		if [ -z "$(get_value "OPTION_$option")" ]\
		&& [ -n "$(get_value "DEFAULT_OPTION_$option")" ]; then
			# shellcheck disable=SC2046
			eval OPTION_$option=\"$(get_value "DEFAULT_OPTION_$option")\"
			export OPTION_$option
		fi
	done

	# Check options values validity

	for option in 'CHECKSUM' 'COMPRESSION' 'PACKAGE'; do
		check_option_validity "$option"
	done

	# Do not allow bzip2 compression when building Debian packages

	if
		[ "$OPTION_PACKAGE" = 'deb' ] && \
		[ "$OPTION_COMPRESSION" = 'bzip2' ]
	then
		print_error
		case "${LANG%_*}" in
			('fr')
				# shellcheck disable=SC1112
				string='Le mode de compression bzip2 n’est pas compatible avec la génération de paquets deb.'
			;;
			('en'|*)
				string='bzip2 compression mode is not compatible with deb packages generation.'
			;;
		esac
		printf '%s\n' "$string"
		exit 1
	fi

	# Do not allow none compression when building Gentoo packages

	if
		[ "$OPTION_PACKAGE" = 'gentoo' ] && \
		[ "$OPTION_COMPRESSION" = 'none' ]
	then
		print_error
		case "${LANG%_*}" in
			('fr')
				# shellcheck disable=SC1112
				string='Le mode de compression none n’est pas compatible avec la génération de paquets gentoo.'
			;;
			('en'|*)
				string='none compression mode is not compatible with gentoo packages generation.'
			;;
		esac
		printf '%s\n' "$string"
		exit 1
	fi

	# Restrict packages list to target architecture

	select_package_architecture

	# Check script dependencies

	check_deps

	# Set package paths

	case $OPTION_PACKAGE in
		('arch'|'gentoo')
			PATH_BIN="$OPTION_PREFIX/bin"
			PATH_DESK='/usr/local/share/applications'
			PATH_DOC="$OPTION_PREFIX/share/doc/$GAME_ID"
			PATH_GAME="$OPTION_PREFIX/share/$GAME_ID"
			PATH_ICON_BASE='/usr/local/share/icons/hicolor'
		;;
		('deb')
			PATH_BIN="$OPTION_PREFIX/games"
			PATH_DESK='/usr/local/share/applications'
			PATH_DOC="$OPTION_PREFIX/share/doc/$GAME_ID"
			PATH_GAME="$OPTION_PREFIX/share/games/$GAME_ID"
			PATH_ICON_BASE='/usr/local/share/icons/hicolor'
		;;
		(*)
			liberror 'OPTION_PACKAGE' "$0"
		;;
	esac

	# Set main archive

	archives_get_list
	archive_set_main $ARCHIVES_LIST

	# Set working directories

	set_temp_directories $PACKAGES_LIST

fi
