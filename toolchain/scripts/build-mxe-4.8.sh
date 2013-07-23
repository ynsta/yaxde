#!/bin/bash
# =====================================================================
[ -z "${VERSION}" ] && VERSION=4.8-$(date +%Y.%m)

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

. "${SCRIPT_DIR}/build-versions.sh"
. "${SCRIPT_DIR}/build-functions.sh"

# =====================================================================
build-env
# =====================================================================
# Patches
BINUTILS_PATCHES=""

GCC_PATCHES="\
${PKGDIR}/gcc-4.8.0-arm-cortex-elf-multilibs.patch \
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
