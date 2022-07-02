# print functions used to display localized messages
# USAGE: launcher_prefix_functions_localized_messages
launcher_prefix_functions_localized_messages() {
	cat <<- 'EOF'
	# select strings matching the current locale
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: localize $string[…]
	localize() {
	    local lang
	    local string
	    local match
	    for lang in "${LANG%%_*}" 'en'; do
	        for string in "$@"; do
	            if [ "${string%%:*}" = "$lang" ]; then
	                echo "${string#*:}"
	                match=1
	            fi
	        done
	        if [ "$match" ]; then
	            break
	        fi
	    done
	}

	# print a localized message on standard error output
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: display_message $string[…]
	display_message() {
	    local string
	    localize "$@" | while read -r string; do
	        printf "$string\n"
	    done 1>&2
	}

	# print a localized error message on standard error output
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: display_error $string[…]
	display_error() {
	    display_message \
	        'en:\033[1;31mError:\033[0m' \
	        'fr:\033[1;31mErreur :\033[0m'
	    display_message "$@"
	}

	# print a localized warning message on standard error output
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: display_warning $string[…]
	display_warning() {
	    display_message \
	        'en:\033[1;33mWarning:\033[0m' \
	        'fr:\033[1;33mAvertissement :\033[0m'
	    display_message "$@"
	}

	# return the localized name of a given file type ('file' or 'directory')
	# USAGE: get_type_name $type
	get_type_name() {
	    local type
	    type="$1"
	    case "$type" in
	        ('file')
	            localize 'en:file' 'fr:le fichier'
	        ;;
	        ('directory')
	            localize 'en:directory' 'fr:le répertoire'
	        ;;
	        (*)
	            display_error \
	                "en:Invalid file type in launcher script: '$type'" \
	                "fr:Type de fichier invalide dans le script : '$type'"
	            exit 1
	        ;;
	    esac
	}
	EOF
}

# print function populating prefix symbolic links to all game file
# USAGE: launcher_prefix_function_init_game_files
launcher_prefix_function_init_game_files() {
	cat <<- 'EOF'
	# populate prefix with symbolic links to all game file
	# USAGE: prefix_init_game_files
	prefix_init_game_files() {
	    # remove symlinks to game directories
	    (
	        cd "$PATH_GAME"
	        find . -type d | while read -r dir; do
	            if [ -h "$PATH_PREFIX/$dir" ]; then
	                rm "$PATH_PREFIX/$dir"
	            fi
	        done
	    )
	    # populate prefix with symlinks to all game file
	    cp --recursive --remove-destination --symbolic-link --no-target-directory "$PATH_GAME" "$PATH_PREFIX"
	    # remove dangling links and non-game empty directories
	    (
	        cd "$PATH_PREFIX"
	        find . -type l | while read -r link; do
	            if [ ! -e "$link" ]; then
	                rm "$link"
	            fi
	        done
	        find . -depth -type d | while read -r dir; do
	            if [ ! -e "$PATH_GAME/$dir" ]; then
	                rmdir --ignore-fail-on-non-empty "$dir"
	            fi
	        done
	    )
	}
	EOF
}

# print function creating links from the prefix to persistent paths
# USAGE: launcher_prefix_function_symlink_to_userdir
launcher_prefix_function_symlink_to_userdir() {
	cat <<- 'EOF'
	# create symbolic link $PATH_PREFIX/$target -> $userdir/$target,
	# overwriting $PATH_PREFIX/$target if it exists
	# USAGE: prefix_symlink_to_userdir $userdir $target
	prefix_symlink_to_userdir() {
	    local userdir target target_prefix target_real
	    userdir="$1"
	    target="$2"
	    if [ -e "${PATH_PREFIX}/${target}" ]; then
	        target_prefix=$(readlink --canonicalize-existing "${PATH_PREFIX}/${target}")
	    else
	        unset target_prefix
	    fi
	    target_real=$(readlink --canonicalize-existing "${userdir}/${target}")
	    if [ "$target_real" != "$target_prefix" ]; then
	        if [ "$target_prefix" ]; then
	            rm --force --recursive "${PATH_PREFIX:?}/${target}"
	        fi
	        local target_parent
	        target_parent=$(dirname "$target")
	        mkdir --parents "${PATH_PREFIX}/${target_parent}"
	        ln --symbolic "$target_real" "${PATH_PREFIX}/${target}"
	    fi
	}
	EOF
}

# print function moving files/directories from the prefix to persistent paths
# USAGE: launcher_prefix_function_move_to_userdir_and_symlink
launcher_prefix_function_move_to_userdir_and_symlink() {
	cat <<- 'EOF'
	# move $PATH_PREFIX/$target to $userdir/$target (overwriting it if it exists),
	# and create symbolic link $PATH_PREFIX/$target -> $userdir/$target
	# USAGE: prefix_move_to_userdir_and_symlink $userdir $target
	prefix_move_to_userdir_and_symlink() {
	    local userdir target
	    userdir="$1"
	    target="$2"
	    if [ -e "${userdir}/${target}" ]; then
	        rm --force --recursive "${userdir}/${target}"
	    fi
	    local target_parent
	    target_parent=$(dirname "$target")
	    mkdir --parents "${userdir}/${target_parent}"
	    cp --recursive --dereference --no-target-directory "${PATH_PREFIX}/${target}" "${userdir}/${target}"
	    rm --force --recursive "${PATH_PREFIX:?}/${target}"
	    ln --symbolic "${userdir}/${target}" "${PATH_PREFIX}/${target}"
	}
	EOF
}

