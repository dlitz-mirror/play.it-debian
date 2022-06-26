# Keep compatibility with 2.10 and older

write_bin() {
	local application
	for application in "$@"; do
		launcher_write_script "$application"
	done
}

write_desktop() {
	local application
	for application in "$@"; do
		launcher_write_desktop "$application"
	done
}

write_desktop_winecfg() {
	launcher_write_desktop 'APP_WINECFG'
}

write_launcher() {
	launchers_write "$@"
}

