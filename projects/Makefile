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
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# =====================================================================
# Params
# make P=program B=board
#

# =====================================================================
# Defines

cdir		= $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

space		:=
space		+=

progs		:= $(notdir $(wildcard programs/*))
boards		:= $(notdir $(wildcard boards/*))

ifndef P
$(error specify program to build with P=[$(progs)])
endif

ifndef B
$(error specify board with B=[$(boards)])
endif

build_dir	:= builds/$(P)/$(B)
program		:= $(build_dir)/$(P)

# Include board configuration
include boards/$(B)/config.mk


ada_libs	:= $(foreach l,$(LIBS),$(wildcard libs/$(l)/ada))


libada		:= $(build_dir)/libada.a

ADA_INCLUDE_PATH:= programs/$(P):boards/$(B):$(subst $(space),:,$(ada_libs))

export ADA_INCLUDE_PATH

ada_paths	:= $(subst :,$(space),$(ADA_INCLUDE_PATH))
ada_specs	:= $(foreach d,$(ada_paths),$(wildcard $(d)/*.ads))
ada_bodys	:= $(foreach d,$(ada_paths),$(wildcard $(d)/*.adb))

ada_objects	:= $(sort \
	$(addprefix $(build_dir)/,$(notdir $(ada_bodys:.adb=.o))) \
	$(addprefix $(build_dir)/,$(notdir $(ada_specs:.ads=.o))))


ifneq ($(strip $(ada_objects)),)
ADA_BUILD	:= 1
  ifeq ($(strip $(rts)),)
    $(error "RTS must be defined in board to build with Ada support")
  endif
endif

c_libs		:= $(foreach l,$(LIBS),$(wildcard libs/$(l)/c))
cc_libs		:= $(foreach l,$(LIBS),$(wildcard libs/$(l)/cc))
asm_libs	:= $(foreach l,$(LIBS),$(wildcard libs/$(l)/asm))


# VPATH
vpath %.S   programs/$(P):boards/$(B):$(subst $(space),:,$(asm_libs))
vpath %.c   programs/$(P):boards/$(B):$(subst $(space),:,$(c_libs))
vpath %.cc  programs/$(P):boards/$(B):$(subst $(space),:,$(cc_libs))
vpath %.cpp programs/$(P):boards/$(B):$(subst $(space),:,$(cc_libs))


sources		:= $(foreach pat,*.S *.c *.cc *.cpp,$(wildcard programs/$(P)/$(pat)))
sources		+= $(foreach pat,*.S *.c *.cc *.cpp,$(wildcard boards/$(B)/$(pat)))
sources		+= $(foreach l,$(c_libs),$(l)/*.c)
sources		+= $(foreach l,$(cc_libs),$(l)/*.cc)
sources		+= $(foreach l,$(cc_libs),$(l)/*.cpp)
sources		+= $(foreach l,$(asm_libs),$(l)/*.S)

objects__	:= $(filter %.o, $(sources:.c=.o) $(sources:.S=.o) $(sources:.cc=.o) $(sources:.cpp=.o))
objects_	:= $(sort $(addprefix $(build_dir)/,$(notdir $(objects__))))
objects		:= $(filter-out $(brd_reqs),$(objects_))

c_includes	:= $(addprefix -I, programs/$(P) boards/$(B) $(c_libs) $(asm_libs))
cc_includes	:= $(c_includes) $(addprefix -I, $(cc_libs))

CXXFLAGS	:= $(CFLAGS) -g $(cc_includes)
CFLAGS		+= -g $(c_includes)

LDFLAGS		:= -nostartfiles -nodefaultlibs -nostdlib \
-Wl,-T$(ldfile) -Wl,-Map -Wl,$(program).map -Wl,--cref -Wl,--gc-sections

# Include program configuration
-include programs/$(P)/config.mk


# =====================================================================
# Rules

all: $(program) | $(build_dir)

$(program).bin: $(program) | $(build_dir)
	@echo "[COPY]	$@"
	@$(target)-objcopy -O binary $< $@

$(program): $(brd_reqs) $(objects) $(libada) | $(build_dir)
	@echo "[LINK]	$@"
	@$(target)-g++ $(LDFLAGS) $^ -o $(program)


$(build_dir)/%.o: %.S | $(build_dir)
	@echo "[AS]	$<"
	@$(target)-gcc $(CFLAGS) -c $< -o $@

$(build_dir)/%.o: %.c | $(build_dir)
	@echo "[CC]	$<"
	@$(target)-gcc $(CFLAGS) -c $< -o $@

$(build_dir)/%.o: %.cc | $(build_dir)
	@echo "[C++]	$<"
	@$(target)-g++ $(CXXFLAGS) -c $< -o $@

$(build_dir)/%.o: %.cpp | $(build_dir)
	@echo "[C++]	$<"
	@$(target)-g++ $(CXXFLAGS) -c $< -o $@


ifdef ADA_BUILD

$(libada): $(build_dir)/ada.o $(ada_objects) | $(build_dir)
	@echo "[AR]	$@"
	@$(target)-ar cr $@ $^

$(build_dir)/ada.o: $(build_dir)/ada.adb | $(build_dir)
	@echo "[AC]	$^"
	@$(target)-gcc $(RTS) $(CFLAGS) -c $< -o $@

$(build_dir)/ada.adb: $(ada_objects) | $(build_dir)
	@echo "[BIND]	$@"
	@cd $(build_dir); $(target)-gnatbind $(RTS) -n $(notdir $(ada_objects:.o=)) -o $(@F)

define compile_ada
$(1): $(filter %/$(strip $(2)).adb, $(ada_bodys)) $(filter %/$(strip $(2)).ads, $(ada_specs)) | $$(build_dir)
	@echo "[AC]	$$^"
	@$$(target)-gcc $$(RTS) $$(CFLAGS) $$(ADAFLAGS) -c $$< -o $$@
endef

$(foreach a,$(ada_objects),$(eval $(call compile_ada, $(a), $(notdir $(a:.o=)))))
endif # ADA_BUILD


# Include bord specific rules
include boards/$(B)/rules.mk

gdb:: $(program)
	@$(target)-gdb -ex "target remote localhost:1234" $(program)

xgdb::
	@xterm -T "gdb $(program)" -e $(target)-gdb -ex "target remote localhost:1234" $(program)

egdb::
	@emacs --eval '(gdb "$(target)-gdb -ex \"target remote localhost:1234\" --annotate=3 $(program)")'


clean:: board_clean
	@rm -f $(objects) $(libada) $(build_dir)/ada.o $(build_dir)/ada.ali  $(ada_objects) $(ada_objects:.o=.ali)

distclean:: board_distclean  clean
	@rm -rf $(build_dir)

$(build_dir):
	@mkdir -p $(build_dir)


# Include program rules.mk
-include programs/$(P)/rules.mk


.PHONY: all clean distclean adaobjects
