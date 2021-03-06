#!/bin/bash
# =====================================================================
[ -z "${VERSION}" ] && VERSION=4.9-$(date +%Y.%m)

TARGET=arm-none-eabi

# =====================================================================
# Options

# Set to 1 to build GDB with python support
GDBPYTHON=1

# Language support to build (usualy c or c,c++)
LANGUAGES="c,c++,ada"

GCCEXTRACFG=" \
--with-multilib-list=mprofile"

MULTILIB=1

# =====================================================================

SCRIPT_DIR="$(dirname $0)"
SCRIPT_NAME="$(basename $0)"

# =====================================================================

. "${SCRIPT_DIR}/build-versions.sh"
. "${SCRIPT_DIR}/build-functions.sh"

# =====================================================================
build-env

# =====================================================================
# Patches
BINUTILS_PATCHES=""

GCC_PATCHES="\
${PKGDIR}/gcc-4.9.2-add-arm-mprofile-for-multilibs.patch \
${PKGDIR}/gcc-4.9.2-ada_bare_board.patch \
"

NEWLIB_PATCHES=""

GDB_PATCHES=""

# =====================================================================
build-gmp
build-mpfr
build-mpc
patch-newlib ${NEWLIB_PATCHES}
# =====================================================================
build-native-gcc ${GCC_PATCHES}
# =====================================================================
build-binutils ${BINUTILS_PATCHES}
build-gcc ${GCC_PATCHES}
build-expat
build-gdb ${GDB_PATCHES}
build-newlibnano
# =====================================================================
remove-srcdirs
