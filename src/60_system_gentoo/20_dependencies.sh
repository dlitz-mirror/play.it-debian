# Gentoo - Set list of generic dependencies
# USAGE: pkg_set_deps_gentoo $dep[…]
pkg_set_deps_gentoo() {
	# $pkg is inherited from the calling function.
	# It should be passed as a mandatory argument to this function instead.
	local package
	package="$pkg"

	local package_architecture architecture_suffix architecture_suffix_use
	package_architecture=$(package_get_architecture "$package")
	case "$package_architecture" in
		('32')
			architecture_suffix='[abi_x86_32]'
			architecture_suffix_use=',abi_x86_32'
		;;
		('64')
			architecture_suffix=''
			architecture_suffix_use=''
		;;
	esac
	for dep in "$@"; do
		case $dep in
			('alsa')
				pkg_dep="media-libs/alsa-lib$architecture_suffix media-plugins/alsa-plugins$architecture_suffix"
			;;
			('bzip2')
				pkg_dep="app-arch/bzip2$architecture_suffix"
			;;
			('dosbox')
				pkg_dep="games-emulation/dosbox"
			;;
			('freetype')
				pkg_dep="media-libs/freetype$architecture_suffix"
			;;
			('gcc32')
				pkg_dep='' #gcc (in @system) should be multilib unless it is a no-multilib profile, in which case the 32 bits libraries wouldn't work
			;;
			('gconf')
				pkg_dep="gnome-base/gconf$architecture_suffix"
			;;
			('glibc')
				pkg_dep="sys-libs/glibc"
				if [ "$(package_get_architecture "$package")" = '32' ]; then
					pkg_dep="$pkg_dep amd64? ( sys-libs/glibc[multilib] )"
				fi
			;;
			('glu')
				pkg_dep="virtual/glu$architecture_suffix"
			;;
			('glx')
				pkg_dep="virtual/opengl$architecture_suffix"
			;;
			('gtk2')
				pkg_dep="x11-libs/gtk+:2$architecture_suffix"
			;;
			('java')
				pkg_dep='virtual/jre'
			;;
			('json')
				pkg_dep="dev-libs/json-c$architecture_suffix"
			;;
			('libcurl')
				pkg_dep="net-misc/curl$architecture_suffix"
			;;
			('libcurl-gnutls')
				local architecture_string
				pkg_dep="net-libs/libcurl-debian$architecture_suffix"
				pkg_overlay='steam-overlay'
				architecture_string="$(package_get_architecture_string "$package")"
				dependencies_gentoo_link 'libcurl-gnutls.so.4' "/usr/$(dependency_gentoo_libdir "$architecture_string")/debiancompat" "$package"
			;;
			('libstdc++')
				pkg_dep='' #maybe this should be virtual/libstdc++, otherwise, it is included in gcc, which should be in @system
			;;
			('libudev1')
				pkg_dep="virtual/libudev$architecture_suffix"
			;;
			('libxrandr')
				pkg_dep="x11-libs/libXrandr$architecture_suffix"
			;;
			('mono')
				pkg_dep="dev-lang/mono$architecture_suffix"
			;;
			('nss')
				pkg_dep="dev-libs/nss$architecture_suffix"
			;;
			('openal')
				pkg_dep="media-libs/openal$architecture_suffix"
			;;
			('pulseaudio')
				pkg_dep='media-sound/pulseaudio'
			;;
			('renpy')
				pkg_dep='games-engines/renpy'
			;;
			('sdl1.2')
				pkg_dep="media-libs/libsdl$architecture_suffix"
			;;
			('sdl2')
				pkg_dep="media-libs/libsdl2$architecture_suffix"
			;;
			('sdl2_image')
				# Most games will require at least jpeg and png
				# Maybe we should add gif and tiff to that list?
				pkg_dep="media-libs/sdl2-image[jpeg,png$architecture_suffix_use]"
			;;
			('sdl2_mixer')
				#Most games will require at least one of flac, mp3, vorbis or wav USE flags, it should better to require them all instead of not requiring any and having non-fonctionnal sound in some games.
				pkg_dep="media-libs/sdl2-mixer[flac,mp3,vorbis,wav$architecture_suffix_use]"
			;;
			('theora')
				pkg_dep="media-libs/libtheora$architecture_suffix"
			;;
			('vorbis')
				pkg_dep="media-libs/libvorbis$architecture_suffix"
			;;
			('wine')
				case "$(package_get_architecture "$package")" in
					('32') pkg_set_deps_gentoo 'wine32' ;;
					('64') pkg_set_deps_gentoo 'wine64' ;;
				esac
			;;
			('wine32')
				pkg_dep='virtual/wine[abi_x86_32]'
			;;
			('wine64')
				pkg_dep='virtual/wine[abi_x86_64]'
			;;
			('wine-staging')
				case "$(package_get_architecture "$package")" in
					('32') pkg_set_deps_gentoo 'wine32-staging' ;;
					('64') pkg_set_deps_gentoo 'wine64-staging' ;;
				esac
			;;
			('wine32-staging')
				pkg_dep='virtual/wine[staging,abi_x86_32]'
			;;
			('wine64-staging')
				pkg_dep='virtual/wine[staging,abi_x86_64]'
			;;
			('winetricks')
				pkg_dep='app-emulation/winetricks
				|| (
					x11-terms/xterm
					gnome-extra/zenity
					kde-apps/kdialog
				)'
			;;
			('xcursor')
				pkg_dep="x11-libs/libXcursor$architecture_suffix"
			;;
			('xft')
				pkg_dep="x11-libs/libXft$architecture_suffix"
			;;
			('xgamma')
				pkg_dep='x11-apps/xgamma'
			;;
			('xrandr')
				pkg_dep='x11-apps/xrandr'
			;;
			( \
				'libasound.so.2' | \
				'libasound_module_'*'.so' | \
				'libc.so.6' | \
				'libgdk_pixbuf-2.0.so.0' | \
				'libgdk-x11-2.0.so.0' | \
				'libGL.so.1' | \
				'libglib-2.0.so.0' | \
				'libGLU.so.1' | \
				'libgobject-2.0.so.0' | \
				'libgtk-x11-2.0.so.0' | \
				'libmbedtls.so.12' | \
				'libpng16.so.16' | \
				'libpulse.so.0' | \
				'libpulse-simple.so.0' | \
				'libopenal.so.1' | \
				'libSDL-1.2.so.0' | \
				'libSDL2-2.0.so.0' | \
				'libstdc++.so.6' | \
				'libturbojpeg.so.0' | \
				'libuv.so.1' | \
				'libudev.so.1' | \
				'libvorbisfile.so.3' | \
				'libX11.so.6' | \
				'libz.so.1' \
			)
				case "$package_architecture" in
					('32')
						pkg_dep=$(dependency_package_providing_library_gentoo32 "$dep" "$package")
					;;
					(*)
						pkg_dep=$(dependency_package_providing_library_gentoo "$dep" "$package")
					;;
				esac
			;;
			(*)
				pkg_dep="games-playit/$(printf '%s' "$dep" | sed 's/-/_/g')"
				local tested_package packages_list
				packages_list=$(packages_get_list)
				for tested_package in $packages_list; do
					if [ "$tested_package" != "$package" ]; then
						if [ "$(package_get_provide "$tested_package")" = "$(printf '%s' "!!games-playit/${dep}" | sed 's/-/_/g')" ]; then
							pkg_dep="|| ( ${pkg_dep} )"
						fi
					fi
				done
			;;
		esac
		if [ -n "$pkg_dep" ]; then
			pkg_deps="$pkg_deps $pkg_dep"
		fi
		if [ -n "$pkg_overlay" ]; then
			dependency_gentoo_overlays_add "$pkg_overlay"
			pkg_overlay=''
		fi
	done
}

