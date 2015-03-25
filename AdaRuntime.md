# Ada Runtime #

Ada Zero Foot Print runtimes are built for each gcc multilib.

## Build ##

RTS are automatically built by projects or can be built manually:
```
cd yaxde/rts
TARGET=arm-none-eabi make
```


Build process copy the following ada files from GCC installation:
  * ada.ads
  * a-unccon.ads
  * a-uncdea.ads
  * gnat.ads
  * g-souinf.ads
  * interfac.ads
  * s-maccod.ads
  * g-io.adb
  * s-atacco.adb
  * s-stoele.adb

The only file that must be adapted for each target is system.ads.

For the moment only ARM generic one is available in
```
rts/src/arm-none-eabi/common/system.ads
```



## Restrictions ##


### Restrictions pragma ###
```

--  ZFP Restrictions
pragma Restrictions (No_Exception_Propagation);
pragma Restrictions (No_Exception_Registration);
pragma Restrictions (No_Implicit_Dynamic_Code);
pragma Restrictions (No_Finalization);
pragma Restrictions (No_Tasking);
pragma Discard_Names;

--  Other Restrictions
pragma Restrictions (No_Secondary_Stack);
```

### Availlable system units ###
  * Ada
  * GNAT
  * GNAT.IO
  * GNAT.Source\_Info
  * Interfaces
  * System
  * System.Address\_To\_Access\_Conversions
  * System.Machine\_Code
  * System.Storage\_Elements


## GNAT.IO ##

To use gnat IO the following functions must be defined:
```
int get_int(void);
char get_char(void);
void put_char(char c);
void put_char_stderr(char c);
void put_int(int i);
void put_int_stderr(int i);
```

## Exceptions ##

System Exceptions could be catched by gnat\_last\_chance\_handler.
```
void __gnat_last_chance_handler (char *source, int line);
```

with:
**source is a null terminated C string.** line is the line number.

It must be defined by the user or by the board files.

If not implemented it is "week defined" to _halt in start.S._


## RTS ##

Built rts are available in yaxde/rts

### arm-none-eabi ###

for ARM the following RTS are built:
  * rts-arm-none-eabi\_armv6s-m
  * rts-arm-none-eabi\_armv7-a\_hard
  * rts-arm-none-eabi\_armv7-a\_soft
  * rts-arm-none-eabi\_armv7-a\_softfp
  * rts-arm-none-eabi\_armv7e-m\_hard
  * rts-arm-none-eabi\_armv7e-m\_soft
  * rts-arm-none-eabi\_armv7e-m\_softfp
  * rts-arm-none-eabi\_armv7\_hard
  * rts-arm-none-eabi\_armv7-m
  * rts-arm-none-eabi\_armv7\_soft
  * rts-arm-none-eabi\_armv7\_softfp

It depends on multilibs provided with current ToolchainInstallation

For each RTS a config.mk is also generated.
For example rts-arm-none-eabi\_armv7-a\_hard/config.mk contains:
```
CFLAGS   = -ffunction-sections -fdata-sections -Wl,--gc-sections -nostdinc -nostdlib -mthumb -march=armv7-a -mfloat-abi=hard -mfpu=neon
ADAFLAGS = -gnata -gnato -gnaty -gnat2012
TARGET   = arm-none-eabi
```


