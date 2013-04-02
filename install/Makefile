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

# set TARGETS to build
ifeq ($(TARGETS),)
targets		:= mxe arm-none-eabi m68k-none-elf powerpc-none-eabi stlink qemu
else
targets		:= $(TARGETS)
endif

build		:= $(shell /usr/bin/gcc -dumpmachine 2>/dev/null || gcc -dumpmachine 2>/dev/null)

# filter-out targets not buildable for mingw
mtargets	:= $(filter-out mxe stlink qemu, $(targets))

# set VERSION
ifeq ($(VERSION),)
export VERSION	:= 4.8-$(shell date +%Y.%m)
endif

# set BASEPATH
ifeq ($(BASEPATH),)
export BASEPATH	:= /opt/x-tools
endif
export WBASEPATH:= /c/x-tools

# unset PREFIX if defined as it might cause problems to underlying scripts
ifneq ($(PREFIX),)
export PREFIX:=
endif

distrib		:= $(shell python -c 'import platform; print "-".join(platform.dist()[0:2] + (platform.machine(), )).lower()')

space		:=
space		+=

vbase		:= $(word 1,$(subst -,$(space),$(VERSION)))

builds		:= $(foreach t,$(targets),$(BASEPATH)/$(t)-$(VERSION))

mingwt		:= i686-pc-mingw32
mingws		:= $(foreach t,$(mtargets),builds/$(mingwt)/$(t)-$(VERSION)_setup.exe)

tarballs	:= builds/$(distrib)/$(build)-$(VERSION).tar.bz2
tarballs	+= $(foreach t,$(targets),builds/$(distrib)/$(t)-$(VERSION).tar.bz2)

toclean		:= $(foreach t,$(targets),/tmp/build-$(t)-$(vbase).log)
toclean		+= $(foreach t,$(targets),build-$(t)-$(vbase))
toclean		+= $(foreach t,$(targets),build-$(t)-$(vbase)-mingw)
toclean		+= $(foreach t,$(targets),$(WBASEPATH)/$(t)-$(VERSION))

touninstall	:= $(builds)
touninstall	+= $(BASEPATH)/mxe
touninstall	+= $(BASEPATH)/$(build)-$(VERSION)



define HELP
Rules:

  all       : build host, mingw and tarballs for selected targets
  deps      : install all required deps (must be run a root)
  host      : build only host programs
  mingw     : build only mingw setups
  tarballs  : create tarballs of built packages in builds/$(distrib)
  install   : install prebuilt tarballs
  uninstall : remove installed packages
  clean     : remove temporary objects
  help      : display this help

Options:

  Options are environment variables passed to make (OPTION=value make)

  BASEPATH  : could be set to define the base installation DIR toolchains will
              be installed in $(BASEPATH)/TARGET-$(VERSION) for each TARGETS in
              [$(targets)]

  VERSION   : version of the toolchain default is $(VERSION)

  TARGETS   : target to build in [$(targets)]

endef



all: host mingw tarballs

host: $(builds)

mingw: $(mingws)

tarballs: $(tarballs)


deps:
	@scripts/install-deps.sh



.SECONDEXPANSION:

$(builds): scripts/build-$$(subst -$(VERSION),,$$(@F))-$(vbase).sh
	$(eval target := $(subst -$(VERSION),,$(@F)))
	@echo "======================================================================="
	@echo "= TARGET: $@"
	@echo "======================================================================="
	@test -d $@ && echo "$@ exists, remove it to rebuild" || \
	($< \
	&& rm -rf     build-$(target)-$(vbase) \
	&& rm -f /tmp/build-$(target)-$(vbase).log)
	@echo ""


$(mingws): scripts/build-$$(subst -$(VERSION)_setup.exe,,$$(@F))-$(vbase)-mingw.sh \
	   $(BASEPATH)/$$(subst _setup.exe,,$$(@F))
	$(eval target := $(subst -$(VERSION)_setup.exe,,$(@F)))
	@echo "======================================================================="
	@echo "= TARGET: $@"
	@echo "======================================================================="
	@$< \
	&& rm -rf $(WBASEPATH)/$(target)-$(VERSION) \
	&& rm -rf build-$(target)-$(vbase)-mingw
	@mkdir -p $(@D)
	@echo ""

$(tarballs): $(BASEPATH)/$$(subst .tar.bz2,,$$(@F))
	$(eval tar := $(abspath $@))
	@echo "======================================================================="
	@echo "= TARGET: $@"
	@echo "======================================================================="
	@mkdir -p $(@D)
	@echo -n "Archiving $^ "
	@cd $(BASEPATH); tar -cjf $(tar) $(<F) 2>/dev/null
	@echo "Done"
	@echo ""

clean:
	@rm -rf $(toclean)

uninstall:
	@rm -rf $(touninstall)

install:
	@mkdir -p $(BASEPATH)
	@for i in $(tarballs); do \
	  echo -n "Extracting $$i ";\
	  tar xf $$i -C $(BASEPATH);\
	  echo "Done";\
	done


export HELP
help:
	@echo "$$HELP"

.PHONY: all deps host mingw tarballs clean uninstall install help
