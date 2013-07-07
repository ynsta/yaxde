#!/bin/bash
# =====================================================================
[ -z "${VERSION}" ] && VERSION=4.8-$(date +%Y.%m)

# =====================================================================
# Used packages
GCC=gcc-4.8.1
BINUTILS=binutils-2.23.1
GDB=gdb-7.5.1
GMP=gmp-5.1.1
MPFR=mpfr-3.1.2
MPC=mpc-1.0.1
MXE=e3e6d0b6e4aed0fa2fe1c6a5e29e33407679f602

# =====================================================================
# Options

# Set to 1 to build GDB with python support
GDBPYTHON=1

# Language support to build (usualy c or c,c++)
LANGUAGES="c,c++,ada"

GCCEXTRACFG=""

MULTILIB=1

# =====================================================================

SCRIPT_DIR="$(dirname $0)"
SCRIPT_NAME="$(basename $0)"

# =====================================================================

. "${SCRIPT_DIR}/build-functions.sh"

# =====================================================================
build-env
# =====================================================================
# Patches
BINUTILS_PATCHES=""

GCC_PATCHES="\
${PKGDIR}/gcc-4.8.0-ada_bare_board.patch \
${PKGDIR}/gcc-4.8.0-xgnatugn-canadian.patch \
${PKGDIR}/gcc-4.8.0-fix-gnatools-canadian.patch"

NEWLIB_PATCHES=""
GDB_PATCHES=""

# =====================================================================
build-gmp
build-mpfr
build-mpc
build-native-gcc ${GCC_PATCHES}
build-mxe
# =====================================================================
remove-srcdirs
