# -*- sh -*-
# x-tools generation helper functions
#
# Copyright (c) 2013, Stany MARCEL <stanypub@gmail.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#


function time_start() {
    start=$(date +%s)
}

function time_get() {
    cur=$(date +%s)
    duration=$(($cur - $start))
    duration_min=$(($duration / 60))
    duration_sec=$(($duration % 60))
}

function head() {
    time_start
    cat <<EOF
=======================================================================
EOF
    for line; do
	echo $line
    done

    rm -rf "${LOG}"
    touch "${LOG}"
    set | egrep '^[A-Za-z_0-9]+=' >> "${LOG}" 2>&1
}

function foot() {
    for line; do
	echo $line
    done
    time_get
    echo "Finished in ${duration_min}min and ${duration_sec}sec"
}

function error()
{
    for line; do
	echo $line
    done
    time_get
    echo "Fatal Error after ${duration_min}min and ${duration_sec}sec"
    echo "Logs are in ${LOG}"
    exit 1
}

# =====================================================================
function build-env() {

    # = Reset env =====================================================
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/mingw/bin
    unset  LD_LIBRARY_PATH
    unset  LIBRARY_PATH
    unset  CC

    BUILD=$(/usr/bin/gcc -dumpmachine 2>/dev/null || gcc -dumpmachine 2>/dev/null)
    [ -z "${HOST}" ]   && HOST=${BUILD}
    [ -z "${TARGET}" ] && TARGET=${BUILD}

    LOG="/tmp/${SCRIPT_NAME%.sh}.log"
    rm -rf "${LOG}"
    touch "${LOG}"

    export LC_ALL=C

    if [ -f /proc/cpuinfo ]; then
	JOBS="-j$(egrep '^processor[^:]*:' /proc/cpuinfo | wc -l)"
    else
	JOBS=""
    fi

    head "build-env: preparing environment"

    #set -o igncr
    #export SHELLOPTS

    unset LIBRARY_PATH

    [ -z ${HOSTVERSION} ] &&  \
	HOSTVERSION=$(python -c 'import platform; print "-".join(platform.dist()[0:2] + (platform.machine(), )).lower()')
    [ -z ${TBPATH} ] && TBPATH="${SCRIPT_DIR}/../src"

    OBJDIR="${PWD}/${SCRIPT_NAME%.sh}"

    cd "${TBPATH}"
    TBPATH="${PWD}"
    PKGDIR="${PWD}"
    cd - &>/dev/null

    # =====================================================================

    if [ "${HOST/mingw/}" != "${HOST}" ] && [ "${HOST}" != "${BUILD}" ]; then
	CB_MINGW=1
    else
	CB_MINGW=0
    fi
    PREFIXBASENAME=${TARGET}-${VERSION}

    if [ -z ${PREFIX} ]; then
	[ -z ${BASEPATH} ] && BASEPATH=/opt/x-tools
	mkdir -p ${BASEPATH}
	PREFIX=${BASEPATH}/${PREFIXBASENAME}
	BPREFIX=${PREFIX}

    else # PREFIX DEFINED
	BPREFIX=${PREFIX}
    fi

    # Force BASEPATH to abspath(${BPREFIX}/..)
    mkdir -p ${BPREFIX}
    cd ${BPREFIX}/..
    BASEPATH="${PWD}"
    cd - &>/dev/null

    # MinGW Canadian Build
    if [ ${CB_MINGW} -eq 1 ]; then
	[ -z ${WBASEPATH} ] && WBASEPATH=/c/x-tools
	PREFIX=${WBASEPATH}/${PREFIXBASENAME}
    fi


    [ "${SYSROOT}" == "" ] && SYSROOT=0
    [ "${TLS}"	   == "" ] && TLS=1

    if [ ${SYSROOT} -eq 1 ]; then
	SPREFIX="${PREFIX}/sysroot"
	mkdir -p "${SPREFIX}"
    fi

    # =====================================================================

    PATH="${BPREFIX}/bin:${PATH}"
    LD_LIBRARY_PATH="${BPREFIX}/lib:${LD_LIBRARY_PATH}"

    export PATH=${PATH%:}
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH%:}


    # =====================================================================

    mkdir -p "${PREFIX}/src" || error

    cd "${PREFIX}/src"
    SRCDIR="${PWD}"
    cd - &>/dev/null

    export LC_ALL=C
    export CFLAGS="-Wformat=0"

    BUILDSUFFIX="${SCRIPT_NAME}"
    BUILDSUFFIX="${BUILDSUFFIX%.sh}"
    BUILDSUFFIX="${BUILDSUFFIX#build-}"

    TMPLIBS_PREFIX=/tmp/${BUILDSUFFIX}/usr/local

    echo "PREFIX  = $PREFIX"
    if [ ${CB_MINGW} -eq 1 ]; then
	echo "BPREFIX = $BPREFIX"
    fi
    if [ ${SYSROOT} -eq 1 ]; then
	echo "SPREFIX = $SPREFIX"
    fi

    if [ "${MULTILIB}" == "0" ]; then
	MULTILIB="--disable-multilib"
    else
	MULTILIB="--enable-multilib"
    fi

    [ -z ${GDBPYTHON} ] && GDBPYTHON=0

    foot
}

