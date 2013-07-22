#!/bin/bash
# =====================================================================
[ -z "${VERSION}" ] && VERSION=4.8-$(date +%Y.%m)
TARGET=tools

# =====================================================================
QEMU=qemu-linaro-1.5.0-2013.06
# =====================================================================

SCRIPT_DIR="$(dirname $0)"
SCRIPT_NAME="$(basename $0)"

# =====================================================================

. "${SCRIPT_DIR}/build-functions.sh"

# =====================================================================
build-env
pushd . &>/dev/null


# =====================================================================
mkdir -p ${PREFIX}/bin
cp -v ${PKGDIR}/stm32sbl.py ${PREFIX}/bin
# =====================================================================

cd ${BASEPATH}

if [ ! -d "${OBJDIR}"/stlink-${BUILDSUFFIX} ]; then
    mkdir -p "${OBJDIR}"/stlink-${BUILDSUFFIX}
    cd       "${OBJDIR}"/stlink-${BUILDSUFFIX}

    head "build-stlink:"

    download https://github.com/texane/stlink.git
    untar ${PKGDIR}/stlink.tar.*

    cd "${SRCDIR}"/stlink
    ./autogen.sh >> "${LOG}" 2>&1
    cd - &>/dev/null

    "${SRCDIR}"/stlink/configure --prefix=${PREFIX} >> "${LOG}" 2>&1

    make         >> "${LOG}" 2>&1
    make install >> "${LOG}" 2>&1
    foot
fi
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

    "${SRCDIR}"/dfu-util/configure --prefix=${PREFIX} >> "${LOG}" 2>&1

    make         >> "${LOG}" 2>&1
    make install >> "${LOG}" 2>&1
    foot
fi
# =====================================================================

cd ${BASEPATH}

if [ ! -d "${OBJDIR}"/${QEMU}-${BUILDSUFFIX} ]; then
    mkdir -p "${OBJDIR}"/${QEMU}-${BUILDSUFFIX}
    cd       "${OBJDIR}"/${QEMU}-${BUILDSUFFIX}

    head "build-qemu:"

    if [ "${QEMU/linaro}" != "${QEMU}" ]; then
	download https://launchpad.net/qemu-linaro/trunk/${QEMU##*-}/+download/${QEMU}.tar.gz
    else
	download http://wiki.qemu-project.org/download/${QEMU}.tar.bz2
    fi

    untar ${PKGDIR}/${QEMU}.tar.*

    "${SRCDIR}"/${QEMU}/configure --prefix=${PREFIX} >> "${LOG}" 2>&1 || error

    make ${JOBS} >> "${LOG}" 2>&1 || error
    make install >> "${LOG}" 2>&1 || error
    foot
fi




popd &>/dev/null
