#!/bin/bash
# =====================================================================
[ -z "${VERSION}" ] && VERSION=4.8-$(date +%Y.%m)
TARGET=qemu

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
