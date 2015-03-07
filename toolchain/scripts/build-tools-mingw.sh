#!/bin/bash
# =====================================================================
[ -z "${VERSION}" ] && VERSION=4.9-$(date +%Y.%m)
TARGET=tools
HOST=i686-w64-mingw32.static
# =====================================================================

SCRIPT_DIR="$(dirname $0)"
SCRIPT_NAME="$(basename $0)"

# =====================================================================

. "${SCRIPT_DIR}/build-versions.sh"
. "${SCRIPT_DIR}/build-functions.sh"

# =====================================================================
build-env

# =====================================================================
GCC_PATCHES="\
${PKGDIR}/gcc-4.9.2-add-arm-mprofile-for-multilibs.patch \
${PKGDIR}/gcc-4.9.2-ada_bare_board.patch \
"

# =====================================================================
build-gmp
build-mpfr
build-mpc
build-native-gcc ${GCC_PATCHES}
build-mxe
# =====================================================================

pushd . &>/dev/null

# =====================================================================
mkdir -p ${PREFIX}/bin
cp -v ${PKGDIR}/stm32sbl.py ${PREFIX}/bin
# =====================================================================

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
export PKG_CONFIG_LIB=${PREFIX}/lib/pkgconfig

cd ${BASEPATH}

if [ ! -d "${OBJDIR}"/libusb-${BUILDSUFFIX} ]; then
    mkdir -p "${OBJDIR}"/libusb-${BUILDSUFFIX}
    cd       "${OBJDIR}"/libusb-${BUILDSUFFIX}

    head "build-libusb:"

    download http://downloads.sourceforge.net/project/libusb/libusb-1.0/${LIBUSB}/${LIBUSB}.tar.bz2
    untar ${PKGDIR}/${LIBUSB}.tar.*

    "${SRCDIR}"/${LIBUSB}/configure --host=${HOST} --prefix=${PREFIX} >> "${LOG}" 2>&1 || error

    make         >> "${LOG}" 2>&1 || error
    make install >> "${LOG}" 2>&1 || error
    foot
fi

# =====================================================================
cd ${BASEPATH}

if [ ! -d "${OBJDIR}"/hidapi-${BUILDSUFFIX} ]; then
    mkdir -p "${OBJDIR}"/hidapi-${BUILDSUFFIX}
    cd       "${OBJDIR}"/hidapi-${BUILDSUFFIX}

    head "build-hidapi:"

    download http://github.com/signal11/hidapi.git ${HIDAPI##*-}
    untar ${PKGDIR}/${HIDAPI}.tar.*

    pushd "${SRCDIR}/${HIDAPI}" &>/dev/null
    if [ -f bootstrap ]; then
	chmod +x bootstrap
	./bootstrap >> "${LOG}" 2>&1 || error
    fi
    popd &>/dev/null

    "${SRCDIR}"/${HIDAPI}/configure --host=${HOST} --prefix=${PREFIX} >> "${LOG}" 2>&1 || error

    make         >> "${LOG}" 2>&1 || error
    make install >> "${LOG}" 2>&1 || error
    foot
fi

# =====================================================================

cd ${BASEPATH}

if [ ! -d "${OBJDIR}"/${LIBFTDI1}-${BUILDSUFFIX} ]; then
    mkdir -p "${OBJDIR}"/${LIBFTDI1}-${BUILDSUFFIX}
    cd       "${OBJDIR}"/${LIBFTDI1}-${BUILDSUFFIX}

    head "build-libftdi1:"

    download http://www.intra2net.com/en/developer/libftdi/download/${LIBFTDI1}.tar.bz2

    untar ${PKGDIR}/${LIBFTDI1}.tar.*

    pushd "${SRCDIR}/${LIBFTDI1}" &>/dev/null

    cmake \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_TOOLCHAIN_FILE=${BASEPATH}/mxe-${VERSION}/usr/${HOST}/share/cmake/mxe-conf.cmake \
	-DLIBUSB_INCLUDE_DIR=${PREFIX}/include/libusb-1.0 \
	-DLIBUSB_LIBRARIES="-L${PREFIX}/lib -lusb-1.0" \
	"${SRCDIR}/${LIBFTDI1}" >> "${LOG}" 2>&1 || error
    make         >> "${LOG}" 2>&1 || error
    make install >> "${LOG}" 2>&1 || error

    foot
