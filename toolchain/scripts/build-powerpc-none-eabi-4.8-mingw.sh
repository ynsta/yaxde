#!/bin/bash
# =====================================================================
[ -z "${VERSION}" ] && VERSION=4.8-$(date +%Y.%m)

TARGET=powerpc-none-eabi
HOST=i686-pc-mingw32

GCCCPU=
GCCARCH=

# =====================================================================
# Options

# Set to 1 to build GDB with python support
GDBPYTHON=0

# Language support to build (usualy c or c,c++)
LANGUAGES="c,c++,ada"

GCCEXTRACFG=""

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
${PKGDIR}/gcc-4.8.3-ada_bare_board.patch \
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
build-mxe
# =====================================================================
build-binutils ${BINUTILS_PATCHES}
build-gcc ${GCC_PATCHES}
build-expat
build-gdb ${GDB_PATCHES}
build-newlibnano
# =====================================================================
remove-srcdirs
# =====================================================================
build-setup
