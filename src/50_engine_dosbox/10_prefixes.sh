# print function used to convert file names to upper case
# USAGE: dosbox_prefix_function_toupper
dosbox_prefix_function_toupper() {
	{
		cat <<- 'EOF'
		# convert the name of specified user files and directories to upper case
		# note that only the last component of each matching path is converted
		# USAGE: userdir_toupper_files $userdir $list
		userdir_toupper_files() {
		    local userdir
		    local list
		    userdir="$1"
		    list="$2"
		    (
		        cd "$userdir"
		        for file in $list; do
		            [ -e "$file" ] || continue
		            newfile=$(dirname "$file")/$(basename "$file" | tr '[:lower:]' '[:upper:]')
		            if [ ! -e "$newfile" ]; then
		                mv "$file" "$newfile"
		            else
		                display_warning \
		                    "en:Cannot overwrite '$userdir/${newfile#./}' with '$userdir/$file'" \
		                    "fr:Impossible d'écraser '$userdir/${newfile#./}' par '$userdir/$file'"
		            fi
		        done
		    )
		}

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'
}
