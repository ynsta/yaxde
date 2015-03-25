# How-to create a new program #

## Create from C++ Template ##
```
cd yaxde/programs
cp -rf cxx-empty myprogram
emacs myprogram/program.cc # replace emacs with your favorite editor
```

## Create from Ada Template ##
```
cd yaxde/programs
cp -rf ada-empty myprogram
emacs myprogram/program.adb # replace emacs with your favorite editor
```

## Compile ##

Use `make help` in yaxde top directory to display available boards and options

To build for an arm qemu cortex-m3 board:
```
make B=ada-qemu-lm3s6965evb P=myprogram
```

To test:
```
make xqemu egdb
```