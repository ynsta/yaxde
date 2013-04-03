#!/bin/bash
# =====================================================================
[ -z "${VERSION}" ] && VERSION=4.8-$(date +%Y.%m)

TARGET=m68k-none-elf

GCCCPU=5475
GCCARCH=cf

# =====================================================================
# Used packages
GCC=gcc-4.8.0
NEWLIB=newlib-2.0.0
NEWLIBNANO=newlib-nano-1.0
BINUTILS=binutils-2.23.1
GDB=gdb-7.5.1
GMP=gmp-5.1.1
MPFR=mpfr-3.1.2
MPC=mpc-1.0.1
EXPAT=expat-2.1.0

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
