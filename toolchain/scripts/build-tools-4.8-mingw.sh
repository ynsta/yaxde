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
${PKGDIR}/gcc-4.8.0-arm-cortex-elf-multilibs.patch \
${PKGDIR}/gcc-4.8.0-ada_bare_board.patch \
${PKGDIR}/gcc-4.8.0-xgnatugn-canadian.patch \
${PKGDIR}/gcc-4.8.0-fix-gnatools-canadian.patch"
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

cd ${BASEPATH}

if [ ! -d "${OBJDIR}"/libusb-${BUILDSUFFIX} ]; then
    mkdir -p "${OBJDIR}"/libusb-${BUILDSUFFIX}
    cd       "${OBJDIR}"/libusb-${BUILDSUFFIX}

    head "build-libusb:"

    download http://downloads.sourceforge.net/project/libusb/libusb-1.0/${LIBUSB}/${LIBUSB}.tar.bz2
    untar ${PKGDIR}/${LIBUSB}.tar.*

    PKG_CONFIG_LIB=${PREFIX}/lib/pkgconfig "${SRCDIR}"/${LIBUSB}/configure --host=${HOST} --prefix=${PREFIX} >> "${LOG}" 2>&1

    make         >> "${LOG}" 2>&1
    make install >> "${LOG}" 2>&1
    foot
fi
# =====================================================================

#cd ${BASEPATH}
#
#
#if [ ! -d "${OBJDIR}"/stlink-${BUILDSUFFIX} ]; then
#    mkdir -p "${OBJDIR}"/stlink-${BUILDSUFFIX}
#    cd       "${OBJDIR}"/stlink-${BUILDSUFFIX}
#
#    head "build-stlink:"
#
#    download https://github.com/texane/stlink.git
#    untar ${PKGDIR}/stlink.tar.*
#
#    cd "${SRCDIR}"/stlink
#    ./autogen.sh >> "${LOG}" 2>&1
#    cd - &>/dev/null
#
#    PKG_CONFIG_LIBDIR=${PREFIX}/lib/pkgconfig "${SRCDIR}"/stlink/configure --host=${HOST} --prefix=${PREFIX} >> "${LOG}" 2>&1
#
#    make         >> "${LOG}" 2>&1
#    make install >> "${LOG}" 2>&1
#    foot
#fi
# =====================================================================

cd ${BASEPATH}

if [ ! -d "${OBJDIR}"/dfu-util-${BUILDSUFFIX} ]; then
    mkdir -p "${OBJDIR}"/dfu-util-${BUILDSUFFIX}
    cd       "${OBJDIR}"/dfu-util-${BUILDSUFFIX}

    head "build-dfu-util:"

    download git://gitorious.org/dfu-util/dfu-util.git
    untar ${PKGDIR}/dfu-util.tar.*

    cd "${SRCDIR}"/dfu-util
    ./autogen.sh >> "${LOG}" 2>&1
    cd - &>/dev/null

    PKG_CONFIG_LIBDIR=${PREFIX}/lib/pkgconfig "${SRCDIR}"/dfu-util/configure --host=${HOST} --prefix=${PREFIX} >> "${LOG}" 2>&1

    make         >> "${LOG}" 2>&1
    make install >> "${LOG}" 2>&1
    foot
fi
# =====================================================================

#cd ${BASEPATH}
#
#if [ ! -d "${OBJDIR}"/${QEMU}-${BUILDSUFFIX} ]; then
#    mkdir -p "${OBJDIR}"/${QEMU}-${BUILDSUFFIX}
#    cd       "${OBJDIR}"/${QEMU}-${BUILDSUFFIX}
#
#    head "build-qemu:"
#
#    if [ "${QEMU/linaro}" != "${QEMU}" ]; then
#	download https://launchpad.net/qemu-linaro/trunk/${QEMU##*-}/+download/${QEMU}.tar.gz
#    else
#	download http://wiki.qemu-project.org/download/${QEMU}.tar.bz2
#    fi
#
#    untar ${PKGDIR}/${QEMU}.tar.*
#
#    "${SRCDIR}"/${QEMU}/configure --prefix=${PREFIX} >> "${LOG}" 2>&1 || error
#
#    make ${JOBS} >> "${LOG}" 2>&1 || error
#    make install >> "${LOG}" 2>&1 || error
#    foot
#fi

# =====================================================================
remove-srcdirs
# =====================================================================
build-setup

popd &>/dev/null
