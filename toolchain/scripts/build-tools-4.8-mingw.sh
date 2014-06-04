#!/bin/bash
# =====================================================================
[ -z "${VERSION}" ] && VERSION=4.8-$(date +%Y.%m)
TARGET=tools
HOST=i686-pc-mingw32
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
${PKGDIR}/gcc-4.8.3-arm-cortex-elf-multilibs.patch \
${PKGDIR}/gcc-4.8.3-ada_bare_board.patch \
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

    "${SRCDIR}"/${LIBUSB}/configure --host=${HOST} --prefix=${PREFIX} >> "${LOG}" 2>&1

    make         >> "${LOG}" 2>&1
    make install >> "${LOG}" 2>&1
    foot
fi
# =====================================================================

cd ${BASEPATH}

if [ ! -d "${OBJDIR}"/libftdi-${BUILDSUFFIX} ]; then
    mkdir -p "${OBJDIR}"/libftdi-${BUILDSUFFIX}
    cd       "${OBJDIR}"/libftdi-${BUILDSUFFIX}

    head "build-libftdi:"

    download http://www.intra2net.com/en/developer/libftdi/download/${LIBFTDI}.tar.gz

    untar ${PKGDIR}/${LIBFTDI}.tar.*

    "${SRCDIR}"/${LIBFTDI}/configure --host=${HOST} --prefix=${PREFIX} >> "${LOG}" 2>&1

    make         >> "${LOG}" 2>&1
    make install >> "${LOG}" 2>&1


cat <<EOF > ${PREFIX}/lib/pkgconfig/libftdi.pc
prefix=${PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libftdi
Description: Library to program and control the FTDI USB controller
Version: 0.20
Libs: -L\${libdir} -lftdi -lusb-1.0
Libs.private:
Cflags: -I\${includedir} -I\${includedir}/libusb-1.0

EOF

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
    ./autogen.sh >> "${LOG}" 2>&1
    cd - &>/dev/null

    PKG_CONFIG_LIBDIR=${PREFIX}/lib/pkgconfig "${SRCDIR}"/${DFU_UTIL}/configure \
	--host=${HOST} --prefix=${PREFIX} >> "${LOG}" 2>&1

    make         >> "${LOG}" 2>&1
    make install >> "${LOG}" 2>&1
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
	./bootstrap >> "${LOG}" 2>&1
	popd &>/dev/null
    fi
    apatch "${SRCDIR}/${OPENOCD}" ${PKGDIR}/${OPENOCD}-zynq.patch

    LIBUSB1_LIBS=-lusb-1.0 \
	LIBUSB1_CFLAGS=-I${PREFIX}/include/libusb-1.0 \
	PKG_CONFIG_LIB=${PREFIX}/lib/pkgconfig \
	"${SRCDIR}/${OPENOCD}"/configure \
	--disable-werror \
	--prefix=${PREFIX} \
	--host=${HOST}  >> "${LOG}" 2>&1

    make         >> "${LOG}" 2>&1
    make install >> "${LOG}" 2>&1
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
    autoreconf -i -s -v -f >> "${LOG}" 2>&1
    popd &>/dev/null

    "${SRCDIR}/${URJTAG}"/configure --prefix=${PREFIX} --disable-python --host=${HOST} >> "${LOG}" 2>&1 || error

    make         >> "${LOG}" 2>&1
    make install >> "${LOG}" 2>&1
    foot
fi

# =====================================================================


# =====================================================================
remove-srcdirs
# =====================================================================
build-setup

popd &>/dev/null

replace-srcdirs-by-pkgs
