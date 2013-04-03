#!/bin/bash
# =====================================================================
[ -z "${VERSION}" ] && VERSION=4.8-$(date +%Y.%m)
TARGET=stlink

# =====================================================================

SCRIPT_DIR="$(dirname $0)"
SCRIPT_NAME="$(basename $0)"

# =====================================================================

. "${SCRIPT_DIR}/build-functions.sh"

# =====================================================================
build-env
pushd . &>/dev/null

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

popd &>/dev/null