# = Shell Functions ===================================================
function untar() {
    echo -n "Extracting $1 "
    [ -f "${1}" ] || error
    tar xf "$1" -C "${SRCDIR}" && echo "Done" || error
    return 0
}

function apatch()
{
    cd "$1"
    shift
    for p; do
	echo -n "Applying $(basename ${p}) "
	cp "${p}" "${SRCDIR}"
	patch -p 1 < "${p}" >> "${LOG}" 2>&1 || error
	echo "Done"
    done
    cd - &>/dev/null
}

function download()
{
    cd ${PKGDIR}
    for url; do
	file=${url##*/}
	ext=${file##*.}
	case ${ext} in
	    bz2|gz|xz)
		ext=tar.${ext}
		if [ -f ${file} ]; then
		    [ ! -f ${file}.md5  ] && md5sum ${file} > ${file}.md5
		    md5sum -c ${file}.md5 && continue
		    rm ${file}
		fi
		wget "${url}" || error
		md5sum ${file} > ${file}.md5
		;;
	    git)
		file=${file%.git}
		if [ -f ${file}.tar.bz2 ]; then
		    [ ! -f ${file}.tar.bz2.md5  ] && \
			md5sum ${file}.tar.bz2 > ${file}.tar.bz2.md5
		    md5sum -c ${file}.tar.bz2.md5 && continue
		    rm ${file}
		fi
		git clone --depth=1 ${url} || error
		chmod +x $(egrep -rl '^#!' ${file})
		tar cjf ${file}{.tar.bz2,}
		rm -rf ${file}
		md5sum ${file}.tar.bz2 > ${file}.tar.bz2.md5
		;;
	esac
    done
    cd - &> /dev/null
}

# = MXE ===============================================================
function build-mxe() {

    head "build-mxe"

    if [ ! -z "${MXE}" ]; then

	if [ -d "${BASEPATH}/mxe-${VERSION}" ]; then
	    echo "MXE mingw cross compiler already installed"
	    export PATH=${BASEPATH}/mxe-${VERSION}/usr/bin:${PATH}
	    foot
	    return
	fi
	pushd . &>/dev/null

	cd ${BASEPATH}

	if [ ! -f ${PKGDIR}/mxe-${MXE}.tar.bz2 ]; then
	    git clone -b master https://github.com/mxe/mxe.git
	    mv mxe mxe-${VERSION}
	    tar cjf ${PKGDIR}/mxe-${MXE}.tar.bz2 mxe-${VERSION}
	else
	    tar xf ${PKGDIR}/mxe-${MXE}.tar.bz2
	fi

	cd mxe-${VERSION} || error

	git co ${MXE} -b x-tools
	git am ${PKGDIR}/mxe-compile-gnat-with-gcc.patch

	download \
	    http://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.bz2 \
	    http://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.bz2 \
	    http://ftp.gnu.org/gnu/gmp/${GMP}.tar.bz2 \
	    http://www.mpfr.org/mpfr-current/${MPFR}.tar.xz \
	    http://www.multiprecision.org/mpc/download/${MPC}.tar.gz

	ln -s ${PKGDIR} pkg

	make gcc      || error
	make zlib     || error
	make expat    || error
	make libusb   || error
	make libftdi  || error
	make readline || error
	#make ncurses  || error

	rm -rf log
	rm -f pkg

	export PATH=${BASEPATH}/mxe-${VERSION}/usr/bin:${PATH}

	popd &>/dev/null
    else
	echo "build-mxe: not built"
    fi
    foot
}

# = GNU binutils ======================================================
function build-binutils() {
    head "build-binutils"

    if [ ! -z ${BINUTILS} ]; then

	download http://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.bz2

	pushd . &>/dev/null

	if [ ! -d ${SRCDIR}/${BINUTILS} ]; then
	    untar ${PKGDIR}/${BINUTILS}.tar.* || error
	    apatch ${SRCDIR}/${BINUTILS} "$@"
	fi


	if [ ! -d "${OBJDIR}"/${BINUTILS}-${BUILDSUFFIX} ]; then

	    mkdir -p "${OBJDIR}"/${BINUTILS}-${BUILDSUFFIX}

	    cd "${OBJDIR}"/${BINUTILS}-${BUILDSUFFIX}

	    coptions="-v \
--with-pkgversion=${TARGET}-${VERSION} \
--target=${TARGET} \
--prefix=${PREFIX} \
--host=${HOST} \
--build=${BUILD} \
--disable-nls \
--disable-shared \
--enable-interwork \
${MULTILIB}"

 	    [ ! -z "${GCCCPU}"  ]  && coptions+=" --with-cpu=${GCCCPU}"
	    [ ! -z "${GCCARCH}" ] && coptions+=" --with-arch=${GCCARCH}"

	    [ ${SYSROOT} -eq 1 ] && coptions+=" --with-sysroot=${SPREFIX}"

	    "${SRCDIR}"/${BINUTILS}/configure ${coptions} >> "${LOG}" 2>&1 || error
	    make ${JOBS} >> "${LOG}" 2>&1 || error
	    make install >> "${LOG}" 2>&1 || error
	fi

	popd &>/dev/null
    else
	echo "build-binutils: not built"
    fi
    foot
}

