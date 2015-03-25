# Getting Started with yaxde #

## Get Sources ##

Get sources with git
```
git clone https://code.google.com/p/yaxde
```

**Directory tree:**
  * `yaxde/toolchain`: Makefile and scripts to build and install x-toolchains.
  * `yaxde/boards`: default base path for boards files (start, bsp, ...).
  * `yaxde/libraries`: default base path for libraries.
  * `yaxde/programs`: default base path for user programs.
  * `yaxde/rts`: [ZFP Ada runtimes](AdaRuntime.md) sources and build Makefile.

## Toolchain ##

Install Toolchain as described [here](ToolchainInstallation.md).



## Test ##

**Build all provided examples for all provided boards:**
```
make -f yaxde.mak
```

**Test with qemu:**
```
make B=ada-qemu-lm3s6965evb P=ada-raise xqemu egdb
```
Then in emacs gdb:
```
(gdb) load
Loading section .isr_vectors, size 0x400 lma 0x0
Loading section .text, size 0x1d8 lma 0x400
Loading section .data, size 0x8 lma 0x5d8
Start address 0x401, load size 1504
Transfer rate: 12032 bits in <1 sec, 501 bytes/write.
(gdb) b __gnat_last_chance_handler
Breakpoint 1 at 0x466: file [...]/boards/ada-qemu-lm3s6965evb/glch.c, line 7.
(gdb) b _halt
Breakpoint 2 at 0x442: file [...]/boards/ada-qemu-lm3s6965evb/start.S, line 94.
(gdb) c
Continuing.

Breakpoint 1, __gnat_last_chance_handler (source_location=0x5cc "program.adb", line=22) at [...]/boards/ada-qemu-lm3s6965evb/glch.c:7
(gdb) c
Continuing.

Breakpoint 2, _isr_use_fault () at [...]/boards/ada-qemu-lm3s6965evb/start.S:94
(gdb)

```

qemu windows must display:
```
program.adb:22
```

_print\_int is not yet implemented so for the moment it only prints program.adb:_


