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

/* ARM Cortex M4 startup file */
	.syntax		unified
	.cpu		cortex-m4
	.arch		armv7e-m
	.fpu		fpv4-sp-d16
	.thumb

	.global		_halt

	.extern		__data_ccm
	.extern		__data_ccm_end
	.extern		__data_rom

	.extern		__bss
	.extern		__bss_end

	.extern		board_setup
	.extern		program_setup
	.extern		program_loop
	.extern		adainit

	.weak		_start
	.type		_start, %function
_start:
	ldr		sp, =__stack

	/* rom 2 ram */
	ldr		r0, =__data_rom
	ldr		r1, =__data_ccm
	movs		r2, #0
	ldr		r3, =__data_size
	b		2f
1:
	ldr		r4, [r0, r2]
	str		r4, [r1, r2]
	adds		r2, r2, #4
2:
	cmp		r2, r3
	bcc		1b

	/* zero bss */
	movs		r0, #0
	ldr		r1, =__bss
	movs		r2, #0
	ldr		r3, =__bss_size
	b		2f
1:
	str		r0, [r1, r2]
	adds		r2, r2, #4
2:
	cmp		r2, r3
	bcc		1b

	bl		adainit
	bl		board_setup
	bl		program_setup
1:
	bl		program_loop
	cmp		r0,#0
	bne		1b
	b		_start
	.size		_start, .-_start


	.type		_halt, %function
