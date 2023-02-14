# Arch Linux - Print the package names providing the given native libraries
# USAGE: archlinux_dependencies_providing_native_libraries $library[…]
# RETURN: a list of Arch Linux package names,
#         one per line
archlinux_dependencies_providing_native_libraries() {
	local library packages_list package
	packages_list=''
	for library in "$@"; do
		package=$(dependency_package_providing_library_arch "$library")
		packages_list="$packages_list
		$package"
	done

	printf '%s' "$packages_list" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}

# Arch Linux - Print the package names providing the given native libraries in a 32-bit build
# USAGE: archlinux_dependencies_providing_native_libraries_32bit $library[…]
# RETURN: a list of Arch Linux package names,
#         one per line
archlinux_dependencies_providing_native_libraries_32bit() {
	local library packages_list package
	packages_list=''
	for library in "$@"; do
		package=$(dependency_package_providing_library_arch32 "$library")
		packages_list="$packages_list
		$package"
	done

	printf '%s' "$packages_list" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}

# Arch Linux - Print the package name providing the given native library
# USAGE: dependency_package_providing_library_arch $library
dependency_package_providing_library_arch() {
	local library package_name
	library="$1"
	case "$library" in
		('ld-linux.so.2')
			package_name='glibc'
		;;
		('ld-linux-x86-64.so.2')
			package_name='glibc'
		;;
		('liballeg.so.4.4')
			package_name='allegro4'
		;;
		('libasound.so.2')
			package_name='alsa-lib'
		;;
		('libasound_module_'*'.so')
			package_name='alsa-plugins'
		;;
		('libatk-1.0.so.0')
			package_name='atk'
		;;
		('libaudio.so.2')
			package_name='nas'
		;;
		('libavcodec.so.58')
			package_name='ffmpeg'
		;;
		('libavformat.so.58')
			package_name='ffmpeg'
		;;
		('libavutil.so.56')
			package_name='ffmpeg'
		;;
		('libbz2.so.1.0')
			package_name='bzip2'
		;;
		('libc.so.6')
			package_name='glibc'
		;;
		('libcairo.so.2')
			package_name='cairo'
		;;
		('liblcms2.so.2')
			package_name='lcms2'
		;;
		('libcom_err.so.2')
			package_name='e2fsprogs'
		;;
		('libcrypt.so.1')
			package_name='libxcrypt'
		;;
		('libcrypto.so.1.1')
			package_name='openssl'
		;;
		('libcups.so.2')
			package_name='libcups'
		;;
		('libcurl.so.4')
			package_name='curl'
		;;
		('libcurl-gnutls.so.4')
			package_name='libcurl-gnutls'
		;;
		('libdbus-1.so.3')
			package_name='dbus'
		;;
		('libdl.so.2')
			package_name='glibc'
		;;
		('libexpat.so.1')
			package_name='expat'
		;;
		('libFAudio.so.0')
			package_name='faudio'
		;;
		('libfontconfig.so.1')
			package_name='fontconfig'
		;;
		('libfreeimage.so.3')
			package_name='freeimage'
		;;
		('libfreetype.so.6')
			package_name='freetype2'
		;;
		('libgcc_s.so.1')
			package_name='gcc-libs'
		;;
		('libgconf-2.so.4')
			package_name='gconf'
		;;
		('libgcrypt.so.11')
			package_name='libgcrypt15'
		;;
		('libgdk_pixbuf-2.0.so.0')
			package_name='gdk-pixbuf2'
		;;
		('libgdk-x11-2.0.so.0')
			package_name='gtk2'
		;;
		('libgio-2.0.so.0')
			package_name='glib2'
		;;
		('libGL.so.1')
			package_name='libgl'
		;;
		('libGLEW.so.2.2')
			package_name='glew'
		;;
		('libglfw.so.3')
			package_name='glfw'
		;;
		('libglib-2.0.so.0')
			package_name='glib2'
		;;
		('libGLU.so.1')
			package_name='glu'
		;;
		('libGLX.so.0')
			package_name='libglvnd'
		;;
		('libgmodule-2.0.so.0')
			package_name='glib2'
		;;
		('libgobject-2.0.so.0')
			package_name='glib2'
		;;
		('libgomp.so.1')
			package_name='gcc-libs'
		;;
		('libgpg-error.so.0')
			package_name='libgpg-error'
		;;
		('libgssapi_krb5.so.2')
			package_name='krb5'
		;;
		('libgthread-2.0.so.0')
			package_name='glib2'
		;;
		('libgtk-x11-2.0.so.0')
			package_name='gtk2'
		;;
		('libICE.so.6')
			package_name='libice'
		;;
		('libidn2.so.0')
			package_name='libidn2'
		;;
		('libjpeg.so.62')
			package_name='libjpeg6-turbo'
		;;
		('libk5crypto.so.3')
			package_name='krb5'
		;;
		('libkrb5.so.3')
			package_name='krb5'
		;;
		('libluajit-5.1.so.2')
			package_name='luajit'
		;;
		('libm.so.6')
			package_name='glibc'
		;;
		('libmbedtls.so.12')
			package_name='mbedtls'
		;;
		('libminiupnpc.so.17')
			package_name='miniupnpc'
		;;
		('libmodplug.so.1')
			package_name='libmodplug'
		;;
		('libmpg123.so.0')
			package_name='mpg123'
		;;
		('libnghttp2.so.14')
			package_name='libnghttp2'
		;;
		('libnspr4.so')
			package_name='nspr'
		;;
		('libnss3.so')
			package_name='nss'
		;;
		('libnssutil3.so')
			package_name='nss'
		;;
		('libogg.so.0')
			package_name='libogg'
		;;
		('libopenal.so.1')
			package_name='openal'
		;;
		('libOpenGL.so.0')
			package_name='libglvnd'
		;;
		('libopenmpt.so.0')
			package_name='libopenmpt'
		;;
		('libpango-1.0.so.0')
			package_name='pango'
		;;
		('libpangocairo-1.0.so.0')
			package_name='pango'
		;;
		('libpangoft2-1.0.so.0')
			package_name='pango'
		;;
		('libphysfs.so.1')
			package_name='physfs'
		;;
		('libpixman-1.so.0')
			package_name='pixman'
		;;
		('libplc4.so')
			package_name='nspr'
		;;
		('libplds4.so')
			package_name='nspr'
		;;
		('libpng16.so.16')
			package_name='libpng'
		;;
		('libpsl.so.5')
			package_name='libpsl'
		;;
		('libpthread.so.0')
			package_name='glibc'
		;;
		('libpulse.so.0')
			package_name='libpulse'
		;;
		('libpulse-simple.so.0')
			package_name='libpulse'
		;;
		('libresolv.so.2')
			package_name='glibc'
		;;
		('librt.so.1')
			package_name='glibc'
		;;
		('librtmp.so.1')
			package_name='rtmpdump'
		;;
		('libSDL-1.2.so.0')
			package_name='sdl'
		;;
		('libSDL_kitchensink.so.1')
			# This library is not provided for Arch Linux
			unset package_name
		;;
		('libSDL_mixer-1.2.so.0')
			package_name='sdl_mixer'
		;;
		('libSDL_sound-1.0.so.1')
			package_name='sdl_sound'
		;;
		('libSDL_ttf-2.0.so.0')
			package_name='sdl_ttf'
		;;
		('libSDL2-2.0.so.0')
			package_name='sdl2'
		;;
		('libSDL2_image-2.0.so.0')
			package_name='sdl2_image'
		;;
		('libSDL2_mixer-2.0.so.0')
			package_name='sdl2_mixer'
		;;
		('libSDL2_ttf-2.0.so.0')
			package_name='sdl2_ttf'
		;;
		('libsecret-1.so.0')
			package_name='libsecret'
		;;
		('libsigc-2.0.so.0')
			package_name='libsigc++'
		;;
		('libSM.so.6')
			package_name='libsm'
		;;
		('libsmime3.so')
			package_name='nss'
		;;
		('libsmpeg-0.4.so.0')
			package_name='smpeg'
		;;
		('libsodium.so.23')
			package_name='libsodium'
		;;
		('libssh2.so.1')
			package_name='libssh2'
		;;
		('libssl.so.1.1')
			package_name='openssl'
		;;
		('libssl3.so')
			package_name='nss'
		;;
		('libstdc++.so.5')
			package_name='libstdc++5'
		;;
		('libstdc++.so.6')
			package_name='gcc-libs'
		;;
		('libtheora.so.0')
			package_name='libtheora'
		;;
		('libtheoradec.so.1')
			package_name='libtheora'
		;;
		('libthread_db.so.1')
			package_name='glibc'
		;;
		('libturbojpeg.so.0')
			package_name='libjpeg-turbo'
		;;
		('libudev.so.1')
			package_name='libudev.so=1-64'
		;;
		('libuuid.so.1')
			package_name='util-linux-libs'
		;;
		('libuv.so.1')
			package_name='libuv'
		;;
		('libvorbis.so.0')
			package_name='libvorbis'
		;;
		('libvorbisenc.so.2')
			package_name='libvorbis'
		;;
		('libvorbisfile.so.3')
			package_name='libvorbis'
		;;
		('libvulkan.so.1')
			package_name='vulkan-icd-loader'
		;;
		('libX11.so.6')
			package_name='libx11'
		;;
		('libX11-xcb.so.1')
			package_name='libx11'
		;;
		('libxcb.so.1')
			package_name='libxcb'
		;;
		('libxcb-randr.so.0')
			package_name='libxcb'
		;;
		('libXcomposite.so.1')
			package_name='libxcomposite'
		;;
		('libXcursor.so.1')
			package_name='libxcursor'
		;;
		('libXdamage.so.1')
			package_name='libxdamage'
		;;
		('libXext.so.6')
			package_name='libxext'
		;;
		('libXfixes.so.3')
			package_name='libxfixes'
		;;
		('libXft.so.2')
			package_name='libxft'
		;;
		('libXi.so.6')
			package_name='libxi'
		;;
		('libXinerama.so.1')
			package_name='libxinerama'
		;;
		('libxml2.so.2')
			package_name='libxml2'
		;;
		('libxmp.so.4')
			package_name='libxmp'
		;;
		('libXrandr.so.2')
			package_name='libxrandr'
		;;
		('libXrender.so.1')
			package_name='libxrender'
		;;
		('libxslt.so.1')
			package_name='libxslt'
		;;
		('libXss.so.1')
			package_name='libxss'
		;;
		('libXt.so.6')
			package_name='libxt'
		;;
		('libXtst.so.6')
			package_name='libxtst'
		;;
		('libXxf86vm.so.1')
			package_name='libxxf86vm'
		;;
		('libz.so.1')
			package_name='zlib'
		;;
	esac

	if [ -n "$package_name" ]; then
		printf '%s' "$package_name"
		return 0
	fi

	dependencies_unknown_libraries_add "$library"
}