# = GMP ===============================================================
function build-gmp() {
    head "build-gmp"
    if [ ! -z $GMP ] && [ ! -d ${SRCDIR}/${GMP} ]; then

	download http://ftp.gnu.org/gnu/gmp/${GMP}.tar.bz2

	untar ${PKGDIR}/${GMP}.tar.* || error
	apatch ${SRCDIR}/${GMP} "$@"
    fi
    foot
}

# = MPFR ==============================================================
function build-mpfr() {
    head "build-mpfr"
    if [ ! -z $MPFR ] && [ ! -d ${SRCDIR}/${MPFR} ]; then

	download http://www.mpfr.org/mpfr-current/${MPFR}.tar.xz

	untar ${PKGDIR}/${MPFR}.tar.* || error
	apatch ${SRCDIR}/${MPFR} "$@"
    fi
    foot
}

# = MPC ===============================================================
function build-mpc() {
    head "build-mpc"
    if [ ! -z $MPC ] && [ ! -d ${SRCDIR}/${MPC} ]; then

	download http://www.multiprecision.org/mpc/download/${MPC}.tar.gz

	untar ${PKGDIR}/${MPC}.tar.* || error
	apatch ${SRCDIR}/${MPC} "$@"
    fi
    foot
}

# = PATCH =============================================================
function patch-newlib()
{
    head "patch-newlib"
    if [ ! -z ${NEWLIB} ] && [ ! -d ${SRCDIR}/${NEWLIB} ]; then

	download ftp://sourceware.org/pub/newlib/${NEWLIB}.tar.gz

	untar ${PKGDIR}/${NEWLIB}.tar.*
	apatch ${SRCDIR}/${NEWLIB} "$@"
    fi
    foot
}

function patch-eglibc()
{
    head "patch-eglibc"
    if [ ! -z ${EGLIBC} ] && [ ! -d ${SRCDIR}/${EGLIBC} ]; then

	# FIXME download from SVN

	untar ${PKGDIR}/${EGLIBC}.tar.*
	apatch ${SRCDIR}/${EGLIBC} "$@"
    fi
    foot
}

function patch-linux()
{
    head "patch-linux"
    if [ ! -z ${LINUX} ] && [ ! -d ${SRCDIR}/${LINUX} ]; then

	# FIXME download

	untar ${PKGDIR}/${LINUX}.tar.*
	apatch ${SRCDIR}/${LINUX} "$@"
    fi
    foot
}

# = newlib-nano =======================================================
function build-newlibnano() {
    if [ ! -z ${NEWLIBNANO} ]; then
	head "build-newlibnano: preparations"

	download git://github.com/32bitmicro/${NEWLIBNANO}.git

	pushd . &>/dev/null

	if [ ! -d ${SRCDIR}/${NEWLIBNANO} ]; then
	    untar ${PKGDIR}/${NEWLIBNANO}.tar.* || error
	    apatch ${SRCDIR}/${NEWLIBNANO} "$@"
	fi
	foot

	if [ ! -d "${OBJDIR}"/${NEWLIBNANO}-${BUILDSUFFIX} ]; then
	    head "build-newlibnano"
	    mkdir -p "${OBJDIR}"/${NEWLIBNANO}-${BUILDSUFFIX}
	    cd "${OBJDIR}"/${NEWLIBNANO}-${BUILDSUFFIX}
	    coptions_newlib="-v \
--target=${TARGET} \
--host=${HOST} \
--build=${BUILD} \
--prefix=${PREFIX}/tmp \
--disable-werror \
--disable-newlib-supplied-syscalls \
--enable-newlib-reent-small \
--disable-nls \
--enable-interwork"

	    "${SRCDIR}"/${NEWLIBNANO}/configure ${coptions_newlib} >> "${LOG}" 2>&1 || error

	    make ${JOBS} >> "${LOG}" 2>&1 || error
	    make install >> "${LOG}" 2>&1 || error

	    for mlib in $(${BPREFIX}/${TARGET}/bin/gcc -print-multi-lib) ; do
		lib="${mlib%%;*}"
		src=${PREFIX}/tmp/${TARGET}/lib/${lib}
		dst=${PREFIX}/${TARGET}/lib/${lib}
		cp -vf "${src}/libstdc++.a" "${dst}/libstdc++_s.a" >> "${LOG}" 2>&1
		cp -vf "${src}/libsupc++.a" "${dst}/libsupc++_s.a" >> "${LOG}" 2>&1
		cp -vf "${src}/libc.a"      "${dst}/libc_s.a"      >> "${LOG}" 2>&1
		cp -vf "${src}/libg.a"      "${dst}/libg_s.a"      >> "${LOG}" 2>&1
		cp -vf "${src}/nano.specs"  "${dst}/"              >> "${LOG}" 2>&1
		cp -vf "${src}/"*crt0.o     "${dst}/"              >> "${LOG}" 2>&1
	    done
	    rm -rf ${PREFIX}/tmp >> "${LOG}" 2>&1
	    foot
	fi
	popd &>/dev/null
    else
	echo "build-newlibnano: not built"
    fi
    foot
}

