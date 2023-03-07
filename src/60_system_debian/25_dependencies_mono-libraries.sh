# Debian - Print the package names providing the given Mono libraries
# WARNING - Unknown Mono libraries are silently omitted.
# USAGE: debian_dependencies_providing_mono_libraries $library[…]
# RETURN: a list of Debian package names,
#         one per line
debian_dependencies_providing_mono_libraries() {
	local library packages_list package
	packages_list=''
	for library in "$@"; do
		package=$(debian_dependency_providing_mono_library "$library")
		packages_list="$packages_list
		$package"
	done

	printf '%s' "$packages_list" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}

# Debian - Print the package name providing the given Mono library
# WARNING - Unknown Mono libraries are silently omitted.
# USAGE: debian_dependency_providing_mono_library $library
# RETURN: a single Debian package name,
#         followed by a line break
debian_dependency_providing_mono_library() {
	local library
	library="$1"

	local package_name
	case "$library" in
		('mscorlib.dll')
			package_name='libmono-corlib4.5-cil'
		;;
		('I18N.dll')
			package_name='libmono-i18n4.0-cil'
		;;
		('I18N.West.dll')
			package_name='libmono-i18n-west4.0-cil'
		;;
		('Microsoft.CSharp.dll')
			package_name='libmono-microsoft-csharp4.0-cil'
		;;
		('Mono.CSharp.dll')
			package_name='libmono-csharp4.0c-cil'
		;;
		('Mono.Posix.dll')
			package_name='libmono-posix4.0-cil'
		;;
		('Mono.Security.dll')
			package_name='libmono-security4.0-cil'
		;;
		('OpenTK.dll')
			package_name='libopentk1.1-cil'
		;;
		('OpenTK.Compatibility.dll')
			package_name='libopentk1.1-cil'
		;;
		('OpenTK.GLControl.dll')
			package_name='libopentk1.1-cil'
		;;
		('System.dll')
			package_name='libmono-system4.0-cil'
		;;
		('System.ComponentModel.DataAnnotations.dll')
			package_name='libmono-system-componentmodel-dataannotations4.0-cil'
		;;
		('System.Configuration.dll')
			package_name='libmono-system-configuration4.0-cil'
		;;
		('System.Core.dll')
			package_name='libmono-system-core4.0-cil'
		;;
		('System.Data.dll')
			package_name='libmono-system-data4.0-cil'
		;;
		('System.Design.dll')
			package_name='libmono-system-design4.0-cil'
		;;
		('System.Drawing.dll')
			package_name='libmono-system-drawing4.0-cil'
		;;
		('System.IO.Compression.dll')
			package_name='libmono-system-io-compression4.0-cil'
		;;
		('System.IO.Compression.FileSystem.dll')
			package_name='libmono-system-io-compression-filesystem4.0-cil'
		;;
		('System.Management.dll')
			package_name='libmono-system-management4.0-cil'
		;;
		('System.Net.dll')
			package_name='libmono-system-net4.0-cil'
		;;
		('System.Net.Http.dll')
			package_name='libmono-system-net-http4.0-cil'
		;;
		('System.Numerics.dll')
			package_name='libmono-system-numerics4.0-cil'
		;;
		('System.Runtime.Serialization.dll')
			package_name='libmono-system-runtime-serialization4.0-cil'
		;;
		('System.Security.dll')
			package_name='libmono-system-security4.0-cil'
		;;
		('System.Transactions.dll')
			package_name='libmono-system-transactions4.0-cil'
		;;
		('System.Web.dll')
			package_name='libmono-system-web4.0-cil'
		;;
		('System.Web.Extensions.dll')
			package_name='libmono-system-web-extensions4.0-cil'
		;;
		('System.Web.Http.dll')
			package_name='libmono-system-web-http4.0-cil'
		;;
		('System.Web.Services.dll')
			package_name='libmono-system-web-services4.0-cil'
		;;
		('System.Windows.Forms.dll')
			package_name='libmono-system-windows-forms4.0-cil'
		;;
		('System.Xml.dll')
			package_name='libmono-system-xml4.0-cil'
		;;
		('System.Xml.Linq.dll')
			package_name='libmono-system-xml-linq4.0-cil'
		;;
		('WindowsBase.dll')
			package_name='libmono-windowsbase4.0-cil'
		;;
	esac

	if [ -n "$package_name" ]; then
		printf '%s' "$package_name"
		return 0
	fi

	dependencies_unknown_mono_libraries_add "$library"
}
