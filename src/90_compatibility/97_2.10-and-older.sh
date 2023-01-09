# Keep compatibility with 2.10 and older

write_launcher() {
	if version_is_at_least '2.11' "$target_version"; then
		warning_deprecated_function 'write_launcher' 'launchers_write'
	fi

	launchers_write "$@"
}

