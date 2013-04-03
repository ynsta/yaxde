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

#define UARTDR (*((volatile unsigned char *)0x4000C000))
#define UARTFR (*((volatile unsigned char *)0x4000C018))

#define UARTFR_BUSY (1<<3) /* cleared when Tx Finished */
#define UARTFR_RXFE (1<<4) /* Rx FIFO Empty */
#define UARTFR_TXFF (1<<5) /* Tx FIFO Full */
#define UARTFR_RXFF (1<<6) /* Rx FIFO Full */
#define UARTFR_TXFE (1<<6) /* Tx FIFO Empty */


int get_int(void)
{
    return 0 /* TBD */;
}

char get_char(void)
{
    while ((UARTFR & UARTFR_RXFE) == UARTFR_RXFE)
        ;
    return UARTDR;
}



void put_char(char c)
{
    while ((UARTFR & UARTFR_TXFF) == UARTFR_TXFF)
        ;
    UARTDR = c;
}

void put_char_stderr(char c)
{
    put_char(c);
}

void put_int(int i)
{
    /* TBD */;
}


void put_int_stderr(int i)
{
    put_int(i);
}
