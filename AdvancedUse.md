# Advanced use #

## Top Makefile options ##
Top dir make help output on 04/03/2013:

```
cd yaxde
make help


= YAXDE Makefile help =

Required arguments:

  Arguments are variables passed to make (make ARG=value)

  P             : The program to build (found: ada-empty ada-raise cxx-empty)
  B             : The selected board (found: ada-qemu-lm3s6965evb ada-stm32f4)

Optional arguments:

  PROGRAMS_DIR  : base path of programs (current: /tmp/yaxde/programs)
  BOARDS_DIR    : base path of boards (current: /tmp/yaxde/boards)
  BUILD_DIR     : base path for build objects (current: /tmp/yaxde/builds)
  TOOLCHAIN     : base path of installed toolchain (current: /opt/x-tools)

Rules:

  all           : build program
  clean         : remove temporary objects
  distclean     : remove all generated files
  help          : display this help

  egdb          : run gdb in emacs
  xgdb          : run gdb in xterm
  gdb           : run gdb

```

to display sepcific board help the board must be selected:
```
make B=ada-qemu-lm3s6965evb help

= YAXDE Makefile help =

...

ada-qemu-lm3s6965evb board specific rules:
  xqemu         : run qemu in xterm
  qemu          : run qemu

```

