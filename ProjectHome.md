# yaxde #
**yet another x-dev environment** is a simple cross-dev environment for bare board systems

## Features ##
  * Targets bare-board lightweight applications.
  * [Easy to use](GettingStarted.md).
  * Runs on Linux and MinGW (Mac might also work but not tested).
  * [Ada](AdaRuntime.md), C++, C and Assembly supported.
  * [GNU based toolchain](ToolchainInstallation.md).
  * [Modified BSD License](ProjectLicense.md).
  * Provides scripts and patches for cross-gcc generation (with Ada support).

Note that the project is still in dev, build environment and toolchains are usable but [BSP](SupportedBoards.md) are not yet very advanced.

## Toolchain ##
  * targets : arm-none-eabi (with multilibs), m68k-none-elf, powerpc-none-eabi
  * hosts : x86\_64-linux-gnu, i686-pc-mingw32 (linux32 should also work)
  * gcc 4.8.3
  * binutils 2.24
  * newlib 2.1.0
  * newlib-nano-2 9312658e6a71651bf4fb9c4b5ee06ed2356bd14a
  * gdb 7.7.1

## Tools ##
  * dfu-util fc81c6cc4eba30eaadf0010deb3d38f3be93ecd1
  * stlink cc2688ec5af87792424dd2f3430216c879d796e8
  * openocd 0.8.0 (built interfaces : ftdi, usb\_blaster, usbprog, openjtag, jlink, vsllink, rlink, ulink, arm-jtag-ew, hla (stlink-v1 stlink-v2 ti-icdi), osbdm,  opendous, aice, cmsis-dap)
  * urjtag 20140603
  * qemu-2.0.0 (only on linux)

## ARM multilibs ##
  * armv7-ar/arm/;@marm@march=armv7-a@mthumb-interwork
  * armv7-ar/arm/softfp;@marm@march=armv7-a@mfloat-abi=softfp@mfpu=vfpv3-d16@mthumb-interwork
  * armv7-ar/arm/fpu;@marm@march=armv7-a@mfloat-abi=hard@mfpu=vfpv3-d16@mthumb-interwork
  * armv6s-m;@mthumb@march=armv6s-m
  * armv7-m;@mthumb@march=armv7-m
  * armv7e-m;@mthumb@march=armv7e-m
  * armv7-ar/thumb/;@mthumb@march=armv7-a
  * armv7e-m/softfp;@mthumb@march=armv7e-m@mfloat-abi=softfp@mfpu=fpv4-sp-d16
  * armv7e-m/fpu;@mthumb@march=armv7e-m@mfloat-abi=hard@mfpu=fpv4-sp-d16
  * armv7-ar/thumb/softfp;@mthumb@march=armv7-a@mfloat-abi=softfp@mfpu=vfpv3-d16
  * armv7-ar/thumb/fpu;@mthumb@march=armv7-a@mfloat-abi=hard@mfpu=vfpv3-d16

<a href='https://plus.google.com/116322524897727490428'>Google+</a>