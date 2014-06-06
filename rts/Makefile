space :=
space +=

ifeq ($(strip $(TARGET)),)
$(error TARGET not defined)
endif

libname = libgnat.a

CC = $(TARGET)-gcc
AR = $(TARGET)-ar

mlibs:=$(shell $(CC) -print-multi-lib)
mlibs:=$(subst ;,:,$(mlibs))
mlibs_path:=$(filter-out .,$(foreach mlib,$(mlibs),$(word 1,$(subst :,$(space),$(mlib)))))
mlibs_path:=$(foreach path,$(mlibs_path),$(patsubst %/,%,$(path)))
libs=$(foreach path,$(mlibs_path),rts-$(subst /,_,$(TARGET)/$(path))/adalib/$(libname))
mks=$(foreach path,$(mlibs_path),rts-$(subst /,_,$(TARGET)/$(path))/config.mk)

sysadainclude := $(word 1,$(shell $(CC) --print-file-name=adainclude))

sysfiles := \
	ada.ads \
	ada-tags.adb \
	ada-tags.ads \
	a-unccon.ads \
	a-uncdea.ads \
	interfac.ads \
	s-stoele.adb \
	s-stoele.ads \
	s-maccod.ads \
	gnat.ads \
	g-souinf.ads \
	g-io.adb \
	g-io.ads \
	s-atacco.adb \
	s-atacco.ads

# FIXME i-c.* should be also usable in zfp but require a reimplementation without exceptions


sysfiles := $(foreach f,$(sysfiles),$(sysadainclude)/$(f))
adafiles := $(wildcard src/$(TARGET)/common/*.ad? src/common/*.ad?) $(sysfiles)

# TODO -fstack-check requires _gnat_stack_check
CFLAGS_B := -ffunction-sections -fdata-sections -Wl,--gc-sections -nostdinc -nostdlib
ADAFLAGS := -gnata -gnato -gnaty -gnat2012


all: $(libs)

$(mlibs_path):
	$(eval SRC    := $(wildcard src/$(TARGET)/$@/*.ad?) $(adafiles))
	$(eval RTS    := rts-$(subst /,_,$(TARGET)/$@))
	$(eval CFLAGS := $(strip $(CFLAGS_B) $(subst @,$(space)-,$(patsubst $@:%,%,$(filter $@:%, $(mlibs))))))
	@mkdir -p $(RTS)/adainclude $(RTS)/adalib $(RTS)/tmp src/$(TARGET)/$@
	@cp -f $(SRC) $(RTS)/tmp        2>/dev/null || true
	@cp -f $(SRC) $(RTS)/adainclude 2>/dev/null || true
	@echo "# -*- makefile-gmake -*-" >  $(RTS)/config.mk
	@echo "CFLAGS   = $(CFLAGS)"     >> $(RTS)/config.mk
	@echo "ADAFLAGS = $(ADAFLAGS)"   >> $(RTS)/config.mk
	@echo "TARGET   = $(TARGET)"     >> $(RTS)/config.mk

$(mks): $(mlibs_path)


$(libs): $(mlibs_path)
	$(eval RTS  := $(patsubst %/adalib/$(libname),%,$@))
	$(eval BODY := $(wildcard $(RTS)/tmp/*.adb))
	$(eval TEMP := $(BODY:.adb=.ads))
	$(eval SPEC := $(filter-out $(TEMP),$(wildcard $(RTS)/tmp/*.ads)))
	$(eval OBJS := $(SPEC:.ads=.o) $(BODY:.adb=.o))
	$(eval include $(RTS)/config.mk)
	@for i in $(SPEC) $(BODY); do \
	  echo "[AC]	$$i"; \
	  $(CC) $(CFLAGS) $(ADAFLAGS) -gnatg -gnatpg --RTS=$(RTS) -c $$i -o $${i%.*}.o; \
	done
	@echo "[AR]	$(RTS)/adalib/$(libname)"
	@$(AR) -rcs $(RTS)/adalib/$(libname) $(OBJS)
	@mv $(RTS)/tmp/*.ali $(RTS)/adalib
	@rm -rf $(RTS)/tmp
	@chmod -R a-w $(RTS)/adalib/* $(RTS)/adainclude/*

clean:
	@find . -name '*.o' -exec chmod +w {} +
	@find . -name '*.o' -exec rm -f {} +

distclean: clean
	@chmod -fR +w rts-* || true
	@rm -rf __fake__ rts-*

dbg:
	@echo $(mlibs_path)

.PHONY: all check distclean clean $(mlibs_path) $(libs)