# Arch Linux - Print the package name providing the given native library in a 32-bit build
# USAGE: dependency_package_providing_library_arch32 $library
dependency_package_providing_library_arch32() {
	local library package_name
	library="$1"
	case "$library" in
		('ld-linux.so.2')
			package_name='lib32-glibc'
		;;
		('ld-linux-x86-64.so.2')
			package_name='lib32-glibc'
		;;
		('liballeg.so.4.4')
			package_name='lib32-allegro4'
		;;
		('libasound.so.2')
			package_name='lib32-alsa-lib'
		;;
		('libasound_module_'*'.so')
			package_name='lib32-alsa-plugins'
		;;
		('libatk-1.0.so.0')
			package_name='lib32-atk'
		;;
		('libaudio.so.2')
			# This library is not provided in a 32-bit build for Arch Linux
			unset package_name
		;;
		('libavcodec.so.58')
			package_name='lib32-libffmpeg'
		;;
		('libavformat.so.58')
			package_name='lib32-libffmpeg'
		;;
		('libavutil.so.56')
			package_name='lib32-libffmpeg'
		;;
		('libbz2.so.1.0')
			package_name='lib32-bzip2'
		;;
		('libc.so.6')
			package_name='lib32-glibc'
		;;
		('libcairo.so.2')
			package_name='lib32-cairo'
		;;
		('liblcms2.so.2')
			package_name='lib32-lcms2'
		;;
		('libcom_err.so.2')
			package_name='lib32-e2fsprogs'
		;;
		('libcrypt.so.1')
			package_name='lib32-libxcrypt'
		;;
		('libcrypto.so.1.1')
			package_name='lib32-openssl'
		;;
		('libcups.so.2')
			package_name='lib32-libcups'
		;;
		('libcurl.so.4')
			package_name='lib32-curl'
		;;
		('libcurl-gnutls.so.4')
			package_name='lib32-libcurl-gnutls'
		;;
		('libdbus-1.so.3')
			package_name='lib32-dbus'
		;;
		('libdl.so.2')
			package_name='lib32-glibc'
		;;
		('libexpat.so.1')
			package_name='lib32-expat'
		;;
		('libFAudio.so.0')
			package_name='lib32-faudio'
		;;
		('libfontconfig.so.1')
			package_name='lib32-fontconfig'
		;;
		('libfreeimage.so.3')
			package_name='lib32-freeimage'
		;;
		('libfreetype.so.6')
			package_name='lib32-freetype2'
		;;
		('libgcc_s.so.1')
			package_name='lib32-gcc-libs'
		;;
		('libgconf-2.so.4')
			package_name='lib32-gconf'
		;;
		('libgcrypt.so.11')
			package_name='lib32-libgcrypt15'
		;;
		('libgdk_pixbuf-2.0.so.0')
			package_name='lib32-gdk-pixbuf2'
		;;
		('libgdk-x11-2.0.so.0')
			package_name='lib32-gtk2'
		;;
		('libgio-2.0.so.0')
			package_name='lib32-glib2'
		;;
		('libGL.so.1')
			package_name='lib32-libgl'
		;;
		('libGLEW.so.2.2')
			package_name='lib32-glew'
		;;
		('libglfw.so.3')
			package_name='lib32-glfw'
		;;
		('libglib-2.0.so.0')
			package_name='lib32-glib2'
		;;
		('libGLU.so.1')
			package_name='lib32-glu'
		;;
		('libGLX.so.0')
			package_name='lib32-libglvnd'
		;;
		('libgmodule-2.0.so.0')
			package_name='lib32-glib2'
		;;
		('libgobject-2.0.so.0')
			package_name='lib32-glib2'
		;;
		('libgomp.so.1')
			package_name='lib32-gcc-libs'
		;;
		('libgpg-error.so.0')
			package_name='lib32-libgpg-error'
		;;
		('libgssapi_krb5.so.2')
			package_name='lib32-krb5'
		;;
		('libgthread-2.0.so.0')
			package_name='lib32-glib2'
		;;
		('libgtk-x11-2.0.so.0')
			package_name='lib32-gtk2'
		;;
		('libICE.so.6')
			package_name='lib32-libice'
		;;
		('libidn2.so.0')
			package_name='lib32-libidn2'
		;;
		('libjpeg.so.62')
			package_name='lib32-libjpeg6-turbo'
		;;
		('libk5crypto.so.3')
			package_name='lib32-krb5'
		;;
		('libkrb5.so.3')
			package_name='lib32-krb5'
		;;
		('libluajit-5.1.so.2')
			package_name='lib32-luajit'
		;;
		('libm.so.6')
			package_name='lib32-glibc'
		;;
		('libmbedtls.so.12')
			# This library is not provided in a 32-bit build for Arch Linux
			unset package_name
		;;
		('libminiupnpc.so.17')
			# This library is not provided in a 32-bit build for Arch Linux
			unset package_name
		;;
		('libmodplug.so.1')
			package_name='lib32-libmodplug'
		;;
		('libmpg123.so.0')
			package_name='lib32-mpg123'
		;;
		('libnghttp2.so.14')
			package_name='lib32-libnghttp2'
		;;
		('libnspr4.so')
			package_name='lib32-nspr'
		;;
		('libnss3.so')
			package_name='lib32-nss'
		;;
		('libnssutil3.so')
			package_name='lib32-nss'
		;;
		('libogg.so.0')
			package_name='lib32-libogg'
		;;
		('libopenal.so.1')
			package_name='lib32-openal'
		;;
		('libOpenGL.so.0')
			package_name='lib32-libglvnd'
		;;
		('libopenmpt.so.0')
			# This library is not provided in a 32-bit build for Arch Linux
			unset package_name
		;;
		('libpango-1.0.so.0')
			package_name='lib32-pango'
		;;
		('libpangocairo-1.0.so.0')
			package_name='lib32-pango'
		;;
		('libpangoft2-1.0.so.0')
			package_name='lib32-pango'
		;;
		('libphysfs.so.1')
			package_name='lib32-physfs'
		;;
		('libpixman-1.so.0')
			package_name='lib32-pixman'
		;;
		('libplc4.so')
			package_name='lib32-nspr'
		;;
		('libplds4.so')
			package_name='lib32-nspr'
		;;
		('libpng16.so.16')
			package_name='lib32-libpng'
		;;
		('libpsl.so.5')
			package_name='lib32-libpsl'
		;;
		('libpthread.so.0')
			package_name='lib32-glibc'
		;;
		('libpulse.so.0')
			package_name='lib32-libpulse'
		;;
		('libpulse-simple.so.0')
			package_name='lib32-libpulse'
		;;
		('libresolv.so.2')
			package_name='lib32-glibc'
		;;
		('librt.so.1')
			package_name='lib32-glibc'
		;;
		('librtmp.so.1')
			package_name='lib32-rtmpdump'
		;;
		('libSDL-1.2.so.0')
			package_name='lib32-sdl'
		;;
		('libSDL_kitchensink.so.1')
			# This library is not provided for Arch Linux
			unset package_name
		;;
		('libSDL_mixer-1.2.so.0')
			package_name='lib32-sdl_mixer'
		;;
		('libSDL_sound-1.0.so.1')
			package_name='lib32-sdl_sound'
		;;
		('libSDL_ttf-2.0.so.0')
			package_name='lib32-sdl_ttf'
		;;
		('libSDL2-2.0.so.0')
			package_name='lib32-sdl2'
		;;
		('libSDL2_image-2.0.so.0')
			package_name='lib32-sdl2_image'
		;;
		('libSDL2_mixer-2.0.so.0')
			package_name='lib32-sdl2_mixer'
		;;
		('libSDL2_ttf-2.0.so.0')
			package_name='lib32-sdl2_ttf'
		;;
		('libsecret-1.so.0')
			# This library is not provided in a 32-bit build for Arch Linux
			unset package_name
		;;
		('libsigc-2.0.so.0')
			package_name='lib32-libsigc++'
		;;
		('libSM.so.6')
			package_name='lib32-libsm'
		;;
		('libsmime3.so')
			package_name='lib32-nss'
		;;
		('libsmpeg-0.4.so.0')
			package_name='lib32-smpeg'
		;;
		('libsodium.so.23')
			package_name='lib32-libsodium'
		;;
		('libssh2.so.1')
			package_name='lib32-libssh2'
		;;
		('libssl.so.1.1')
			package_name='lib32-openssl'
		;;
		('libssl3.so')
			package_name='lib32-nss'
		;;
		('libstdc++.so.5')
			package_name='lib32-libstdc++5'
		;;
		('libstdc++.so.6')
			package_name='lib32-gcc-libs'
		;;
		('libtheora.so.0')
			package_name='lib32-libtheora'
		;;
		('libtheoradec.so.1')
			package_name='lib32-libtheora'
		;;
		('libthread_db.so.1')
			package_name='lib32-glibc'
		;;
		('libturbojpeg.so.0')
			package_name='lib32-libjpeg-turbo'
		;;
		('libudev.so.1')
			package_name='lib32-systemd'
		;;
		('libuuid.so.1')
			package_name='lib32-util-linux'
		;;
		('libuv.so.1')
			# This library is not provided in a 32-bit build for Arch Linux
			unset package_name
		;;
		('libvorbis.so.0')
			package_name='lib32-libvorbis'
		;;
		('libvorbisenc.so.2')
			package_name='lib32-libvorbis'
		;;
		('libvorbisfile.so.3')
			package_name='lib32-libvorbis'
		;;
		('libvulkan.so.1')
			package_name='lib32-vulkan-icd-loader'
		;;
		('libX11.so.6')
			package_name='lib32-libx11'
		;;
		('libX11-xcb.so.1')
			package_name='lib32-libx11'
		;;
		('libxcb.so.1')
			package_name='lib32-libxcb'
		;;
		('libxcb-randr.so.0')
			package_name='lib32-libxcb'
		;;
		('libXcomposite.so.1')
			package_name='lib32-libxcomposite'
		;;
		('libXcursor.so.1')
			package_name='lib32-libxcursor'
		;;
		('libXdamage.so.1')
			package_name='lib32-libxdamage'
		;;
		('libXext.so.6')
			package_name='lib32-libxext'
		;;
		('libXfixes.so.3')
			package_name='lib32-libxfixes'
		;;
		('libXft.so.2')
			package_name='lib32-libxft'
		;;
		('libXi.so.6')
			package_name='lib32-libxi'
		;;
		('libXinerama.so.1')
			package_name='lib32-libxinerama'
		;;
		('libxml2.so.2')
			package_name='lib32-libxml2'
		;;
		('libxmp.so.4')
			package_name='lib32-libxmp-git'
		;;
		('libXrandr.so.2')
			package_name='lib32-libxrandr'
		;;
		('libXrender.so.1')
			package_name='lib32-libxrender'
		;;
		('libxslt.so.1')
			package_name='lib32-libxslt'
		;;
		('libXss.so.1')
			package_name='lib32-libxss'
		;;
		('libXt.so.6')
			package_name='lib32-libxt'
		;;
		('libXtst.so.6')
			package_name='lib32-libxtst'
		;;
		('libXxf86vm.so.1')
			package_name='lib32-libxxf86vm'
		;;
		('libz.so.1')
			package_name='lib32-zlib'
		;;
	esac

	if [ -n "$package_name" ]; then
		printf '%s' "$package_name"
		return 0
	fi

	dependencies_unknown_libraries_add "$library"
}