_halt:
1:
	b		1b
	.size		_halt, .-_halt

	.macro		WEAK_DEFINE func alias
	.weak		\func
	.thumb_set	\func,\alias
	.endm

	WEAK_DEFINE	__gnat_last_chance_handler _halt
	WEAK_DEFINE	_isr_nmi	_halt
	WEAK_DEFINE	_isr_hard_fault	_halt
	WEAK_DEFINE	_isr_mm_fault	_halt
	WEAK_DEFINE	_isr_bus_fault	_halt
	WEAK_DEFINE	_isr_use_fault	_halt
	WEAK_DEFINE	_isr_svcall	_halt
	WEAK_DEFINE	_isr_debug	_halt
	WEAK_DEFINE	_isr_pend_sv	_halt
	WEAK_DEFINE	_isr_sys_tick	_halt

	WEAK_DEFINE	_isr_irq0	_halt
	WEAK_DEFINE	_isr_irq1	_halt
	WEAK_DEFINE	_isr_irq2	_halt
	WEAK_DEFINE	_isr_irq3	_halt
	WEAK_DEFINE	_isr_irq4	_halt
	WEAK_DEFINE	_isr_irq5	_halt
	WEAK_DEFINE	_isr_irq6	_halt
	WEAK_DEFINE	_isr_irq7	_halt
	WEAK_DEFINE	_isr_irq8	_halt
	WEAK_DEFINE	_isr_irq9	_halt
	WEAK_DEFINE	_isr_irq10	_halt
	WEAK_DEFINE	_isr_irq11	_halt
	WEAK_DEFINE	_isr_irq12	_halt
	WEAK_DEFINE	_isr_irq13	_halt
	WEAK_DEFINE	_isr_irq14	_halt
	WEAK_DEFINE	_isr_irq15	_halt
	WEAK_DEFINE	_isr_irq16	_halt
	WEAK_DEFINE	_isr_irq17	_halt
	WEAK_DEFINE	_isr_irq18	_halt
	WEAK_DEFINE	_isr_irq19	_halt
	WEAK_DEFINE	_isr_irq20	_halt
	WEAK_DEFINE	_isr_irq21	_halt
	WEAK_DEFINE	_isr_irq22	_halt
	WEAK_DEFINE	_isr_irq23	_halt
	WEAK_DEFINE	_isr_irq24	_halt
	WEAK_DEFINE	_isr_irq25	_halt
	WEAK_DEFINE	_isr_irq26	_halt
	WEAK_DEFINE	_isr_irq27	_halt
	WEAK_DEFINE	_isr_irq28	_halt
	WEAK_DEFINE	_isr_irq29	_halt
	WEAK_DEFINE	_isr_irq30	_halt
	WEAK_DEFINE	_isr_irq31	_halt
	WEAK_DEFINE	_isr_irq32	_halt
	WEAK_DEFINE	_isr_irq33	_halt
	WEAK_DEFINE	_isr_irq34	_halt
	WEAK_DEFINE	_isr_irq35	_halt
	WEAK_DEFINE	_isr_irq36	_halt
	WEAK_DEFINE	_isr_irq37	_halt
	WEAK_DEFINE	_isr_irq38	_halt
	WEAK_DEFINE	_isr_irq39	_halt
	WEAK_DEFINE	_isr_irq40	_halt
	WEAK_DEFINE	_isr_irq41	_halt
	WEAK_DEFINE	_isr_irq42	_halt
	WEAK_DEFINE	_isr_irq43	_halt
	WEAK_DEFINE	_isr_irq44	_halt
	WEAK_DEFINE	_isr_irq45	_halt
	WEAK_DEFINE	_isr_irq46	_halt
	WEAK_DEFINE	_isr_irq47	_halt
	WEAK_DEFINE	_isr_irq48	_halt
	WEAK_DEFINE	_isr_irq49	_halt
	WEAK_DEFINE	_isr_irq50	_halt
	WEAK_DEFINE	_isr_irq51	_halt
	WEAK_DEFINE	_isr_irq52	_halt
	WEAK_DEFINE	_isr_irq53	_halt
	WEAK_DEFINE	_isr_irq54	_halt
	WEAK_DEFINE	_isr_irq55	_halt
	WEAK_DEFINE	_isr_irq56	_halt
	WEAK_DEFINE	_isr_irq57	_halt
	WEAK_DEFINE	_isr_irq58	_halt
	WEAK_DEFINE	_isr_irq59	_halt
	WEAK_DEFINE	_isr_irq60	_halt
	WEAK_DEFINE	_isr_irq61	_halt
	WEAK_DEFINE	_isr_irq62	_halt
	WEAK_DEFINE	_isr_irq63	_halt
	WEAK_DEFINE	_isr_irq64	_halt
	WEAK_DEFINE	_isr_irq65	_halt
	WEAK_DEFINE	_isr_irq66	_halt
	WEAK_DEFINE	_isr_irq67	_halt
	WEAK_DEFINE	_isr_irq68	_halt
	WEAK_DEFINE	_isr_irq69	_halt
	WEAK_DEFINE	_isr_irq70	_halt
	WEAK_DEFINE	_isr_irq71	_halt
	WEAK_DEFINE	_isr_irq72	_halt
	WEAK_DEFINE	_isr_irq73	_halt
	WEAK_DEFINE	_isr_irq74	_halt
	WEAK_DEFINE	_isr_irq75	_halt
	WEAK_DEFINE	_isr_irq76	_halt
	WEAK_DEFINE	_isr_irq77	_halt
	WEAK_DEFINE	_isr_irq78	_halt
	WEAK_DEFINE	_isr_irq79	_halt
	WEAK_DEFINE	_isr_irq80	_halt
	WEAK_DEFINE	_isr_irq81	_halt
	WEAK_DEFINE	_isr_irq82	_halt
	WEAK_DEFINE	_isr_irq83	_halt
	WEAK_DEFINE	_isr_irq84	_halt
	WEAK_DEFINE	_isr_irq85	_halt
	WEAK_DEFINE	_isr_irq86	_halt
	WEAK_DEFINE	_isr_irq87	_halt
	WEAK_DEFINE	_isr_irq88	_halt
	WEAK_DEFINE	_isr_irq89	_halt
	WEAK_DEFINE	_isr_irq90	_halt
	WEAK_DEFINE	_isr_irq91	_halt
	WEAK_DEFINE	_isr_irq92	_halt
	WEAK_DEFINE	_isr_irq93	_halt
	WEAK_DEFINE	_isr_irq94	_halt
	WEAK_DEFINE	_isr_irq95	_halt
	WEAK_DEFINE	_isr_irq96	_halt
	WEAK_DEFINE	_isr_irq97	_halt
	WEAK_DEFINE	_isr_irq98	_halt
	WEAK_DEFINE	_isr_irq99	_halt
	WEAK_DEFINE	_isr_irq100	_halt
	WEAK_DEFINE	_isr_irq101	_halt
	WEAK_DEFINE	_isr_irq102	_halt
	WEAK_DEFINE	_isr_irq103	_halt
	WEAK_DEFINE	_isr_irq104	_halt
	WEAK_DEFINE	_isr_irq105	_halt
	WEAK_DEFINE	_isr_irq106	_halt
	WEAK_DEFINE	_isr_irq107	_halt
	WEAK_DEFINE	_isr_irq108	_halt
	WEAK_DEFINE	_isr_irq109	_halt
	WEAK_DEFINE	_isr_irq110	_halt
	WEAK_DEFINE	_isr_irq111	_halt
	WEAK_DEFINE	_isr_irq112	_halt
	WEAK_DEFINE	_isr_irq113	_halt
	WEAK_DEFINE	_isr_irq114	_halt
	WEAK_DEFINE	_isr_irq115	_halt
	WEAK_DEFINE	_isr_irq116	_halt
	WEAK_DEFINE	_isr_irq117	_halt
	WEAK_DEFINE	_isr_irq118	_halt
	WEAK_DEFINE	_isr_irq119	_halt
	WEAK_DEFINE	_isr_irq120	_halt
	WEAK_DEFINE	_isr_irq121	_halt
	WEAK_DEFINE	_isr_irq122	_halt
	WEAK_DEFINE	_isr_irq123	_halt
	WEAK_DEFINE	_isr_irq124	_halt
	WEAK_DEFINE	_isr_irq125	_halt
	WEAK_DEFINE	_isr_irq126	_halt
	WEAK_DEFINE	_isr_irq127	_halt
	WEAK_DEFINE	_isr_irq128	_halt
	WEAK_DEFINE	_isr_irq129	_halt
	WEAK_DEFINE	_isr_irq130	_halt
	WEAK_DEFINE	_isr_irq131	_halt
	WEAK_DEFINE	_isr_irq132	_halt
	WEAK_DEFINE	_isr_irq133	_halt
	WEAK_DEFINE	_isr_irq134	_halt
	WEAK_DEFINE	_isr_irq135	_halt
	WEAK_DEFINE	_isr_irq136	_halt
	WEAK_DEFINE	_isr_irq137	_halt
	WEAK_DEFINE	_isr_irq138	_halt
	WEAK_DEFINE	_isr_irq139	_halt
	WEAK_DEFINE	_isr_irq140	_halt
	WEAK_DEFINE	_isr_irq141	_halt
	WEAK_DEFINE	_isr_irq142	_halt
	WEAK_DEFINE	_isr_irq143	_halt
	WEAK_DEFINE	_isr_irq144	_halt
	WEAK_DEFINE	_isr_irq145	_halt
	WEAK_DEFINE	_isr_irq146	_halt
	WEAK_DEFINE	_isr_irq147	_halt
	WEAK_DEFINE	_isr_irq148	_halt
	WEAK_DEFINE	_isr_irq149	_halt
	WEAK_DEFINE	_isr_irq150	_halt
	WEAK_DEFINE	_isr_irq151	_halt
	WEAK_DEFINE	_isr_irq152	_halt
	WEAK_DEFINE	_isr_irq153	_halt
	WEAK_DEFINE	_isr_irq154	_halt
	WEAK_DEFINE	_isr_irq155	_halt
	WEAK_DEFINE	_isr_irq156	_halt
	WEAK_DEFINE	_isr_irq157	_halt
	WEAK_DEFINE	_isr_irq158	_halt
	WEAK_DEFINE	_isr_irq159	_halt
	WEAK_DEFINE	_isr_irq160	_halt
	WEAK_DEFINE	_isr_irq161	_halt
	WEAK_DEFINE	_isr_irq162	_halt
	WEAK_DEFINE	_isr_irq163	_halt
	WEAK_DEFINE	_isr_irq164	_halt
	WEAK_DEFINE	_isr_irq165	_halt
	WEAK_DEFINE	_isr_irq166	_halt
	WEAK_DEFINE	_isr_irq167	_halt
	WEAK_DEFINE	_isr_irq168	_halt
	WEAK_DEFINE	_isr_irq169	_halt
	WEAK_DEFINE	_isr_irq170	_halt
	WEAK_DEFINE	_isr_irq171	_halt
	WEAK_DEFINE	_isr_irq172	_halt
	WEAK_DEFINE	_isr_irq173	_halt
	WEAK_DEFINE	_isr_irq174	_halt
	WEAK_DEFINE	_isr_irq175	_halt
	WEAK_DEFINE	_isr_irq176	_halt
	WEAK_DEFINE	_isr_irq177	_halt
	WEAK_DEFINE	_isr_irq178	_halt
	WEAK_DEFINE	_isr_irq179	_halt
	WEAK_DEFINE	_isr_irq180	_halt
	WEAK_DEFINE	_isr_irq181	_halt
	WEAK_DEFINE	_isr_irq182	_halt
	WEAK_DEFINE	_isr_irq183	_halt
	WEAK_DEFINE	_isr_irq184	_halt
	WEAK_DEFINE	_isr_irq185	_halt
	WEAK_DEFINE	_isr_irq186	_halt
	WEAK_DEFINE	_isr_irq187	_halt
	WEAK_DEFINE	_isr_irq188	_halt
	WEAK_DEFINE	_isr_irq189	_halt
	WEAK_DEFINE	_isr_irq190	_halt
	WEAK_DEFINE	_isr_irq191	_halt
	WEAK_DEFINE	_isr_irq192	_halt
	WEAK_DEFINE	_isr_irq193	_halt
	WEAK_DEFINE	_isr_irq194	_halt
	WEAK_DEFINE	_isr_irq195	_halt
	WEAK_DEFINE	_isr_irq196	_halt
	WEAK_DEFINE	_isr_irq197	_halt
	WEAK_DEFINE	_isr_irq198	_halt
	WEAK_DEFINE	_isr_irq199	_halt
	WEAK_DEFINE	_isr_irq200	_halt
	WEAK_DEFINE	_isr_irq201	_halt
	WEAK_DEFINE	_isr_irq202	_halt
	WEAK_DEFINE	_isr_irq203	_halt
	WEAK_DEFINE	_isr_irq204	_halt
	WEAK_DEFINE	_isr_irq205	_halt
	WEAK_DEFINE	_isr_irq206	_halt
	WEAK_DEFINE	_isr_irq207	_halt
	WEAK_DEFINE	_isr_irq208	_halt
	WEAK_DEFINE	_isr_irq209	_halt
	WEAK_DEFINE	_isr_irq210	_halt
	WEAK_DEFINE	_isr_irq211	_halt
	WEAK_DEFINE	_isr_irq212	_halt
	WEAK_DEFINE	_isr_irq213	_halt
	WEAK_DEFINE	_isr_irq214	_halt
	WEAK_DEFINE	_isr_irq215	_halt
	WEAK_DEFINE	_isr_irq216	_halt
	WEAK_DEFINE	_isr_irq217	_halt
	WEAK_DEFINE	_isr_irq218	_halt
	WEAK_DEFINE	_isr_irq219	_halt
	WEAK_DEFINE	_isr_irq220	_halt
	WEAK_DEFINE	_isr_irq221	_halt
	WEAK_DEFINE	_isr_irq222	_halt
	WEAK_DEFINE	_isr_irq223	_halt
	WEAK_DEFINE	_isr_irq224	_halt
	WEAK_DEFINE	_isr_irq225	_halt
	WEAK_DEFINE	_isr_irq226	_halt
	WEAK_DEFINE	_isr_irq227	_halt
	WEAK_DEFINE	_isr_irq228	_halt
	WEAK_DEFINE	_isr_irq229	_halt
	WEAK_DEFINE	_isr_irq230	_halt
	WEAK_DEFINE	_isr_irq231	_halt
	WEAK_DEFINE	_isr_irq232	_halt
	WEAK_DEFINE	_isr_irq233	_halt
	WEAK_DEFINE	_isr_irq234	_halt
	WEAK_DEFINE	_isr_irq235	_halt
	WEAK_DEFINE	_isr_irq236	_halt
	WEAK_DEFINE	_isr_irq237	_halt
	WEAK_DEFINE	_isr_irq238	_halt
	WEAK_DEFINE	_isr_irq239	_halt