# print function initializing prefix with user files or directories
# USAGE: launcher_prefix_function_init_user_files
launcher_prefix_function_init_user_files() {
	cat <<- 'EOF'
	# initialize prefix with user files or directories
	# USAGE: prefix_init_user_files file|directory $userdir $list
	prefix_init_user_files() {
	    local type userdir list type_name
	    type="$1"
	    userdir="$2"
	    list="$3"
	    type_name=$(get_type_name "$type")
	    # populate prefix with symlinks to specified files or directories
	    (
	        cd "$userdir"
	        if [ "$type" = 'file' ]; then
	            # symlink to all files, even those not specified in $list
	            find -L . -type f
	        else
	            for target in $list; do echo "$target"; done
	        fi | while read -r target; do
	            case "$type" in
	                ('file')
	                    [ -f "$target" ] || continue
	                ;;
	                ('directory')
	                    [ -d "$target" ] || continue
	                ;;
	            esac
	            prefix_symlink_to_userdir "$userdir" "$target"
	        done
	    )
	    # move specified files or directories, if any, from prefix back to user directory
	    (
	        cd "$PATH_PREFIX"
	        for target in $list; do
	            case "$type" in
	                ('file')
	                    [ -f "$target" ] || continue
	                ;;
	                ('directory')
	                    # User directories should always be available in the game prefix from the first launch,
	                    # because some games will fail trying to write in them instead of creating them when needed.
	                    mkdir --parents "$target"
	                ;;
	            esac
	            if [ ! -e "$userdir/$target" ]; then
	                prefix_move_to_userdir_and_symlink "$userdir" "$target"
	            else
	                case "$type" in
	                    ('file')
	                        if [ ! -f "$userdir/$target" ]; then
	                            display_warning \
	                                "en:Cannot overwrite '$userdir/$target' with $type_name '$PATH_PREFIX/$target'" \
	                                "fr:Impossible d'écraser '$userdir/$target' par $type_name '$PATH_PREFIX/$target'"
	                        fi
	                    ;;
	                    ('directory')
	                        if [ ! -d "$userdir/$target" ]; then
	                            display_warning \
	                                "en:Cannot overwrite '$userdir/$target' with $type_name '$PATH_PREFIX/$target'" \
	                                "fr:Impossible d'écraser '$userdir/$target' par $type_name '$PATH_PREFIX/$target'"
	                        fi
	                    ;;
	                esac
	            fi
	        done
	    )
	}
	EOF
}

# print function synchronizing user files or directories with prefix
# USAGE: launcher_prefix_function_sync_user_files
launcher_prefix_function_sync_user_files() {
	cat <<- 'EOF'
	# synchronize user files or directories with prefix
	# USAGE: prefix_sync_user_files $type $userdir $list
	prefix_sync_user_files() {
	    local type userdir list type_name
	    type="$1"
	    userdir="$2"
	    list="$3"
	    type_name=$(get_type_name "$type")
	    # move specified files or directories, if any, from prefix back to user directory
	    (
	        cd "$PATH_PREFIX"
	        for target in $list; do
	            case "$type" in
	                ('file')
	                    [ -f "$target" ] || continue
	                ;;
	                ('directory')
	                    [ -d "$target" ] || continue
	                ;;
	            esac
	            if [ ! -h "$target" ]; then
	                case "$type" in
	                    ('file')
	                        if [ ! -e "$userdir/$target" ] || [ -f "$userdir/$target" ]; then
	                            prefix_move_to_userdir_and_symlink "$userdir" "$target"
	                        else
	                            display_warning \
	                                "en:Cannot overwrite '$userdir/$target' with $type_name '$PATH_PREFIX/$target'" \
	                                "fr:Impossible d'écraser '$userdir/$target' par $type_name '$PATH_PREFIX/$target'"
	                        fi
	                    ;;
	                    ('directory')
	                        if [ ! -e "$userdir/$target" ] || [ -d "$userdir/$target" ]; then
	                            prefix_move_to_userdir_and_symlink "$userdir" "$target"
	                        else
	                            display_warning \
	                                "en:Cannot overwrite '$userdir/$target' with $type_name '$PATH_PREFIX/$target'" \
	                                "fr:Impossible d'écraser '$userdir/$target' par $type_name '$PATH_PREFIX/$target'"
	                        fi
	                    ;;
	                esac
	            fi
	        done
	    )
	    # remove user files or directories which are not in the prefix anymore, if any
	    (
	        cd "$userdir"
	        for target in $list; do
	            case "$type" in
	                ('file')
	                    [ -f "$target" ] || continue
	                ;;
	                ('directory')
	                    [ -d "$target" ] || continue
	                ;;
	            esac
	            if [ ! -e "$PATH_PREFIX/$target" ]; then
	                rm --force --recursive "$target"
	            fi
	        done
	    )
	}
	EOF
}