# Gentoo - Print the package name providing the given native library
# USAGE: dependency_package_providing_library_gentoo $library $package
dependency_package_providing_library_gentoo() {
	local library package package_name pkg_overlay
	library="$1"
	package="$2"
	case "$library" in
		('ld-linux.so.2')
			package_name='sys-libs/glibc'
		;;
		('ld-linux-x86-64.so.2')
			package_name='sys-libs/glibc'
		;;
		('libasound.so.2')
			package_name='media-libs/alsa-lib'
		;;
		('libasound_module_'*'.so')
			package_name='media-plugins/alsa-plugins'
		;;
		('libatk-1.0.so.0')
			package_name='dev-libs/atk'
		;;
		('libavcodec.so.58')
			package_name='media-video/ffmpeg'
		;;
		('libavformat.so.58')
			package_name='media-video/ffmpeg'
		;;
		('libavutil.so.56')
			package_name='media-video/ffmpeg'
		;;
		('libbz2.so.1.0')
			package_name='app-arch/bzip2'
		;;
		('libc.so.6')
			package_name='sys-libs/glibc'
		;;
		('libcairo.so.2')
			package_name='x11-libs/cairo'
		;;
		('libcom_err.so.2')
			package_name='sys-libs/e2fsprogs-libs'
		;;
		('libcrypto.so.1.1')
			package_name='dev-libs/openssl'
		;;
		('libcurl.so.4')
			package_name='net-misc/curl'
		;;
		('libcurl-gnutls.so.4')
			package_name='net-libs/libcurl-debian'
			pkg_overlay='steam-overlay'
			dependencies_gentoo_link 'libcurl-gnutls.so.4' "/usr/$(dependency_gentoo_libdir 'amd64')/debiancompat" "$package"
			;;
		('libdl.so.2')
			package_name='sys-libs/glibc'
		;;
		('libexpat.so.1')
			package_name='dev-libs/expat'
		;;
		('libfontconfig.so.1')
			package_name='media-libs/fontconfig'
		;;
		('libfreeimage.so.3')
			package_name='media-libs/freeimage'
		;;
		('libfreetype.so.6')
			package_name='media-libs/freetype'
		;;
		('libgcc_s.so.1')
			package_name='sys-devel/gcc'
		;;
		('libgcrypt.so.11')
			package_name='dev-libs/libgcrypt-compat'
		;;
		('libgdk_pixbuf-2.0.so.0')
			package_name='x11-libs/gdk-pixbuf:2'
		;;
		('libgdk-x11-2.0.so.0')
			package_name='x11-libs/gtk+:2'
		;;
		('libgio-2.0.so.0')
			package_name='dev-libs/glib:2'
		;;
		('libGL.so.1')
			package_name='virtual/opengl'
		;;
		('libGLEW.so.2.2')
			package_name='media-libs/glew'
		;;
		('libglfw.so.3')
			package_name='media-libs/glfw'
		;;
		('libglib-2.0.so.0')
			package_name='dev-libs/glib:2'
		;;
		('libGLU.so.1')
			package_name='virtual/glu'
		;;
		('libGLX.so.0')
			package_name='media-libs/libglvnd'
		;;
		('libgmodule-2.0.so.0')
			package_name='dev-libs/glib:2'
		;;
		('libgobject-2.0.so.0')
			package_name='dev-libs/glib:2'
		;;
		('libgpg-error.so.0')
			package_name='dev-libs/libgpg-error'
		;;
		('libgssapi_krb5.so.2')
			package_name='app-crypt/mit-krb5'
		;;
		('libgthread-2.0.so.0')
			package_name='dev-libs/glib:2'
		;;
		('libgtk-x11-2.0.so.0')
			package_name='x11-libs/gtk+:2'
		;;
		('libICE.so.6')
			package_name='x11-libs/libICE'
		;;
		('libidn2.so.0')
			package_name='net-dns/libidn2'
		;;
		('libk5crypto.so.3')
			package_name='app-crypt/mit-krb5'
		;;
		('libkrb5.so.3')
			package_name='app-crypt/mit-krb5'
		;;
		('libluajit-5.1.so.2')
			package_name='dev-lang/luajit'
		;;
		('libm.so.6')
			package_name='sys-libs/glibc'
		;;
		('libmbedtls.so.12')
			package_name='net-libs/mbedtls:0/12'
		;;
		('libminiupnpc.so.17')
			package_name='net-libs/miniupnpc'
		;;
		('libnghttp2.so.14')
			package_name='net-libs/nghttp2'
		;;
		('libnspr4.so')
			package_name='dev-libs/nspr'
		;;
		('libnss3.so')
			package_name='dev-libs/nss'
		;;
		('libogg.so.0')
			package_name='media-libs/libogg'
		;;
		('libopenal.so.1')
			package_name='media-libs/openal'
		;;
		('libOpenGL.so.0')
			package_name='media-libs/libglvnd'
		;;
		('libopenmpt.so.0')
			package_name='media-libs/libopenmpt'
		;;
		('libpango-1.0.so.0')
			package_name='x11-libs/pango'
		;;
		('libpangocairo-1.0.so.0')
			package_name='x11-libs/pango'
		;;
		('libpangoft2-1.0.so.0')
			package_name='x11-libs/pango'
		;;
		('libplc4.so')
			package_name='dev-libs/nspr'
		;;
		('libplds4.so')
			package_name='dev-libs/nspr'
		;;
		('libpng16.so.16')
			package_name='media-libs/libpng:0/16'
		;;
		('libpsl.so.5')
			package_name='net-libs/libpsl'
		;;
		('libpthread.so.0')
			package_name='sys-libs/glibc'
		;;
		('libpulse.so.0')
			package_name='media-sound/pulseaudio'
		;;
		('libpulse-simple.so.0')
			package_name='media-sound/pulseaudio'
		;;
		('libresolv.so.2')
			package_name='sys-libs/glibc'
		;;
		('librt.so.1')
			package_name='sys-libs/glibc'
		;;
		('librtmp.so.1')
			package_name='media-video/rtmpdump'
		;;
		('libSDL-1.2.so.0')
			package_name='media-libs/libsdl'
		;;
		('libSDL_mixer-1.2.so.0')
			package_name='media-libs/sdl-mixer'
		;;
		('libSDL_ttf-2.0.so.0')
			package_name='media-libs/sdl-ttf'
		;;
		('libSDL2-2.0.so.0')
			package_name='media-libs/libsdl2'
		;;
		('libSDL2_image-2.0.so.0')
			package_name='media-libs/sdl2-image'
		;;
		('libSDL2_mixer-2.0.so.0')
			package_name='media-libs/sdl2-mixer'
		;;
		('libSDL2_ttf-2.0.so.0')
			package_name='media-libs/sdl2-ttf'
		;;
		('libSM.so.6')
			package_name='x11-libs/libSM'
		;;
		('libsmime3.so')
			package_name='dev-libs/nss'
		;;
		('libsmpeg-0.4.so.0')
			package_name='media-libs/smpeg'
		;;
		('libsodium.so.23')
			package_name='dev-libs/libsodium'
		;;
		('libssh2.so.1')
			package_name='net-libs/libssh2'
		;;
		('libssl.so.1.1')
			package_name='dev-libs/openssl'
		;;
		('libssl3.so')
			package_name='dev-libs/nss'
		;;
		('libstdc++.so.5')
			package_name='sys-libs/libstdc++-v3'
		;;
		('libstdc++.so.6')
			package_name='virtual/libstdc++'
		;;
		('libtheoradec.so.1')
			package_name='media-libs/libtheora'
		;;
		('libthread_db.so.1')
			package_name='sys-libs/glibc'
		;;
		('libturbojpeg.so.0')
			package_name='media-libs/libjpeg-turbo'
		;;
		('libudev.so.1')
			package_name='virtual/libudev'
		;;
		('libuuid.so.1')
			package_name='sys-apps/util-linux'
		;;
		('libuv.so.1')
			package_name='dev-libs/libuv:0/1'
		;;
		('libvorbis.so.0')
			package_name='media-libs/libvorbis'
		;;
		('libvorbisfile.so.3')
			package_name='media-libs/libvorbis'
		;;
		('libvulkan.so.1')
			package_name='media-libs/vulkan-loader'
		;;
		('libX11.so.6')
			package_name='x11-libs/libX11'
		;;
		('libXcursor.so.1')
			package_name='x11-libs/libXcursor'
		;;
		('libXext.so.6')
			package_name='x11-libs/libXext'
		;;
		('libXft.so.2')
			package_name='x11-libs/libXft'
		;;
		('libXi.so.6')
			package_name='x11-libs/libXi'
		;;
		('libXinerama.so.1')
			package_name='x11-libs/libXinerama'
		;;
		('libXrandr.so.2')
			package_name='x11-libs/libXrandr'
		;;
		('libXrender.so.1')
			package_name='x11-libs/libXrender'
		;;
		('libXt.so.6')
			package_name='x11-libs/libXt'
		;;
		('libXtst.so.6')
			package_name='x11-libs/libXtst'
		;;
		('libXxf86vm.so.1')
			package_name='x11-libs/libXxf86vm'
		;;
		('libxmp.so.4')
			package_name='media-libs/libxmp'
		;;
		('libz.so.1')
			package_name='sys-libs/zlib:0/1'
		;;
	esac

	if [ -n "$package_name" ]; then
		printf '%s' "$package_name"
		if [ -n "$pkg_overlay" ]; then
			dependency_gentoo_overlays_add "$pkg_overlay"
		fi
		return 0
	fi

	dependencies_unknown_libraries_add "$library"
}