fi
# =====================================================================

cd ${BASEPATH}

if [ ! -d "${OBJDIR}"/dfu-util-${BUILDSUFFIX} ]; then
    mkdir -p "${OBJDIR}"/dfu-util-${BUILDSUFFIX}
    cd       "${OBJDIR}"/dfu-util-${BUILDSUFFIX}

    head "build-dfu-util:"

    download git://gitorious.org/dfu-util/dfu-util.git ${DFU_UTIL##*-}
    untar ${PKGDIR}/${DFU_UTIL}.tar.*

    cd "${SRCDIR}"/${DFU_UTIL}
    ./autogen.sh >> "${LOG}" 2>&1 || error
    cd - &>/dev/null

    export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
    export PKG_CONFIG_LIBDIR=${PREFIX}/lib/pkgconfig

    PKG_CONFIG=/usr/bin/pkg-config \
	"${SRCDIR}"/${DFU_UTIL}/configure \
	--host=${HOST} --prefix=${PREFIX} >> "${LOG}" 2>&1 || error

    make         >> "${LOG}" 2>&1 || error
    make install >> "${LOG}" 2>&1 || error
    foot
fi


# =====================================================================

cd ${BASEPATH}

if [ ! -d "${OBJDIR}"/${OPENOCD}-${BUILDSUFFIX} ]; then
    mkdir -p "${OBJDIR}"/${OPENOCD}-${BUILDSUFFIX}
    cd       "${OBJDIR}"/${OPENOCD}-${BUILDSUFFIX}

    head "openocd:"

    #download http://freefr.dl.sourceforge.net/project/openocd/openocd/${OPENOCD##*-}/${OPENOCD}.tar.bz2

    untar ${PKGDIR}/${OPENOCD}.tar.*

    if [ -f bootstrap ]; then
	pushd "${SRCDIR}/${OPENOCD}" &>/dev/null
	chmod +x bootstrap
	./bootstrap >> "${LOG}" 2>&1 || error
	popd &>/dev/null
    fi
    apatch "${SRCDIR}/${OPENOCD}" ${PKGDIR}/${OPENOCD}-zynq.patch

    export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
    export PKG_CONFIG_LIBDIR=${PREFIX}/lib/pkgconfig

    PKG_CONFIG=/usr/bin/pkg-config \
	"${SRCDIR}/${OPENOCD}"/configure \
	--disable-werror \
	--prefix=${PREFIX} \
	--host=${HOST}  >> "${LOG}" 2>&1 || error

    make         >> "${LOG}" 2>&1 || error
    make install >> "${LOG}" 2>&1 || error
    foot
fi

# =====================================================================

cd ${BASEPATH}

if [ ! -d "${OBJDIR}"/${URJTAG}-${BUILDSUFFIX} ]; then
    mkdir -p "${OBJDIR}"/${URJTAG}-${BUILDSUFFIX}
    cd       "${OBJDIR}"/${URJTAG}-${BUILDSUFFIX}

    head "urjtag:"

    download-svn http://svn.code.sf.net/p/urjtag/svn/trunk/urjtag ${URJTAG}

    untar ${PKGDIR}/${URJTAG}.tar.*

    pushd "${SRCDIR}/${URJTAG}" &>/dev/null
    autoreconf -i -s -v -f >> "${LOG}" 2>&1 || error
    popd &>/dev/null

    "${SRCDIR}/${URJTAG}"/configure CFLAGS="-DNOCRYPT -DNOUSER" --prefix=${PREFIX} --disable-python --host=${HOST} >> "${LOG}" 2>&1 || error

    make         >> "${LOG}" 2>&1 || error
    make install >> "${LOG}" 2>&1 || error
    foot
fi

# =====================================================================


# =====================================================================
remove-srcdirs
# =====================================================================
build-setup

popd &>/dev/null

replace-srcdirs-by-pkgs
