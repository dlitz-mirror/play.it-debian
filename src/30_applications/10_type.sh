# Print the type of the given application
# USAGE: application_type $application
# RETURN: the application type keyword, from the supported values:
#         - dosbox
#         - java
#         - mono
#         - native
#         - scummvm
#         - wine
#         or an empty string if the type is not set and could not be guessed
application_type() {
	local application
	application="$1"

	local application_type
	application_type=$(context_value "${application}_TYPE")

	# If no type has been explicitely set, try to guess one
	## Try to detect ScummVM applications
	if [ -z "$application_type" ]; then
		local application_scummid
		application_scummid=$(application_scummvm_scummid "$application")
		if [ -n "$application_scummid" ]; then
			application_type='scummvm'
		fi
	fi
	## Try to detect the application type based of the binary MIME type
	if [ -z "$application_type" ]; then
		if [ -n "${PLAYIT_WORKDIR:-}" ]; then
			application_type=$(application_type_guess_from_file "$application")
		fi
	fi

	# Return early if no type has been found
	if [ -z "$application_type" ]; then
		return 0
	fi

	# Check that a supported type has been fetched
	case "$application_type" in
		( \
			'dosbox' | \
			'java' | \
			'mono' | \
			'native' | \
			'scummvm' | \
			'wine' \
		)
			## This is a supported type, no error to throw.
		;;
		(*)
			error_unknown_application_type "$application_type"
			return 1
		;;
	esac

	printf '%s' "$application_type"
}

# Try to find the application type from the MIME type of its binary file
# USAGE: application_type_guess_from_file $application
# RETURN: the guessed application type,
#         or an empty string if none could be guessed
application_type_guess_from_file() {
	local application
	application="$1"

	# Compute path to application binary
	local application_exe application_exe_path
	application_exe=$(application_exe "$application")
	## If no binary is found for the current package,
	## try to find one for any of the packages.
	if [ -z "$application_exe" ]; then
		local packages_list PKG
		packages_list=$(packages_get_list)
		for PKG in $packages_list; do
			application_exe=$(application_exe "$application")
			if [ -n "$application_exe" ]; then
				break
			fi
		done
	fi
	## Check that an application binary is set.
	if [ -z "$application_exe" ]; then
		error_application_exe_empty "$application" 'application_type_guess_from_file'
		return 1
	fi
	application_exe_path=$(application_exe_path "$application_exe")

	# Return early if no binary file can be found for the given application.
	if [ -z "$application_exe_path" ]; then
		return 0
	fi

	local file_type application_type
	file_type=$(file_type "$application_exe_path")
	case "$file_type" in
		( \
			'application/x-executable' | \
			'application/x-pie-executable' | \
			'application/x-sharedlib' \
		)
			application_type='native'
		;;
		( \
			'application/x-dosexec' | \
			'application/vnd.microsoft.portable-executable' \
		)
			local file_type_extended
			file_type_extended=$( \
				LANG=C file --brief --dereference "$application_exe_path" | \
				cut --delimiter=',' --fields=1 \
			)
			case "$file_type_extended" in
				('MS-DOS executable')
					application_type='dosbox'
				;;
				(*'Mono/.Net assembly')
					application_type='mono'
				;;
				( \
					'PE32 executable'* | \
					'PE32+ executable'* \
				)
					application_type='wine'
				;;
			esac
		;;
		('application/octet-stream')
			local file_type_extended
			file_type_extended=$(LANG=C file --brief --dereference "$application_exe_path")
			case "$file_type_extended" in
				('MS-DOS executable')
					application_type='dosbox'
				;;
			esac
		;;
	esac

	printf '%s' "$application_type"
}

# Print the type variant for the given application
# USAGE: application_type_variant $application
# RETURNS: the type variant, or an empty string
application_type_variant() {
	local application
	application="$1"

	local application_type_variant
	application_type_variant=$(context_value "${application}_TYPE_VARIANT")
	if [ -n "$application_type_variant" ]; then
		printf '%s' "$application_type_variant"
		return 0
	fi

	# If no variant is explicitly set, try to guess one.
	local unity3d_name
	unity3d_name=$(unity3d_name)
	if [ -n "$unity3d_name" ]; then
		printf 'unity3d'
		return 0
	fi
}