# Gentoo - Print the package name providing the given native library in a 32-bit build
# USAGE: dependency_package_providing_library_gentoo32 $library $package
dependency_package_providing_library_gentoo32() {
	local library package package_name pkg_overlay
	library="$1"
	package="$2"
	case "$library" in
		('ld-linux.so.2')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('ld-linux-x86-64.so.2')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('libasound.so.2')
			package_name='media-libs/alsa-lib[abi_x86_32]'
		;;
		('libasound_module_'*'.so')
			package_name='media-plugins/alsa-plugins[abi_x86_32]'
		;;
		('libatk-1.0.so.0')
			package_name='dev-libs/atk[abi_x86_32]'
		;;
		('libavcodec.so.58')
			package_name='media-video/ffmpeg[abi_x86_32]'
		;;
		('libavformat.so.58')
			package_name='media-video/ffmpeg[abi_x86_32]'
		;;
		('libavutil.so.56')
			package_name='media-video/ffmpeg[abi_x86_32]'
		;;
		('libbz2.so.1.0')
			package_name='app-arch/bzip2[abi_x86_32]'
		;;
		('libc.so.6')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('libcairo.so.2')
			package_name='x11-libs/cairo[abi_x86_32]'
		;;
		('libcom_err.so.2')
			package_name='sys-libs/e2fsprogs-libs[abi_x86_32]'
		;;
		('libcrypto.so.1.1')
			package_name='dev-libs/openssl[abi_x86_32]'
		;;
		('libcurl.so.4')
			package_name='net-misc/curl[abi_x86_32]'
		;;
		('libcurl-gnutls.so.4')
			package_name='net-libs/libcurl-debian[abi_x86_32]'
			pkg_overlay='steam-overlay'
			dependencies_gentoo_link 'libcurl-gnutls.so.4' "/usr/$(dependency_gentoo_libdir 'x86')/debiancompat" "$package"
			;;
		('libdl.so.2')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('libexpat.so.1')
			package_name='dev-libs/expat[abi_x86_32]'
		;;
		('libfontconfig.so.1')
			package_name='media-libs/fontconfig[abi_x86_32]'
		;;
		('libfreeimage.so.3')
			package_name='media-libs/freeimage[abi_x86_32]'
		;;
		('libfreetype.so.6')
			package_name='media-libs/freetype[abi_x86_32]'
		;;
		('libgcc_s.so.1')
			package_name='sys-devel/gcc[abi_x86_32]'
		;;
		('libgcrypt.so.11')
			package_name='dev-libs/libgcrypt-compat[abi_x86_32]'
		;;
		('libgdk_pixbuf-2.0.so.0')
			package_name='x11-libs/gdk-pixbuf:2[abi_x86_32]'
		;;
		('libgdk-x11-2.0.so.0')
			package_name='x11-libs/gtk+:2[abi_x86_32]'
		;;
		('libgio-2.0.so.0')
			package_name='dev-libs/glib:2[abi_x86_32]'
		;;
		('libGL.so.1')
			package_name='virtual/opengl[abi_x86_32]'
		;;
		('libGLEW.so.2.2')
			package_name='media-libs/glew[abi_x86_32]'
		;;
		('libglfw.so.3')
			package_name='media-libs/glfw[abi_x86_32]'
		;;
		('libglib-2.0.so.0')
			package_name='dev-libs/glib:2[abi_x86_32]'
		;;
		('libGLU.so.1')
			package_name='virtual/glu[abi_x86_32]'
		;;
		('libGLX.so.0')
			package_name='media-libs/libglvnd[abi_x86_32]'
		;;
		('libgmodule-2.0.so.0')
			package_name='dev-libs/glib:2[abi_x86_32]'
		;;
		('libgobject-2.0.so.0')
			package_name='dev-libs/glib:2[abi_x86_32]'
		;;
		('libgpg-error.so.0')
			package_name='dev-libs/libgpg-error[abi_x86_32]'
		;;
		('libgssapi_krb5.so.2')
			package_name='app-crypt/mit-krb5[abi_x86_32]'
		;;
		('libgthread-2.0.so.0')
			package_name='dev-libs/glib:2[abi_x86_32]'
		;;
		('libgtk-x11-2.0.so.0')
			package_name='x11-libs/gtk+:2[abi_x86_32]'
		;;
		('libICE.so.6')
			package_name='x11-libs/libICE[abi_x86_32]'
		;;
		('libidn2.so.0')
			package_name='net-dns/libidn2[abi_x86_32]'
		;;
		('libk5crypto.so.3')
			package_name='app-crypt/mit-krb5[abi_x86_32]'
		;;
		('libkrb5.so.3')
			package_name='app-crypt/mit-krb5[abi_x86_32]'
		;;
		('libluajit-5.1.so.2')
			package_name='dev-lang/luajit[abi_x86_32]'
		;;
		('libm.so.6')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('libmbedtls.so.12')
			package_name='net-libs/mbedtls:0/12[abi_x86_32]'
		;;
		('libminiupnpc.so.17')
			package_name='net-libs/miniupnpc[abi_x86_32]'
		;;
		('libnghttp2.so.14')
			package_name='net-libs/nghttp2[abi_x86_32]'
		;;
		('libnspr4.so')
			package_name='dev-libs/nspr[abi_x86_32]'
		;;
		('libnss3.so')
			package_name='dev-libs/nss[abi_x86_32]'
		;;
		('libogg.so.0')
			package_name='media-libs/libogg[abi_x86_32]'
		;;
		('libopenal.so.1')
			package_name='media-libs/openal[abi_x86_32]'
		;;
		('libOpenGL.so.0')
			package_name='media-libs/libglvnd[abi_x86_32]'
		;;
		('libopenmpt.so.0')
			package_name='media-libs/libopenmpt[abi_x86_32]'
		;;
		('libpango-1.0.so.0')
			package_name='x11-libs/pango[abi_x86_32]'
		;;
		('libpangocairo-1.0.so.0')
			package_name='x11-libs/pango[abi_x86_32]'
		;;
		('libpangoft2-1.0.so.0')
			package_name='x11-libs/pango[abi_x86_32]'
		;;
		('libplc4.so')
			package_name='dev-libs/nspr[abi_x86_32]'
		;;
		('libplds4.so')
			package_name='dev-libs/nspr[abi_x86_32]'
		;;
		('libpng16.so.16')
			package_name='media-libs/libpng:0/16[abi_x86_32]'
		;;
		('libpsl.so.5')
			package_name='net-libs/libpsl[abi_x86_32]'
		;;
		('libpthread.so.0')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('libpulse.so.0')
			package_name='media-sound/pulseaudio[abi_x86_32]'
		;;
		('libpulse-simple.so.0')
			package_name='media-sound/pulseaudio[abi_x86_32]'
		;;
		('libresolv.so.2')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('librt.so.1')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('librtmp.so.1')
			package_name='media-video/rtmpdump[abi_x86_32]'
		;;
		('libSDL-1.2.so.0')
			package_name='media-libs/libsdl[abi_x86_32]'
		;;
		('libSDL_mixer-1.2.so.0')
			package_name='media-libs/sdl-mixer[abi_x86_32]'
		;;
		('libSDL_ttf-2.0.so.0')
			package_name='media-libs/sdl-ttf[abi_x86_32]'
		;;
		('libSDL2-2.0.so.0')
			package_name='media-libs/libsdl2[abi_x86_32]'
		;;
		('libSDL2_image-2.0.so.0')
			package_name='media-libs/sdl2-image[abi_x86_32]'
		;;
		('libSDL2_mixer-2.0.so.0')
			package_name='media-libs/sdl2-mixer[abi_x86_32]'
		;;
		('libSDL2_ttf-2.0.so.0')
			package_name='media-libs/sdl2-ttf[abi_x86_32]'
		;;
		('libSM.so.6')
			package_name='x11-libs/libSM[abi_x86_32]'
		;;
		('libsmime3.so')
			package_name='dev-libs/nss[abi_x86_32]'
		;;
		('libsmpeg-0.4.so.0')
			package_name='media-libs/smpeg[abi_x86_32]'
		;;
		('libsodium.so.23')
			package_name='dev-libs/libsodium[abi_x86_32]'
		;;
		('libssh2.so.1')
			package_name='net-libs/libssh2[abi_x86_32]'
		;;
		('libssl.so.1.1')
			package_name='dev-libs/openssl[abi_x86_32]'
		;;
		('libssl3.so')
			package_name='dev-libs/nss[abi_x86_32]'
		;;
		('libstdc++.so.5')
			package_name='sys-libs/libstdc++-v3[abi_x86_32]'
		;;
		('libstdc++.so.6')
			package_name='virtual/libstdc++[abi_x86_32]'
		;;
		('libtheoradec.so.1')
			package_name='media-libs/libtheora[abi_x86_32]'
		;;
		('libthread_db.so.1')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('libturbojpeg.so.0')
			package_name='media-libs/libjpeg-turbo[abi_x86_32]'
		;;
		('libudev.so.1')
			package_name='virtual/libudev[abi_x86_32]'
		;;
		('libuuid.so.1')
			package_name='sys-apps/util-linux[abi_x86_32]'
		;;
		('libuv.so.1')
			package_name='dev-libs/libuv:0/1[abi_x86_32]'
		;;
		('libvorbis.so.0')
			package_name='media-libs/libvorbis[abi_x86_32]'
		;;
		('libvorbisfile.so.3')
			package_name='media-libs/libvorbis[abi_x86_32]'
		;;
		('libvulkan.so.1')
			package_name='media-libs/vulkan-loader[abi_x86_32]'
		;;
		('libX11.so.6')
			package_name='x11-libs/libX11[abi_x86_32]'
		;;
		('libXcursor.so.1')
			package_name='x11-libs/libXcursor[abi_x86_32]'
		;;
		('libXext.so.6')
			package_name='x11-libs/libXext[abi_x86_32]'
		;;
		('libXft.so.2')
			package_name='x11-libs/libXft[abi_x86_32]'
		;;
		('libXi.so.6')
			package_name='x11-libs/libXi[abi_x86_32]'
		;;
		('libXinerama.so.1')
			package_name='x11-libs/libXinerama[abi_x86_32]'
		;;
		('libXrandr.so.2')
			package_name='x11-libs/libXrandr[abi_x86_32]'
		;;
		('libXrender.so.1')
			package_name='x11-libs/libXrender[abi_x86_32]'
		;;
		('libXt.so.6')
			package_name='x11-libs/libXt[abi_x86_32]'
		;;
		('libXtst.so.6')
			package_name='x11-libs/libXtst[abi_x86_32]'
		;;
		('libXxf86vm.so.1')
			package_name='x11-libs/libXxf86vm[abi_x86_32]'
		;;
		('libxmp.so.4')
			package_name='media-libs/libxmp[abi_x86_32]'
		;;
		('libz.so.1')
			package_name='sys-libs/zlib:0/1[abi_x86_32]'
		;;
	esac

	if [ -n "$package_name" ]; then
		printf '%s' "$package_name"
		if [ -n "$pkg_overlay" ]; then
			dependency_gentoo_overlays_add "$pkg_overlay"
		fi
		return 0
	fi

	dependencies_unknown_libraries_add "$library"
}

