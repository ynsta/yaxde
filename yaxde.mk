# -*- makefile-gmake -*-
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

targets		:= arm-none-eabi qemu stlink

ada_projects	:= $(notdir $(dir $(wildcard programs/*/program.adb)))
ada_boards	:= $(notdir $(wildcard boards/ada-*))

all_projects	:= $(notdir $(wildcard programs/*))
all_boards	:= $(notdir $(wildcard boards/*))

oth_projects	:= $(filter-out $(ada_projects), $(all_projects))
oth_board	:= $(filter-out $(ada_board), $(all_board))

build_lst	:= \
	$(foreach b,$(ada_boards),$(addprefix build~$(b)~,$(ada_projects))) \
	$(foreach b,$(all_boards),$(addprefix build~$(b)~,$(oth_projects)))

clean_lst	:= \
	$(foreach b,$(ada_boards),$(addprefix clean~$(b)~,$(ada_projects))) \
	$(foreach b,$(all_boards),$(addprefix clean~$(b)~,$(oth_projects)))

distclean_lst	:= \
	$(foreach b,$(ada_boards),$(addprefix distclean~$(b)~,$(ada_projects))) \
	$(foreach b,$(all_boards),$(addprefix distclean~$(b)~,$(oth_projects)))

space		:=
space		+=

all: $(build_lst)

clean: $(clean_lst)

distclean: $(distclean_lst)

$(build_lst):
	$(eval prj := $(word 3,$(subst ~,$(space),$@)))
	$(eval brd := $(word 2,$(subst ~,$(space),$@)))
	$(MAKE) -C . P=$(prj) B=$(brd)

$(clean_lst):
	$(eval prj := $(word 3,$(subst ~,$(space),$@)))
	$(eval brd := $(word 2,$(subst ~,$(space),$@)))
	$(MAKE) -C . P=$(prj) B=$(brd) clean

$(distclean_lst):
	$(eval prj := $(word 3,$(subst ~,$(space),$@)))
	$(eval brd := $(word 2,$(subst ~,$(space),$@)))
	$(MAKE) -C . P=$(prj) B=$(brd) distclean

install-deps:
	$(MAKE) -C toolchain deps

install-toolchain:
	BASEPATH=$(toolchain) TARGETS=$(targets) $(MAKE) -C toolchain host

.PHONY: all clean distclean $(build_lst) $(clean_lst) $(distclean_lst)
