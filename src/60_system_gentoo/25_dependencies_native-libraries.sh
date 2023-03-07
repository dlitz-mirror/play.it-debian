# Gentoo - Print the package names providing the given native libraries
# USAGE: gentoo_dependencies_providing_native_libraries $library[…]
# RETURN: a list of Gentoo package names,
#         one per line
gentoo_dependencies_providing_native_libraries() {
	local library packages_list package
	packages_list=''
	for library in "$@"; do
		package=$(dependency_package_providing_library_gentoo "$library")
		packages_list="$packages_list
		$package"
	done

	printf '%s' "$packages_list" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}

# Gentoo - Print the package names providing the given native libraries in a 32-bit build
# USAGE: gentoo_dependencies_providing_native_libraries_32bit $library[…]
# RETURN: a list of Gentoo package names,
#         one per line
gentoo_dependencies_providing_native_libraries_32bit() {
	local library packages_list package
	packages_list=''
	for library in "$@"; do
		package=$(dependency_package_providing_library_gentoo32 "$library")
		packages_list="$packages_list
		$package"
	done

	printf '%s' "$packages_list" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
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
		('liballeg.so.4.4')
			package_name='media-libs/allegro'
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
		('libaudio.so.2')
			package_name='media-libs/nas'
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
		('libbz2.so.1.0'|'libbz2.so.1')
			package_name='app-arch/bzip2'
		;;
		('libc.so.6')
			package_name='sys-libs/glibc'
		;;
		('libcairo.so.2')
			package_name='x11-libs/cairo'
		;;
		('liblcms2.so.2')
			package_name='media-libs/lcms'
		;;
		('libcom_err.so.2')
			package_name='sys-libs/e2fsprogs-libs'
		;;
		('libcrypt.so.1')
			package_name='sys-libs/libxcrypt'
		;;
		('libcrypto.so.1.1')
			package_name='dev-libs/openssl'
		;;
		('libcups.so.2')
			package_name='net-print/cups'
		;;
		('libcurl.so.4')
			package_name='net-misc/curl'
		;;
		('libcurl-gnutls.so.4')
			package_name='net-libs/libcurl-debian'
			pkg_overlay='steam-overlay'
			dependencies_gentoo_link 'libcurl-gnutls.so.4' "/usr/$(dependency_gentoo_libdir 'amd64')/debiancompat" "$package"
			;;
		('libdbus-1.so.3')
			package_name='sys-apps/dbus'
		;;
		('libdl.so.2')
			package_name='sys-libs/glibc'
		;;
		('libexpat.so.1')
			package_name='dev-libs/expat'
		;;
		('libFAudio.so.0')
			package_name='app-emulation/faudio'
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
		('libgconf-2.so.4')
			package_name='gnome-base/gconf'
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
		('libgomp.so.1')
			package_name='sys-devel/gcc'
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
		('libIL.so.1')
			package_name='media-libs/devil'
		;;
		('libjpeg.so.62')
			package_name='media-libs/libjpeg-turbo'
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
		('libmodplug.so.1')
			package_name='media-libs/libmodplug'
		;;
		('libmpg123.so.0')
			package_name='media-sound/mpg123'
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
		('libnssutil3.so')
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
		('libphysfs.so.1')
			package_name='dev-games/physfs'
		;;
		('libpixman-1.so.0')
			package_name='x11-libs/pixman'
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
			package_name='media-libs/libsdl[opengl]'
		;;
		('libSDL_kitchensink.so.1')
			# This library is not provided for Gentonn
			unset package_name
		;;
		('libSDL_mixer-1.2.so.0')
			package_name='media-libs/sdl-mixer'
		;;
		('libSDL_sound-1.0.so.1')
			package_name='media-libs/sdl-sound'
		;;
		('libSDL_ttf-2.0.so.0')
			package_name='media-libs/sdl-ttf'
		;;
		('libSDL2-2.0.so.0')
			package_name='media-libs/libsdl2[opengl]'
		;;
		('libSDL2_image-2.0.so.0')
			# Most games will require at least jpeg and png
			# Maybe we should add gif and tiff to that list?
			package_name='media-libs/sdl2-image[jpeg,png]'
		;;
		('libSDL2_mixer-2.0.so.0')
			# Most games will require at least one of flac, mp3, vorbis or wav USE flags,
			# it should better to require them all instead of not requiring any
			# and having non-fonctionnal sound in some games.
			package_name='media-libs/sdl2-mixer[flac,mp3,vorbis,wav]'
		;;
		('libSDL2_ttf-2.0.so.0')
			package_name='media-libs/sdl2-ttf'
		;;
		('libsecret-1.so.0')
			package_name='app-crypt/libsecret'
		;;
		('libsigc-2.0.so.0')
			package_name='dev-libs/libsigc++'
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
			package_name='sys-devel/gcc'
		;;
		('libtheora.so.0')
			package_name='media-libs/libtheora'
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
		('libvorbisenc.so.2')
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
		('libX11-xcb.so.1')
			package_name='x11-libs/libX11'
		;;
		('libxcb.so.1')
			package_name='x11-libs/libxcb'
		;;
		('libxcb-randr.so.0')
			package_name='x11-libs/libxcb'
		;;
		('libXcomposite.so.1')
			package_name='x11-libs/libXcomposite'
		;;
		('libXcursor.so.1')
			package_name='x11-libs/libXcursor'
		;;
		('libXdamage.so.1')
			package_name='x11-libs/libXdamage'
		;;
		('libXext.so.6')
			package_name='x11-libs/libXext'
		;;
		('libXfixes.so.3')
			package_name='x11-libs/libXfixes'
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
		('libxml2.so.2')
			package_name='dev-libs/libxml2'
		;;
		('libxmp.so.4')
			package_name='media-libs/libxmp'
		;;
		('libXrandr.so.2')
			package_name='x11-libs/libXrandr'
		;;
		('libXrender.so.1')
			package_name='x11-libs/libXrender'
		;;
		('libxslt.so.1')
			package_name='dev-libs/libxslt'
		;;
		('libXss.so.1')
			package_name='x11-libs/libXScrnSaver'
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
		('liballeg.so.4.4')
			package_name='media-libs/allegro[abi_x86_32]'
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
		('libaudio.so.2')
			package_name='media-libs/nas[abi_x86_32]'
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
		('libbz2.so.1.0'|'libbz2.so.1')
			package_name='app-arch/bzip2[abi_x86_32]'
		;;
		('libc.so.6')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('libcairo.so.2')
			package_name='x11-libs/cairo[abi_x86_32]'
		;;
		('liblcms2.so.2')
			package_name='media-libs/lcms[abi_x86_32]'
		;;
		('libcom_err.so.2')
			package_name='sys-libs/e2fsprogs-libs[abi_x86_32]'
		;;
		('libcrypt.so.1')
			package_name='sys-libs/libxcrypt[abi_x86_32]'
		;;
		('libcrypto.so.1.1')
			package_name='dev-libs/openssl[abi_x86_32]'
		;;
		('libcups.so.2')
			package_name='net-print/cups[abi_x86_32]'
		;;
		('libcurl.so.4')
			package_name='net-misc/curl[abi_x86_32]'
		;;
		('libcurl-gnutls.so.4')
			package_name='net-libs/libcurl-debian[abi_x86_32]'
			pkg_overlay='steam-overlay'
			dependencies_gentoo_link 'libcurl-gnutls.so.4' "/usr/$(dependency_gentoo_libdir 'x86')/debiancompat" "$package"
			;;
		('libdbus-1.so.3')
			package_name='sys-apps/dbus[abi_x86_32]'
		;;
		('libdl.so.2')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('libexpat.so.1')
			package_name='dev-libs/expat[abi_x86_32]'
		;;
		('libFAudio.so.0')
			package_name='app-emulation/faudio[abi_x86_32]'
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
		('libgconf-2.so.4')
			package_name='gnome-base/gconf[abi_x86_32]'
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
		('libgomp.so.1')
			package_name='sys-devel/gcc[abi_x86_32]'
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
		('libIL.so.1')
			package_name='media-libs/devil[abi_x86_32]'
		;;
		('libjpeg.so.62')
			package_name='media-libs/libjpeg-turbo[abi_x86_32]'
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
		('libmodplug.so.1')
			package_name='media-libs/libmodplug[abi_x86_32]'
		;;
		('libmpg123.so.0')
			package_name='media-sound/mpg123[abi_x86_32]'
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
		('libnssutil3.so')
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
		('libphysfs.so.1')
			package_name='dev-games/physfs[abi_x86_32]'
		;;
		('libpixman-1.so.0')
			package_name='x11-libs/pixman[abi_x86_32]'
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
			package_name='media-libs/libsdl[abi_x86_32,opengl]'
		;;
		('libSDL_kitchensink.so.1')
			# This library is not provided for Gentoo
			unset package_name
		;;
		('libSDL_mixer-1.2.so.0')
			package_name='media-libs/sdl-mixer[abi_x86_32]'
		;;
		('libSDL_sound-1.0.so.1')
			package_name='media-libs/sdl-sound[abi_x86_32]'
		;;
		('libSDL_ttf-2.0.so.0')
			package_name='media-libs/sdl-ttf[abi_x86_32]'
		;;
		('libSDL2-2.0.so.0')
			package_name='media-libs/libsdl2[abi_x86_32,opengl]'
		;;
		('libSDL2_image-2.0.so.0')
			# Most games will require at least jpeg and png
			# Maybe we should add gif and tiff to that list?
			package_name='media-libs/sdl2-image[jpeg,png,abi_x86_32]'
		;;
		('libSDL2_mixer-2.0.so.0')
			# Most games will require at least one of flac, mp3, vorbis or wav USE flags,
			# it should better to require them all instead of not requiring any
			# and having non-fonctionnal sound in some games.
			package_name='media-libs/sdl2-mixer[flac,mp3,vorbis,wav,abi_x86_32]'
		;;
		('libSDL2_ttf-2.0.so.0')
			package_name='media-libs/sdl2-ttf[abi_x86_32]'
		;;
		('libsecret-1.so.0')
			package_name='app-crypt/libsecret[abi_x86_32]'
		;;
		('libsigc-2.0.so.0')
			package_name='dev-libs/libsigc++[abi_x86_32]'
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
			package_name='sys-devel/gcc amd64? ( sys-devel/gcc[multilib] )'
		;;
		('libtheora.so.0')
			package_name='media-libs/libtheora[abi_x86_32]'
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
		('libvorbisenc.so.2')
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
		('libX11-xcb.so.1')
			package_name='x11-libs/libX11[abi_x86_32]'
		;;
		('libxcb.so.1')
			package_name='x11-libs/libxcb[abi_x86_32]'
		;;
		('libxcb-randr.so.0')
			package_name='x11-libs/libxcb[abi_x86_32]'
		;;
		('libXcomposite.so.1')
			package_name='x11-libs/libXcomposite[abi_x86_32]'
		;;
		('libXcursor.so.1')
			package_name='x11-libs/libXcursor[abi_x86_32]'
		;;
		('libXdamage.so.1')
			package_name='x11-libs/libXdamage[abi_x86_32]'
		;;
		('libXext.so.6')
			package_name='x11-libs/libXext[abi_x86_32]'
		;;
		('libXfixes.so.3')
			package_name='x11-libs/libXfixes[abi_x86_32]'
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
		('libxml2.so.2')
			package_name='dev-libs/libxml2[abi_x86_32]'
		;;
		('libxmp.so.4')
			package_name='media-libs/libxmp[abi_x86_32]'
		;;
		('libXrandr.so.2')
			package_name='x11-libs/libXrandr[abi_x86_32]'
		;;
		('libXrender.so.1')
			package_name='x11-libs/libXrender[abi_x86_32]'
		;;
		('libxslt.so.1')
			package_name='dev-libs/libxslt[abi_x86_32]'
		;;
		('libXss.so.1')
			package_name='x11-libs/libXScrnSaver[abi_x86_32]'
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