# Gentoo - List all dependencies for the given package
# USAGE: dependencies_gentoo_full_list $package
dependencies_gentoo_full_list() {
	local package
	package="$1"

	{
		# Include generic dependencies
		local dependency_generic
		while read -r dependency_generic; do
			# pkg_set_deps_gentoo sets a variable $pkg_deps instead of printing a value,
			# we prevent it from leaking using unset.
			unset pkg_deps
			pkg_set_deps_gentoo $dependency_generic
			printf '%s\n' "$pkg_deps"
			unset pkg_deps
		done <<- EOL
		$(dependencies_list_generic "$package")
		EOL

		# Include Gentoo-specific dependencies
		local dependencies_specific
		dependencies_specific=$(get_context_specific_value 'archive' "${package}_DEPS_GENTOO")
		if [ -n "$dependencies_specific" ]; then
			printf '%s\n' "$dependencies_specific" | sed 's/ /\n/g'
		fi

		# Include dependencies on native libraries
		dependencies_list_native_libraries_packages "$package"

		local package_provide
		package_provide=$(package_get_provide "$package")
		if [ -n "$package_provide" ]; then
			printf '%s\n' "$package_provide"
		fi
	} | sort --unique
}

# Gentoo - Print the path to a temporary file used for additional overlays listing
# USAGE: dependency_gentoo_overlays_file
dependency_gentoo_overlays_file() {
	printf '%s/overlays' "$PLAYIT_WORKDIR"
}