# = GCC ===============================================================
function build-gcc() {

    if [ ! -z ${GCC} ]; then

	download http://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.bz2
	download ftp://sourceware.org/pub/newlib/${NEWLIB}.tar.gz

        # =============================================================
	head "build-gcc: preparations"

	pushd . &>/dev/null

	[ -d ${SRCDIR}/${NEWLIB} ]     || untar ${PKGDIR}/${NEWLIB}.tar.*

	if [ ! -d ${SRCDIR}/${GCC} ]; then
	    untar ${PKGDIR}/${GCC}.tar.*
	    apatch ${SRCDIR}/${GCC} "$@"
	fi
	cd ${SRCDIR}/${GCC}
	[ ! -z ${MPC} ]    && ln -sf ${SRCDIR}/${MPC}    mpc
	[ ! -z ${MPFR} ]   && ln -sf ${SRCDIR}/${MPFR}   mpfr
	[ ! -z ${GMP} ]    && ln -sf ${SRCDIR}/${GMP}    gmp

	cd - &>/dev/null

	foot

	coptions="-v \
--with-pkgversion=${TARGET}-${VERSION} \
--prefix=${PREFIX} \
--target=${TARGET} \
--host=${HOST} \
--build=${BUILD} \
--with-gnu-as \
--with-gnu-ld \
--with-newlib \
--with-system-zlib \
--enable-newlib-mb \
--enable-newlib-iconv \
--enable-languages=${LANGUAGES} \
--enable-cpp \
--with-dwarf2 \
--enable-version-specific-runtime-libs \
--disable-nls \
--disable-libstdcxx-pch \
--with-gxx-include-dir=${PREFIX}/${TARGET}/include \
--enable-libssp \
${MULTILIB} \
${GCCEXTRACFG}"


	if [ "${TARGET/rtems/}" != "${TARGET}" ]; then
	    coptions+=" --enable-threads=rtems"
	else
	    coptions+=" --disable-shared --disable-threads"
	fi

	[ "${LANGUAGES/ada/}" != "${LANGUAGES}" ] && coptions+=" --enable-libada"

	[ ! -z "${GCCCPU}"  ] && coptions+=" --with-cpu=${GCCCPU}"
	[ ! -z "${GCCARCH}" ] && coptions+=" --with-arch=${GCCARCH}"

	if [ ${CB_MINGW} -eq 1 ]; then

	    coptions="${coptions} --with-build-time-tools=${BPREFIX}/bin"
	fi


	if [ ! -d "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-pass1 ]; then

	    mkdir -p ${PREFIX}/${TARGET}
	    cp -rf "${SRCDIR}"/${NEWLIB}/newlib/libc/include ${PREFIX}/${TARGET}/include

            # =========================================================
	    head "build-gcc: configure(${LANGUAGES})"
	    mkdir -p ${PREFIX}/${TARGET}
	    mkdir -p "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-pass1
	    cd "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-pass1

	    "${SRCDIR}"/${GCC}/configure ${coptions} >> "${LOG}" 2>&1 || error

	    foot

            # =========================================================
	    head "build-gcc: make gcc pass 1"
	    make ${JOBS} all-gcc >> "${LOG}" 2>&1 || error
	    make install-gcc     >> "${LOG}" 2>&1 || error

	    rm -rf ${PREFIX}/${TARGET}/include
	    foot
	fi

	if [ ! -d "${OBJDIR}"/${NEWLIB}-${BUILDSUFFIX} ]; then
	    # =========================================================
	    head "build-gcc: newlib"

	    mkdir -p "${OBJDIR}"/${NEWLIB}-${BUILDSUFFIX}
	    cd "${OBJDIR}"/${NEWLIB}-${BUILDSUFFIX}

	    coptions_newlib="-v \
--target=${TARGET} \
--host=${HOST} \
--build=${BUILD} \
--prefix=${PREFIX} \
--disable-werror \
--disable-newlib-supplied-syscalls \
--enable-newlib-io-long-long \
--enable-newlib-register-fini \
--disable-nls \
--enable-interwork"

	    [ ! -z "${GCCCPU}"  ] && coptions_newlib+=" --with-cpu=${GCCCPU}"
	    [ ! -z "${GCCARCH}" ] && coptions_newlib+=" --with-arch=${GCCARCH}"

	    if [ "${TARGET/rtems/}" != "${TARGET}" ]; then
		coptions_newlib+=" --enable-threads=rtems"
	    else
		coptions_newlib+=" --disable-shared --disable-threads"
	    fi

	    "${SRCDIR}"/${NEWLIB}/configure ${coptions_newlib} >> "${LOG}" 2>&1 || error

	    make ${JOBS} >> "${LOG}" 2>&1 || error
	    make install >> "${LOG}" 2>&1 || error

	    foot
	fi

	if [ ! -d "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-pass2 ]; then

	    # =========================================================
	    head "build-gcc: make gcc pass 2"

	    mkdir -p "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-pass2
	    cd "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-pass2

	    "${SRCDIR}"/${GCC}/configure ${coptions} >> "${LOG}" 2>&1 || error
	    make ${JOBS} >> "${LOG}" 2>&1 || error
	    foot

	    # =========================================================
	    head "build-gcc: install"
	    make install >> "${LOG}" 2>&1 || error

	    if [ "${PREFIX}" != "${PREFIX}" ]; then
		find "${OBJDIR}"/${GCC}-${BUILDSUFFIX} \
		    -name ${TARGET}-${GCC} \
		    -exec cp -rf \{\} "${PREFIX}/.." \;
		find "/${PREFIX}/.." \
		    -name ${TARGET}-${GCC} \
		    -exec cp -rf \{\} "${PREFIX}/.." \;
	    fi
	    foot
	fi

	popd &>/dev/null

    else
	echo "build-gcc: not built"
    fi
}

# = GCC ===============================================================
function build-native-gcc() {

    NATIVE_PREFIX=${BASEPATH}/${BUILD}-${VERSION}

    if [ ! -z ${GCC} ]; then

	head "build-native-gcc: preparations"

	echo ${NATIVE_PREFIX}

	if [ -f ${NATIVE_PREFIX}/bin/gnatmake ]; then
	    echo "Native compiler already installed"
	    export PATH=${NATIVE_PREFIX}/bin:${PATH}
	    foot
	    return ;
	fi

	download http://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.bz2

	# Get GNAT Version
	gnat=$(which /usr/bin/gnat 2>/dev/null || which gnat)
	gnatv=$(${gnat} | grep '^GNAT 4.' | awk '{ print $2 }' | awk -F. '{print $1"."$2}')
	if [ -z ${gnatv} ]; then
	    echo "gnat not installed"
	    error
	fi
	# GCC built with ada support
	export CC=$(which gcc-${gnatv} 2>/dev/null || which gcc)
	export CC

	P_LD_LIBRARY_PATH=LD_LIBRARY_PATH
	# Required with multiarch gcc install like ubuntu one
	export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/${BUILD}
	export LIBRARY_PATH=/usr/lib/${BUILD}
	export C_INCLUDE_PATH=/usr/include/${BUILD}
	export CPLUS_INCLUDE_PATH=/usr/include/${BUILD}

	pushd . &>/dev/null

	if [ ! -d ${SRCDIR}/${GCC} ]; then
	    untar ${PKGDIR}/${GCC}.tar.*
	    apatch ${SRCDIR}/${GCC} "$@"
	fi
	cd ${SRCDIR}/${GCC}
	[ ! -z ${MPC} ]    && ln -sf ${SRCDIR}/${MPC}    mpc
	[ ! -z ${MPFR} ]   && ln -sf ${SRCDIR}/${MPFR}   mpfr
	[ ! -z ${GMP} ]    && ln -sf ${SRCDIR}/${GMP}    gmp

	cd - &>/dev/null

	foot

	if [ ! -d "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-native ]; then

	    mkdir -p "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-native
	    cd "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-native

	    coptions="-v \
--with-pkgversion=${TARGET}-${VERSION} \
--prefix=${NATIVE_PREFIX} \
--host=${BUILD} \
--build=${BUILD} \
--target=${BUILD} \
--with-system-zlib \
--enable-languages=${LANGUAGES} \
--enable-libada \
--disable-nls \
--disable-libstdcxx-pch \
--enable-multilib \
--enable-shared \
--enable-threads=posix"

	    # =========================================================
	    head "build-native-gcc: configure"
	    "${SRCDIR}"/${GCC}/configure ${coptions} >> "${LOG}" 2>&1 || error
	    foot

	    # =========================================================
	    head "build-native-gcc: all"
	    make ${JOBS} >> "${LOG}" 2>&1 || error
	    foot

	    # =========================================================
	    head "build-native-gcc: install"
	    make install >> "${LOG}" 2>&1 || error
	    foot
	fi

	popd &>/dev/null

	unset CC
	export LD_LIBRARY_PATH=${P_LD_LIBRARY_PATH}
	unset LIBRARY_PATH
	unset C_INCLUDE_PATH
	unset CPLUS_INCLUDE_PATH

	ln -sf /usr/lib/${BUILD}/crt*.o ${NATIVE_PREFIX}/lib
    else
	echo "build-native-gcc: not built"
    fi

    export PATH=${NATIVE_PREFIX}/bin:${PATH}
}


# = GCC ===============================================================
function build-gcc-eglibc() {

    if [ ! -z ${GCC} ]; then

	# =============================================================
	head "build-gcc-eglibc: preparing gcc & eglibc builds"

	download http://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.bz2
	# FIXME download eglibc from svn

	pushd . &>/dev/null

	[ -d ${SRCDIR}/${EGLIBC} ] || untar ${PKGDIR}/${EGLIBC}.tar.*

	if  [ "${LINUX_IS_TARBALL}" == "1" ]; then
	    [ -d ${SRCDIR}/${LINUX} ] || untar ${PKGDIR}/${LINUX}.tar.*
	fi

	if [ ! -d ${SRCDIR}/${GCC} ]; then
	    untar ${PKGDIR}/${GCC}.tar.*
	    apatch ${SRCDIR}/${GCC} "$@"
	fi
	cd ${SRCDIR}/${GCC}
	[ ! -z ${MPC} ]    && ln -sf ${SRCDIR}/${MPC}    mpc
	[ ! -z ${MPFR} ]   && ln -sf ${SRCDIR}/${MPFR}   mpfr
	[ ! -z ${GMP} ]    && ln -sf ${SRCDIR}/${GMP}    gmp

	cd - &>/dev/null

	foot

	if [  ! -d "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-3 ]; then

	    mkdir -p "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-1
	    cd "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-1


	    coptions_gccX="-v \
--with-pkgversion=${TARGET}-${VERSION} \
--prefix=${PREFIX} \
--target=${TARGET} \
--host=${HOST} \
--build=${BUILD} \
--with-gnu-as \
--with-gnu-ld \
--disable-nls \
--disable-libmudflap \
--disable-libgomp \
--disable-libquadmath \
--disable-libssp \
--disable-libada \
--without-ppl \
--without-cloog \
--disable-libstdcxx-pch \
${MULTILIB} \
${GCCEXTRACFG}"

	    [ ! -z "${GCCCPU}"  ]     && coptions_gccX+=" --with-cpu=${GCCCPU}"
	    [ ! -z "${GCCARCH}" ]     && coptions_gccX+=" --with-arch=${GCCARCH}"

	    if [ ${CB_MINGW} -eq 1 ]; then
		coptions_gccX+=" --with-build-time-tools=${BPREFIX}/bin"
	    fi

	    coptions_gcc1="${coptions_gccX} \
--without-headers \
--with-newlib \
--disable-threads \
--enable-languages=c"

	    coptions_gcc2="${coptions_gccX} \
--with-sysroot=${SPREFIX} \
--with-threads=posix \
--enable-shared \
--enable-languages=c"

	    coptions_gcc3="${coptions_gccX} \
--enable-languages=${LANGUAGES} \
--with-sysroot=${SPREFIX} \
--enable-__cxa_atexit \
--enable-clocale=gnu \
--enable-shared \
--enable-threads=posix"

	    coptions_eglibc="--enable-add-ons \
--disable-profile \
--prefix=/usr \
--host=${TARGET} \
--build=${BUILD} \
--without-cvs \
--with-headers=${SPREFIX}/usr/include"

	    if [ ${TLS} -eq 0 ]; then
		coptions_eglibc+=" --without-tls"
		coptions_gcc1+=" --disable-tls"
		coptions_gcc2+=" --disable-tls"
		coptions_gcc3+=" --disable-tls"
	    else
		coptions_eglibc+=" --with-tls"
		coptions_gcc2+=" --enable-tls"
		coptions_gcc3+=" --enable-tls"
	    fi

	    if [ ${CB_MINGW} -eq 0 ]; then

	    # =========================================================
		head "build-gcc-eglibc: first gcc"
		echo "${coptions_gcc1}" >> ${LOG}

		"${SRCDIR}"/${GCC}/configure ${coptions_gcc1} >> "${LOG}" 2>&1 || error

		make ${JOBS} all-gcc >> "${LOG}" 2>&1 || error
		make install-gcc >> "${LOG}" 2>&1 || error
		foot

	    # =========================================================
		head "build-gcc-eglibc: install linux headers"
		if [ "${LINUX_IS_TARBALL}" == "1" ]; then
		    cd ${SRCDIR}/${LINUX}
		else
		    cd ${BASEPATH}/../${LINUX}
		fi
		make headers_install \
		    ARCH=${ARCH} \
		    CROSS_COMPILE=${TARGET}- \
		    INSTALL_HDR_PATH=${SPREFIX}/usr  >> "${LOG}" 2>&1 || error
		cd - &>/dev/null
		foot

	    # =========================================================
		head "build-gcc-eglibc: first eglibc (install headers)"

		# Force linking to libgcc_s
		pushd "${SRCDIR}"/${EGLIBC} &>/dev/null
		sed -i.orig -e 's/libc.so-gnulib := -lgcc$/libc.so-gnulib := -lgcc -lgcc_s$(libgcc_s_suffix)/' Makeconfig

		# Moving localdef
		mv localedef ../localdef-${EGLIBC##*-}
		popd &>/dev/null

		mkdir -p "${OBJDIR}"/${EGLIBC}-${BUILDSUFFIX}-1
		cd "${OBJDIR}"/${EGLIBC}-${BUILDSUFFIX}-1

		BUILD_CC=${BUILD}-gcc \
		    CC=${TARGET}-gcc \
		    CXX=${TARGET}-g++ \
		    AR=${TARGET}-ar \
		    RANLIB=${TARGET}-ranlib \
		    CFLAGS=-O2 \
		    "${SRCDIR}"/${EGLIBC}/configure ${coptions_eglibc} >> "${LOG}" 2>&1 || error

		make install-headers \
		    install_root=${SPREFIX} \
		    install-bootstrap-headers=yes >> "${LOG}" 2>&1 || error

		foot

	    # =========================================================
		head "build-gcc-eglibc: eglibc dummy libraries"
		mkdir -p ${SPREFIX}/usr/lib
		make ${JOBS} csu/subdir_lib >> "${LOG}" 2>&1 || error
		cp csu/crt1.o csu/crti.o csu/crtn.o ${SPREFIX}/usr/lib

		# Create Dummy libc
		${TARGET}-gcc -nostdlib -nostartfiles -shared \
		    -x c /dev/null \
		    -o ${SPREFIX}/usr/lib/libc.so
		foot

	    # =========================================================
		head "build-gcc-eglibc: second gcc"
		echo "${coptions_gcc2}" >> ${LOG}

		mkdir -p "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-2
		cd "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-2

		"${SRCDIR}"/${GCC}/configure ${coptions_gcc2} >> "${LOG}" 2>&1 || error

		make ${JOBS} >> "${LOG}" 2>&1 || error
		make install >> "${LOG}" 2>&1 || error

		mkdir -p "${SPREFIX}"/lib
		cp -d "${PREFIX}/${TARGET}"/lib/libgcc_s.so*  "${SPREFIX}"/lib

		foot

	    # =========================================================
		head "build-gcc-eglibc: second and final eglibc"
		mkdir -p "${OBJDIR}"/${EGLIBC}-${BUILDSUFFIX}-2
		cd "${OBJDIR}"/${EGLIBC}-${BUILDSUFFIX}-2

		BUILD_CC=${BUILD}-gcc \
		    CC=${TARGET}-gcc \
		    CXX=${TARGET}-g++ \
		    AR=${TARGET}-ar \
		    RANLIB=${TARGET}-ranlib \
		    CFLAGS="-mcpu=${GCCCPU} -O2" \
		    "${SRCDIR}"/${EGLIBC}/configure ${coptions_eglibc} >> "${LOG}" 2>&1 || error

		make ${JOBS} >> "${LOG}" 2>&1 || error
		make install install_root=${SPREFIX} >> "${LOG}" 2>&1 || error
		foot

	    # =========================================================
		head "build-gcc-eglibc: third and final gcc"
		echo "${coptions_gcc3}" >> ${LOG}

		mkdir -p "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-3
		cd "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-3

		"${SRCDIR}"/${GCC}/configure ${coptions_gcc3} >> "${LOG}" 2>&1 || error

		make ${JOBS} >> "${LOG}" 2>&1 || error
		make install >> "${LOG}" 2>&1 || error

		mkdir -p "${SPREFIX}"/lib
		cp -d "${PREFIX}/${TARGET}"/lib/libgcc_s.so*  "${SPREFIX}"/lib
		cp -d "${PREFIX}/${TARGET}"/lib/libstdc++.so* "${SPREFIX}"/usr/lib

	    else
	    # =========================================================
		head "build-gcc-eglibc: gcc for mingw"
		echo "${coptions_gcc3}" >> ${LOG}

		mkdir -p "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-3
		cd "${OBJDIR}"/${GCC}-${BUILDSUFFIX}-3

		# copy prebuilt sysroot
		cp -Rf ${BPREFIX}/* ${PREFIX}/

		"${SRCDIR}"/${GCC}/configure ${coptions_gcc3} >> "${LOG}" 2>&1 || error

		make ${JOBS} all-gcc >> "${LOG}" 2>&1 || error
		make install-gcc     >> "${LOG}" 2>&1 || error

		# remove build executables keep windows one only
		for i in $(find ${PREFIX} -name '*.exe'); do
		    rm -f ${i%.exe}
		done
	    fi

	    if [ "${PREFIX}" != "${PREFIX}" ]; then
		find "${OBJDIR}"/${GCC}-${BUILDSUFFIX} \
		    -name ${TARGET}-${GCC} \
		    -exec cp -rf \{\} "${PREFIX}/.." \;
		find "/${PREFIX}/.." \
		    -name ${TARGET}-${GCC} \
		    -exec cp -rf \{\} "${PREFIX}/.." \;
	    fi
	    foot
	fi

	popd &>/dev/null

    else
	echo "build-gcc-eglibc: not built"
    fi
    foot
}

# = GDB ===============================================================
function build-expat() {
    head "build-expat"


    if [ ! -z ${EXPAT} ]; then

	download http://freefr.dl.sourceforge.net/project/expat/expat/${EXPAT/expat-/}/${EXPAT}.tar.gz

	pushd . &>/dev/null

	if [ ! -d ${SRCDIR}/${EXPAT} ]; then
	    untar ${PKGDIR}/${EXPAT}.tar.* || exit 1
	    apatch ${SRCDIR}/${EXPAT} "$@"
	fi

	if [ ! -d "${OBJDIR}"/${EXPAT}-${BUILDSUFFIX} ]; then
	    mkdir -p "${OBJDIR}"/${EXPAT}-${BUILDSUFFIX}
	    cd "${OBJDIR}"/${EXPAT}-${BUILDSUFFIX}


	    coptions="-v \
--prefix=${PREFIX} \
--host=${HOST} \
--disable-shared"

	    "${SRCDIR}"/${EXPAT}/configure ${coptions} >> "${LOG}" 2>&1 || error
	    make ${JOBS} install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=  >> "${LOG}" 2>&1 || error
	fi

	popd &>/dev/null
    else
	echo "build-expat: not built"
    fi
    foot
}


# = GDB ===============================================================
function build-gdb() {
    head "build-gdb"

    if [ ! -z ${GDB} ]; then

	download http://ftp.gnu.org/gnu/gdb/${GDB}.tar.bz2

	pushd . &>/dev/null

	if [ ! -d ${SRCDIR}/${GDB} ]; then
	    untar ${PKGDIR}/${GDB}.tar.* || exit 1
	    apatch ${SRCDIR}/${GDB} "$@"
	fi

	if [ ! -d "${OBJDIR}"/${GDB}-${BUILDSUFFIX} ]; then
	    mkdir -p "${OBJDIR}"/${GDB}-${BUILDSUFFIX}
	    cd "${OBJDIR}"/${GDB}-${BUILDSUFFIX}


	    coptions="-v \
--with-pkgversion=${TARGET}-${VERSION} \
--prefix=${PREFIX} \
--target=${TARGET} \
--host=${HOST} \
--build=${BUILD} \
--disable-nls \
--with-libexpat-prefix=${PREFIX}
${MULTILIB}"

	    [ ${GDBPYTHON} -eq 1 ] && coptions+=" --with-python"
	    [ ! -z ${SUFFIX} ]     && coptions+=" --program-prefix=${TARGET}${SUFFIX}-"

	    "${SRCDIR}"/${GDB}/configure ${coptions} >> "${LOG}" 2>&1 || error

	    make ${JOBS} all >> "${LOG}" 2>&1 || error
	    make install     >> "${LOG}" 2>&1 || error
	fi

	popd &>/dev/null
    else
	echo "build-gdb: not built"
    fi
    foot
}

# =====================================================================
function build-setup() {

    [ -z "${INSTALLDIR}" ] && INSTALLDIR="C:\\\\x-tools"
    [ -z "${DATE}"       ] && DATE=$(date +%Y)
    [ -z "${COMPANY}"    ] && COMPANY="none"
    [ -z "${NSIS_SETUP}" ] && NSIS_SETUP="${PKGDIR}/../builds/${HOST}/${TARGET}-${VERSION}_setup.exe"
    PVERSION=$(echo ${GCC##*-} | awk -F'[.-]' '{print $1 "." $2 }').$(date +%y.%m)
    head "build-setup"

    if [ ! -d "${OBJDIR}/build-setup" ]; then
	pushd . &> /dev/null

	mkdir -p "${OBJDIR}"/build-setup
	cd "${OBJDIR}"/build-setup
	cp -f ${PKGDIR}/*.nsh .
	sed -e "s~@VERSION@~${VERSION}~g" \
	    -e "s~@PVERSION@~${PVERSION}~g" \
	    -e "s~@TARGET@~${TARGET}~g" \
	    -e "s~@INSTALLDIR@~${INSTALLDIR}~g" \
	    -e "s~@COMPANY@~${COMPANY}~g" \
	    -e "s~@YEAR@~$(date +%Y)~g" \
	    -e "s~@PREFIX@~${PREFIX}~g" \
	    -e "s~@NSIS_SETUP@~${NSIS_SETUP}~g" \
	    ${PKGDIR}/build-setup.nsi.in \
	    > build-setup.nsi
	mkdir -p $(dirname ${NSIS_SETUP})
	makensis build-setup.nsi >> "${LOG}" 2>&1 || error
	popd &>/dev/null
    fi
    foot
}

function replace-srcdirs-by-pkgs() {
    head "Replacing sources by tarballs"
    for i in "${SRCDIR}/"*; do
	if [ -d "$i" ]; then
	    cp "${PKGDIR}/$(basename $i)".tar.* "${SRCDIR}" && rm -rf "$i"
	fi
    done
    foot
}

function remove-srcdirs() {
    head "Removing sources directory (patch kept)"
    for i in "${SRCDIR}/"*; do
	if [ -d "$i" ]; then
	    rm -rf "$i"
	fi
    done
    foot
}

function cleaninfo() {
    cat <<EOF
You can now remove the build log file:
 rm -f ${LOG}

And remove build dirs:
 rm -rf ${OBJDIR}
EOF
    if [ ${CB_MINGW} -eq 1 ]; then
	echo "rm -rf ${PREFIX}"
    fi
}
