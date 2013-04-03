/*
 * Copyright (c) 2013, Stany MARCEL <stanypub@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
OUTPUT_FORMAT("elf32-littlearm")
ENTRY(_start)

MEMORY
{
  rom (xr)  : ORIGIN = 0x00000000, LENGTH = 256K
  ccm (xrw) : ORIGIN = 0x20000000, LENGTH = 64K
}

SECTIONS
{
  .isr_vectors :
  {
    LONG(__stack)
    LONG(_start)
    LONG(_isr_nmi)
    LONG(_isr_hard_fault)
    LONG(_isr_mm_fault)
    LONG(_isr_bus_fault)
    LONG(_isr_use_fault)
    LONG(0)
    LONG(0)
    LONG(0)
    LONG(0)
    LONG(_isr_svcall)
    LONG(_isr_debug)
    LONG(0)
    LONG(_isr_pend_sv)
    LONG(_isr_sys_tick)
    LONG(_isr_irq0)
    LONG(_isr_irq1)
    LONG(_isr_irq2)
    LONG(_isr_irq3)
    LONG(_isr_irq4)
    LONG(_isr_irq5)
    LONG(_isr_irq6)
    LONG(_isr_irq7)
    LONG(_isr_irq8)
    LONG(_isr_irq9)
    LONG(_isr_irq10)
    LONG(_isr_irq11)
    LONG(_isr_irq12)
    LONG(_isr_irq13)
    LONG(_isr_irq14)
    LONG(_isr_irq15)
    LONG(_isr_irq16)
    LONG(_isr_irq17)
    LONG(_isr_irq18)
    LONG(_isr_irq19)
    LONG(_isr_irq20)
    LONG(_isr_irq21)
    LONG(_isr_irq22)
    LONG(_isr_irq23)
    LONG(_isr_irq24)
    LONG(_isr_irq25)
    LONG(_isr_irq26)
    LONG(_isr_irq27)
    LONG(_isr_irq28)
    LONG(_isr_irq29)
    LONG(_isr_irq30)
    LONG(_isr_irq31)
    LONG(_isr_irq32)
    LONG(_isr_irq33)
    LONG(_isr_irq34)
    LONG(_isr_irq35)
    LONG(_isr_irq36)
    LONG(_isr_irq37)
    LONG(_isr_irq38)
    LONG(_isr_irq39)
    LONG(_isr_irq40)
    LONG(_isr_irq41)
    LONG(_isr_irq42)
    LONG(_isr_irq43)
    LONG(_isr_irq44)
    LONG(_isr_irq45)
    LONG(_isr_irq46)
    LONG(_isr_irq47)
    LONG(_isr_irq48)
    LONG(_isr_irq49)
    LONG(_isr_irq50)
    LONG(_isr_irq51)
    LONG(_isr_irq52)
    LONG(_isr_irq53)
    LONG(_isr_irq54)
    LONG(_isr_irq55)
    LONG(_isr_irq56)
    LONG(_isr_irq57)
    LONG(_isr_irq58)
    LONG(_isr_irq59)
    LONG(_isr_irq60)
    LONG(_isr_irq61)
    LONG(_isr_irq62)
    LONG(_isr_irq63)
    LONG(_isr_irq64)
    LONG(_isr_irq65)
    LONG(_isr_irq66)
    LONG(_isr_irq67)
    LONG(_isr_irq68)
    LONG(_isr_irq69)
    LONG(_isr_irq70)
    LONG(_isr_irq71)
    LONG(_isr_irq72)
    LONG(_isr_irq73)
    LONG(_isr_irq74)
    LONG(_isr_irq75)
    LONG(_isr_irq76)
    LONG(_isr_irq77)
    LONG(_isr_irq78)
    LONG(_isr_irq79)
    LONG(_isr_irq80)
    LONG(_isr_irq81)
    LONG(_isr_irq82)
    LONG(_isr_irq83)
    LONG(_isr_irq84)
    LONG(_isr_irq85)
    LONG(_isr_irq86)
    LONG(_isr_irq87)
    LONG(_isr_irq88)
    LONG(_isr_irq89)
    LONG(_isr_irq90)
    LONG(_isr_irq91)
    LONG(_isr_irq92)
    LONG(_isr_irq93)
    LONG(_isr_irq94)
    LONG(_isr_irq95)
    LONG(_isr_irq96)
    LONG(_isr_irq97)
    LONG(_isr_irq98)
    LONG(_isr_irq99)
    LONG(_isr_irq100)
    LONG(_isr_irq101)
    LONG(_isr_irq102)
    LONG(_isr_irq103)
    LONG(_isr_irq104)
    LONG(_isr_irq105)
    LONG(_isr_irq106)
    LONG(_isr_irq107)
    LONG(_isr_irq108)
    LONG(_isr_irq109)
    LONG(_isr_irq110)
    LONG(_isr_irq111)
    LONG(_isr_irq112)
    LONG(_isr_irq113)
    LONG(_isr_irq114)
    LONG(_isr_irq115)
    LONG(_isr_irq116)
    LONG(_isr_irq117)
    LONG(_isr_irq118)
    LONG(_isr_irq119)
    LONG(_isr_irq120)
    LONG(_isr_irq121)
    LONG(_isr_irq122)
    LONG(_isr_irq123)
    LONG(_isr_irq124)
    LONG(_isr_irq125)
    LONG(_isr_irq126)
    LONG(_isr_irq127)
    LONG(_isr_irq128)
    LONG(_isr_irq129)
    LONG(_isr_irq130)
    LONG(_isr_irq131)
    LONG(_isr_irq132)
    LONG(_isr_irq133)
    LONG(_isr_irq134)
    LONG(_isr_irq135)
    LONG(_isr_irq136)
    LONG(_isr_irq137)
    LONG(_isr_irq138)
    LONG(_isr_irq139)
    LONG(_isr_irq140)
    LONG(_isr_irq141)
    LONG(_isr_irq142)
    LONG(_isr_irq143)
    LONG(_isr_irq144)
    LONG(_isr_irq145)
    LONG(_isr_irq146)
    LONG(_isr_irq147)
    LONG(_isr_irq148)
    LONG(_isr_irq149)
    LONG(_isr_irq150)
    LONG(_isr_irq151)
    LONG(_isr_irq152)
    LONG(_isr_irq153)
    LONG(_isr_irq154)
    LONG(_isr_irq155)
    LONG(_isr_irq156)
    LONG(_isr_irq157)
    LONG(_isr_irq158)
    LONG(_isr_irq159)
    LONG(_isr_irq160)
    LONG(_isr_irq161)
    LONG(_isr_irq162)
    LONG(_isr_irq163)
    LONG(_isr_irq164)
    LONG(_isr_irq165)
    LONG(_isr_irq166)
    LONG(_isr_irq167)
    LONG(_isr_irq168)
    LONG(_isr_irq169)
    LONG(_isr_irq170)
    LONG(_isr_irq171)
    LONG(_isr_irq172)
    LONG(_isr_irq173)
    LONG(_isr_irq174)
    LONG(_isr_irq175)
    LONG(_isr_irq176)
    LONG(_isr_irq177)
    LONG(_isr_irq178)
    LONG(_isr_irq179)
    LONG(_isr_irq180)
    LONG(_isr_irq181)
    LONG(_isr_irq182)
    LONG(_isr_irq183)
    LONG(_isr_irq184)
    LONG(_isr_irq185)
    LONG(_isr_irq186)
    LONG(_isr_irq187)
    LONG(_isr_irq188)
    LONG(_isr_irq189)
    LONG(_isr_irq190)
    LONG(_isr_irq191)
    LONG(_isr_irq192)
    LONG(_isr_irq193)
    LONG(_isr_irq194)
    LONG(_isr_irq195)
    LONG(_isr_irq196)
    LONG(_isr_irq197)
    LONG(_isr_irq198)
    LONG(_isr_irq199)
    LONG(_isr_irq200)
    LONG(_isr_irq201)
    LONG(_isr_irq202)
    LONG(_isr_irq203)
    LONG(_isr_irq204)
    LONG(_isr_irq205)
    LONG(_isr_irq206)
    LONG(_isr_irq207)
    LONG(_isr_irq208)
    LONG(_isr_irq209)
    LONG(_isr_irq210)
    LONG(_isr_irq211)
    LONG(_isr_irq212)
    LONG(_isr_irq213)
    LONG(_isr_irq214)
    LONG(_isr_irq215)
    LONG(_isr_irq216)
    LONG(_isr_irq217)
    LONG(_isr_irq218)
    LONG(_isr_irq219)
    LONG(_isr_irq220)
    LONG(_isr_irq221)
    LONG(_isr_irq222)
    LONG(_isr_irq223)
    LONG(_isr_irq224)
    LONG(_isr_irq225)
    LONG(_isr_irq226)
    LONG(_isr_irq227)
    LONG(_isr_irq228)
    LONG(_isr_irq229)
    LONG(_isr_irq230)
    LONG(_isr_irq231)
    LONG(_isr_irq232)
    LONG(_isr_irq233)
    LONG(_isr_irq234)
    LONG(_isr_irq235)
    LONG(_isr_irq236)
    LONG(_isr_irq237)
    LONG(_isr_irq238)
    LONG(_isr_irq239)
 } > rom

  .text :
  {
    *(.text .text*)
    *(.gnu.warning)
    *(.gnu.linkonce.t*)
    . = ALIGN(4);

     /* These are for running static constructors and destructors under ELF.  */
    KEEP (*crtbegin.o(.ctors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*crtend.o(.ctors))
    KEEP (*crtbegin.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*crtend.o(.dtors))

    . = ALIGN(0x4);
    KEEP (*crtbegin.o(.jcr))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .jcr))
    KEEP (*crtend.o(.jcr))

    *(.rodata .rodata.*)
    *(.gnu.linkonce.r.*)

    . = ALIGN(0x4);
    *(.gcc_except_table)

    . = ALIGN(0x4);
    *(.eh_frame)

    . = ALIGN(0x4);
    KEEP (*(.init))
    . = ALIGN(0x4);
    KEEP (*(.fini))
    . = ALIGN(4);

    *(.lit)

    . = ALIGN(4);

   } > rom

  .ARM.extab : { *(.ARM.extab* .gnu.linkonce.armextab.*) } > rom
  .ARM       : { *(.ARM.exidx*) } > rom

  .data :
  {
    *(.got.plt) *(.got)
    *(.shdata)
    *(.data .data*)
    *(.gnu.linkonce.d*)
    . = ALIGN(4);
  } > ccm AT> rom

  .bss :
  {
    *(.shbss)
    *(.bss .bss*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN(4);
   } > ccm

  .stab 0 (NOLOAD) :
  {
    *(.stab)
  }

  .stabstr 0 (NOLOAD) :
  {
    *(.stabstr)
  }


  .stack :
  {
    . = ORIGIN(ccm) + LENGTH(ccm);
  } > ccm

  /* Remove information from the standard libraries */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }

  __isr_vectors		= ADDR(.isr_vectors);
  __isr_vectors_size    = SIZEOF(.isr_vectors);
  __isr_vectors_end	= __isr_vectors + __isr_vectors_size;

  __text		= ADDR(.text);
  __text_size		= SIZEOF(.text);
  __text_end		= __text + __text_size;

  __data_ccm		= ADDR(.data);
  __data_rom		= LOADADDR(.data);
  __data_size		= SIZEOF(.data);
  __data_ccm_end	= __data_ccm + __data_size;
  __data_rom_end	= __data_rom + __data_size;

  __bss			= ADDR(.bss);
  __bss_size		= SIZEOF(.bss);
  __bss_end		= __bss + __bss_size;

  __stack_end		= ADDR(.stack);
  __stack_size		= SIZEOF(.stack);
  __stack		= __stack_end + __stack_size;

  .ARM.attributes 0 : { *(.ARM.attributes) }

  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section so we begin them at 0.  */
  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
}
