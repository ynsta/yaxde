#!/bin/bash
# =====================================================================
[ -z "${VERSION}" ] && VERSION=4.8-$(date +%Y.%m)
TARGET=tools

# =====================================================================

SCRIPT_DIR="$(dirname $0)"
SCRIPT_NAME="$(basename $0)"

# =====================================================================

. "${SCRIPT_DIR}/build-versions.sh"
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

    download https://github.com/texane/stlink.git ${STLINK##*-}
    untar ${PKGDIR}/${STLINK}.tar.*

    cd "${SRCDIR}"/${STLINK}
    ./autogen.sh >> "${LOG}" 2>&1
    cd - &>/dev/null

    "${SRCDIR}"/${STLINK}/configure --with-gtk --prefix=${PREFIX} >> "${LOG}" 2>&1

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

    download git://gitorious.org/dfu-util/dfu-util.git ${DFU_UTIL##*-}
    untar ${PKGDIR}/${DFU_UTIL}.tar.*

    cd "${SRCDIR}"/${DFU_UTIL}
    ./autogen.sh >> "${LOG}" 2>&1
    cd - &>/dev/null

    "${SRCDIR}"/${DFU_UTIL}/configure --prefix=${PREFIX} >> "${LOG}" 2>&1

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

    download http://freefr.dl.sourceforge.net/project/openocd/openocd/${OPENOCD##*-}/${OPENOCD}.tar.bz2

    untar ${PKGDIR}/${OPENOCD}.tar.*

    if [ -f bootstrap ]; then
	pushd "${SRCDIR}/${OPENOCD}" &>/dev/null
	chmod +x bootstrap
	./bootstrap >> "${LOG}" 2>&1 || error
	popd &>/dev/null
    fi
    apatch "${SRCDIR}/${OPENOCD}" ${PKGDIR}/${OPENOCD}-zynq.patch

    "${SRCDIR}/${OPENOCD}"/configure --prefix=${PREFIX} >> "${LOG}" 2>&1 || error

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

    "${SRCDIR}/${URJTAG}"/configure --prefix=${PREFIX} --disable-python >> "${LOG}" 2>&1 || error

    make         >> "${LOG}" 2>&1 || error
    make install >> "${LOG}" 2>&1 || error
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

replace-srcdirs-by-pkgs
