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
# Macro and usefull variables
# cdir is the current absolute directory (also usable in included makefiles)
cdir		= $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# space is a variable with one space
space		:=
space		+=

# =====================================================================
# Defines

boards_dir	:= $(or $(realpath $(BOARDS_DIR)), $(cdir)/boards)
programs_dir	:= $(or $(realpath $(PROGRAMS_DIR)), $(cdir)/programs)
BUILD_DIR	:= $(or $(realpath $(BUILD_DIR)), $(realpath $(programs_dir)/..)/builds)
build_dir	:= $(BUILD_DIR)/$(P)/$(B)
toolchain	:= $(or $(realpath $(TOOLCHAIN)), /opt/x-tools)

# Test if P and B exist
progr		:= $(and $(realpath $(programs_dir)/$(P)),$(P))
board		:= $(and $(realpath $(boards_dir)/$(B)),$(B))

define HELP

= YAXDE Makefile help =

Required arguments:

  Arguments are variables passed to make (make ARG=value)

  P             : The program to build (found: $(notdir $(wildcard $(programs_dir)/*)))
  B             : The selected board (found: $(notdir $(wildcard $(boards_dir)/*)))

Optional arguments:

  PROGRAMS_DIR  : base path of programs (current: $(programs_dir))
  BOARDS_DIR    : base path of boards (current: $(boards_dir))
  BUILD_DIR     : base path for build objects (current: $(BUILD_DIR))
  TOOLCHAIN     : base path of installed toolchain (current: $(toolchain))

Rules:

  all           : build program
  clean         : remove temporary objects
  distclean     : remove all generated files
  help          : display this help

  egdb          : run gdb in emacs
  xgdb          : run gdb in xterm
  gdb           : run gdb

endef


# Test if P not empty or give help with programs list
ifneq ($(strip $(board)),)

# Include board configuration
-include $(boards_dir)/$(board)/config.mk

ifneq ($(strip $(progr)),)

# Export PATH with toolchains first
export PATH	:= $(subst $(space),:,$(wildcard $(toolchain)/*/bin)):$(PATH)

program		:= $(build_dir)/$(progr)

ada_libs	:= $(foreach l,$(LIBS),$(wildcard libraries/$(l)/ada))

libada		:= $(build_dir)/libada.a

ADA_INCLUDE_PATH:= $(programs_dir)/$(progr):$(boards_dir)/$(board):$(subst $(space),:,$(ada_libs))

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

c_libs		:= $(foreach l,$(LIBS),$(wildcard libraries/$(l)/c))
cc_libs		:= $(foreach l,$(LIBS),$(wildcard libraries/$(l)/cc))
asm_libs	:= $(foreach l,$(LIBS),$(wildcard libraries/$(l)/asm))


# VPATH
vpath %.S   $(programs_dir)/$(progr):$(boards_dir)/$(board):$(subst $(space),:,$(asm_libs))
vpath %.c   $(programs_dir)/$(progr):$(boards_dir)/$(board):$(subst $(space),:,$(c_libs))
vpath %.cc  $(programs_dir)/$(progr):$(boards_dir)/$(board):$(subst $(space),:,$(cc_libs))
vpath %.cpp $(programs_dir)/$(progr):$(boards_dir)/$(board):$(subst $(space),:,$(cc_libs))


sources		:= $(foreach pat,*.S *.c *.cc *.cpp,$(wildcard $(programs_dir)/$(progr)/$(pat)))
sources		+= $(foreach pat,*.S *.c *.cc *.cpp,$(wildcard $(boards_dir)/$(board)/$(pat)))
sources		+= $(foreach l,$(c_libs),$(l)/*.c)
sources		+= $(foreach l,$(cc_libs),$(l)/*.cc)
sources		+= $(foreach l,$(cc_libs),$(l)/*.cpp)
sources		+= $(foreach l,$(asm_libs),$(l)/*.S)

objects__	:= $(filter %.o, $(sources:.c=.o) $(sources:.S=.o) $(sources:.cc=.o) $(sources:.cpp=.o))
objects_	:= $(sort $(addprefix $(build_dir)/,$(notdir $(objects__))))
objects		:= $(filter-out $(brd_reqs),$(objects_))

c_includes	:= $(addprefix -I, $(programs_dir)/$(progr) $(boards_dir)/$(board) $(c_libs) $(asm_libs))
cc_includes	:= $(c_includes) $(addprefix -I, $(cc_libs))

CXXFLAGS	:= $(CFLAGS) -g $(cc_includes)
CFLAGS		+= -g $(c_includes)

LDFLAGS		:= -nostartfiles -nodefaultlibs -nostdlib \
-Wl,-T$(ldfile) -Wl,-Map -Wl,$(program).map -Wl,--cref -Wl,--gc-sections

# Include program configuration
-include $(programs_dir)/$(progr)/config.mk


# =====================================================================
# Rules

all: $(program).bin | $(build_dir)


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
include $(boards_dir)/$(board)/rules.mk

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
-include $(programs_dir)/$(progr)/rules.mk

endif # -z progr
endif # -z board

export HELP
export BOARD_HELP
help:
	@echo "$$HELP"
	@echo "$$BOARD_HELP"


ifneq ($(B),$(board))
$(warning Board '$(B)' not found in $(boards_dir))
endif

ifneq ($(P),$(progr))
$(warning Program '$(P)' not found in $(programs_dir))
endif


.PHONY: all help clean distclean