# print function creating and initializing the user prefix
# USAGE: launcher_prefix_function_build
launcher_prefix_function_build() {
	cat <<- 'EOF'
	# create and initialize user prefix
	# USAGE: prefix_build
	prefix_build() {
	    local reply
	    # clean up the prefix if a lock file is still present from a previous run
	    if [ -e "$PREFIX_LOCK" ]; then
	        display_warning \
	            "en:The game prefix ('$PATH_PREFIX') was not properly cleaned up (possibly from a previous game crash)." \
	            "fr:Le répertoire de jeu ('$PATH_PREFIX') n'a pas été nettoyé correctement (possiblement à cause d'un précédent plantage du jeu)."
	        while true; do
	            display_message \
	                "en:Clean up the game prefix? [(Y)es/(n)o/(q)uit]" \
	                "fr:Nettoyer le répertoire de jeu ? [(O)ui/(n)on/(q)uitter]"
	            read reply || :
	            reply="$(echo "$reply" | tr '[:upper:]' '[:lower:]')"
	            if [ -z "$reply" ] || [ "$reply" = "$(localize 'en:y' 'fr:o')" ]; then
	                prefix_cleanup
	                break
	            elif [ "$reply" = "$(localize 'en:n' 'fr:n')" ]; then
	                break
	            elif [ "$reply" = "$(localize 'en:q' 'fr:q')" ]; then
	                exit 1
	            fi
	            display_warning \
	                "en:Invalid answer: '$reply'." \
	                "fr:Réponse invalide : '$reply'."
	        done
	    fi
	    prefix_init_game_files
	    prefix_init_user_files 'directory' "$USER_PERSISTENT_PATH" "$USER_PERSISTENT_DIRECTORIES"
	    prefix_init_user_files 'file' "$USER_PERSISTENT_PATH" "$USER_PERSISTENT_FILES"
	    touch "$PREFIX_LOCK"
	}
	EOF
}

# print function cleaning up and synchronizing back user prefix
# USAGE: launcher_prefix_function_cleanup
launcher_prefix_function_cleanup() {
	cat <<- 'EOF'
	# clean up and synchronize back user prefix
	# USAGE: prefix_cleanup
	prefix_cleanup() {
	    prefix_sync_user_files 'directory' "$USER_PERSISTENT_PATH" "$USER_PERSISTENT_DIRECTORIES"
	    prefix_sync_user_files 'file' "$USER_PERSISTENT_PATH" "$USER_PERSISTENT_FILES"
	    rm --force "$PREFIX_LOCK"
	}
	EOF
}

# write launcher script prefix functions
# USAGE: launcher_write_script_prefix_functions $file
# CALLED BY: launcher_write_script
launcher_write_script_prefix_functions() {
	local file
	file="$1"
	{
		cat <<- 'EOF'

		# Set localization and error reporting functions

		EOF
		launcher_prefix_functions_localized_messages
		cat <<- 'EOF'

		# Set userdir- and prefix-related functions

		EOF
		launcher_prefix_function_init_game_files
		launcher_prefix_function_symlink_to_userdir
		launcher_prefix_function_move_to_userdir_and_symlink
		launcher_prefix_function_init_user_files
		launcher_prefix_function_sync_user_files
		launcher_prefix_function_build
		launcher_prefix_function_cleanup
	} >> "$file"
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# write launcher script prefix prepare hook
# USAGE: launcher_write_script_prefix_prepare $file
# CALLED BY: launcher_write_script_prefix_build launcher_write_script_wine_prefix_build
launcher_write_script_prefix_prepare() {
	local file
	file="$1"

	if [ "$PREFIX_PREPARE" ]; then
		cat >> "$file" <<- EOF
		$PREFIX_PREPARE

		EOF
	fi

	return 0
}

# write launcher script prefix initialization
# USAGE: launcher_write_script_prefix_build $file
# CALLED BY: launcher_write_build
launcher_write_script_prefix_build() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Build user prefix

	PATH_PREFIX="${XDG_DATA_HOME:=$HOME/.local/share}/play.it/prefixes/${PREFIX_ID:=$GAME_ID}"
	PREFIX_LOCK="$PATH_PREFIX/.$GAME_ID.lock"
	mkdir --parents \
	    "$PATH_PREFIX" \
	    "$USER_PERSISTENT_PATH"
	EOF

	launcher_write_script_prefix_prepare "$file"

	cat >> "$file" <<- 'EOF'
	prefix_build

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# write launcher script prefix cleanup
# USAGE: launcher_write_script_prefix_cleanup $file
# CALLED BY: launcher_write_build
launcher_write_script_prefix_cleanup() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Clean up user prefix

	prefix_cleanup

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}