# Gentoo - Add an overlay to the list of additional overlays
# USAGE: dependency_gentoo_overlays_add $overlay
dependency_gentoo_overlays_add() {
	local overlay overlays_file
	overlay="$1"
	overlays_file="$(dependency_gentoo_overlays_file)"

	# Do nothing if this overlay is already included in the list
	if test -e "$overlays_file" \
		&& grep --quiet --fixed-strings --word-regexp "$overlay" < "$overlays_file"
	then
		return 0
	fi

	printf '%s\n' "$overlay" >> "$overlays_file"
}

# Gentoo - Print gentoo libdir name
# USAGE: dependency_gentoo_libdir $arch_string
# Note: This prints the name (ie. “lib”) not the path (ie. “/usr/lib”)
dependency_gentoo_libdir() {
	local arch_string="$1"
	if command -v portageq >/dev/null 2>&1; then
		print '%s' "$(portageq envvar "LIBDIR_${arch_string}")"
	else
		case "$arch_string" in
			('amd64')
				printf '%s' 'lib64'
				;;
			('x86')
				printf '%s' 'lib'
				;;
			('x32')
				printf '%s' 'libx32'
				;;
			(*)
				error_unknown_gentoo_architecture_string "$arch_string" 'dependency_gentoo_libdir'
				return 1
				;;
		esac
	fi
	return 0
}

# Gentoo - Link library installed in non-standard libdir to the game’s libdir
# USAGE: dependencies_gentoo_link $libname $libdir $package
# Note: $libdir is the library’s directory, not the game’s one!
dependencies_gentoo_link() {
	local libname libdir package game_libdir
	libname="$1"
	libdir="$2"
	package="$3"
	game_libdir="$(path_libraries)"

	local package_path library_destination
	package_path=$(package_get_path "$package")
	library_destination="${package_path}${game_libdir}"

	mkdir --parents "$library_destination"
	ln -sft "$library_destination" "${libdir}/${libname}"
}
