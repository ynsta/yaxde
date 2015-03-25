# Toolchain Installation #

## Limitations ##
All toolchain build scripts are only tested with xubuntu 12.10.

## Targets ##
Supported targets are :
  * arm-none-eabi
  * powerpc-none-eabi
  * m68k-none-elf

## Build ##

Default build is

```
git clone https://code.google.com/p/yaxde
cd yaxde/toolchain
sudo make deps
make
```

It will install all tools in /opt/x-tools/

Tarballs and MinGW setups will be generated in yaxde/toolchain/builds/.

To build only host versions and tarballs:
```
make host tarballs
```

## PATH ##
After build you can add the toolchain in you PATH
edit your ~/.bashrc with your favorite editor and add the following lines :
```
function absdir() {
    for i; do
	python -c "import os; print os.path.abspath('$i')"
    done
}

function setenv() {
    for env ; do
	case "${env}" in
	    *)
		if [ -d "${env}" ]; then
		    env=$(absdir "$env")
		    for i in PATH:bin MANPATH:man INFOPATH:info LD_LIBRARY_PATH:lib LIBRARY_PATH:lib; do
			var=${i%:*}
			dir="${env}/${i#*:}"
			[ -d "${dir}" ] && eval export $var=\"${dir}:\${${var}}\"
		    done
		fi
		;;
	esac
    done
}

setenv /opt/x-tools/*
```


## Build Help ##

Toolchain install can be displayed with make help

```
cd yaxde/toolchain
make help
Rules:

  all       : build host, mingw and tarballs for selected targets
  deps      : install all required deps (must be run a root)
  host      : build only host programs
  mingw     : build only mingw setups
  tarballs  : create tarballs of built packages in builds/ubuntu-12.10-x86_64
  install   : install prebuilt tarballs
  uninstall : remove installed packages
  clean     : remove temporary objects
  help      : display this help

Options:

  Options are environment variables passed to make (OPTION=value make)

  BASEPATH  : could be set to define the base installation DIR toolchains will
              be installed in /opt/x-tools/TARGET-4.8-2013.04 for each TARGETS in
              [mxe arm-none-eabi m68k-none-elf powerpc-none-eabi stlink qemu]

  VERSION   : version of the toolchain default is 4.8-2013.04

  TARGETS   : target to build in [mxe arm-none-eabi m68k-none-elf powerpc-none-eabi stlink qemu]

```


