#!/usr/bin/python
# -*- coding: utf-8 -*-

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


import struct
import time
import sys
import math
import os

try:
    import serial
except:
    sys.stderr.write('''
pyserial python library is missing and must be installed

on GNU/Linux install python-serial, pyserial, python-pyserial depending on your distrib
  debian/ubuntu:  apt-get install python-serial
  fedora/red-hat: yum install pyserial
  arch: pacman -S python-pyserial
  ...

on Ms Windows a setup can be downloaded here:
  http://www.lfd.uci.edu/~gohlke/pythonlibs/#pyserial

  Select the the version correspoding to your python install

''')
    sys.exit(42)



VERSION='1.0'
DESCRIPTION='''STM32 serial bootloader host tool (AN3155)

 * Connect BOOT0 to VDD, BOOT1(PB2) to GND and reset to start bootloader.
 * Connect Tx to PB10(USART3 RX),
 *         Rx to PB11(USART3 TX) (RS232 PHY required).

'''

CMD_INIT            = chr(0x7F)
CMD_GET_VER         = chr(0x00)
CMD_GET_ID          = chr(0x02)
CMD_READ            = chr(0x11)
CMD_GO              = chr(0x21)
CMD_WRITE           = chr(0x31)
CMD_ERASE           = chr(0x43)
CMD_ERASE_EXT       = chr(0x44)
CMD_WRITE_PROT      = chr(0x63)
CMD_WRITE_UNPROT    = chr(0x73)
CMD_READ_PROT       = chr(0x82)
CMD_READ_UNPROT     = chr(0x92)

ACK                 = chr(0x79)
NACK                = chr(0x1F)

VERSION_MIN_SUPPORT = 0x21

CHIP_SUPPORT        = [0x0413, 0x0414]

ERASE_TO            = 20.0

WRITESIZE           = 256 # max 256


FLASH_ADDR          = 0x08000000


def to_str(arg):
    if arg == None:
        return ''
    elif type(arg) == chr or type(arg) == str:
        return arg
    elif type(arg) == int:
        if arg & 0xFF == arg:
            return chr(arg)
        else:
            return struct.pack('>I', arg)
    elif type(arg) == list or type(arg) == tuple:
        return ''.join(map(to_str, arg))
    else:
        return []

def to_buf(arg):
    return map(ord, list(to_str(arg)))


class SerialDFU(serial.Serial):

    def __init__(self, port, baudrate=115200, rtscts=False):
         super(SerialDFU, self).__init__(port=port, baudrate=baudrate, rtscts=rtscts,
                                         timeout=2.0,
                                         parity=serial.PARITY_EVEN,
                                         stopbits=serial.STOPBITS_ONE)

    def init(self):

        self.version = None
        self.vmin = 0
        self.vmaj = 0
        self.chip = None

        self.flushOutput()
        self.flushInput()

        if not self.write(CMD_INIT):
            sys.stderr.write('Unable to init\n\n')
            sys.stderr.write(DESCRIPTION)
            return False

        self.version = self._getVersion()
        if not self.version:
            sys.stderr.write('Unable to read version\n')
            return False

        tmp = ord(self.version[0])
        self.vmaj = tmp >> 4
        self.vmin = tmp & 0xf

        if tmp < VERSION_MIN_SUPPORT:

            sys.stderr.write('Unsupported bootloader version %1x.%1x\n'
                             % (self.vmaj, self.vmin))
            self.version = None
            self.vmin = 0
            self.vmaj = 0
            return False


        self.chip = self._getChip()
        if not self.chip:
            sys.stderr.write('Unable to read chip id\n')
            return False

        if not (self.chip in CHIP_SUPPORT):
            sys.stderr.write('Unsupported chip id %04x\n' % self.chip)
            self.chip = None
            return False

        return True

    def _ack(self):
        r = self.read(1)
        if r == NACK:
            # try to read the second NACK
            self.read(1)
        return r == ACK


    def write(self, data):
        self.flushInput()
        buf = to_str(data)
        if len(buf) > 1:
            cksum = 0
            for i in buf:
                cksum = cksum ^ ord(i)
            buf = buf + chr(cksum)
        super(SerialDFU, self).write(buf)
        return self._ack()

    def writeCmd(self, cmd):
        self.flushInput()
        buf = cmd + chr((~ord(cmd) & 0xFF))
        super(SerialDFU, self).write(buf)
        return self._ack()


    def _getVersion(self):
        if not self.writeCmd(CMD_GET_VER):
            return None
        r = self.read(1)
        if len(r) != 1:
            return None
        size = ord(r) + 1
        v = self.read(size)
        if len(v) != size:
            return None
        if not self._ack():
            return None
        else:
            return v

    def _getChip(self):
        if not self.writeCmd(CMD_GET_ID):
            return None
        cbuf = self.read(3)
        if len(cbuf) != 3:
            return None
        if not self._ack():
            return None
        chip = struct.unpack('>bH', cbuf)
        if chip[0] != 1:
            return None
        return chip[1]

    def writeUnprot(self):
        if not self.version and not self.chip:
            sys.stderr.write('Not initialized\n')
            return False


        if ((not self.writeCmd(CMD_WRITE_UNPROT)) and
            (not self._ack())):
            return False

        # Wait for Reset
        time.sleep(0.5)

        # Reinit
        return self.write(CMD_INIT)


    def erase(self):
        if not self.version and not self.chip:
            sys.stderr.write('Not initialized\n')
            return False
        if self.vmaj >= 3:
            if not self.writeCmd(CMD_ERASE_EXT):
                return False
            super(SerialDFU, self).write('\xFF')
        else:
            if not self.writeCmd(CMD_ERASE):
                return False
        super(SerialDFU, self).write('\xFF')
        super(SerialDFU, self).write('\x00')

        tmp = self.timeout
        self.timeout = ERASE_TO
        ack = self._ack()
        self.timeout = tmp
        return ack

    def writeMem(self, buf, address = FLASH_ADDR):
        off = 0
        size = len(buf)
        to = self.timeout
        self.timeout = 20
        while buf:
            page = buf[:WRITESIZE]
            buf = buf[WRITESIZE:]
            page = chr(len(page) - 1) + page
            if not self.writeCmd(CMD_WRITE):
                sys.stderr.write('Flash Error: flash write cmd not ack\n')
                return False
            if not self.write((address + off)):
                sys.stderr.write('Flash Error: send addr 0x%08x\n' % (address + off))
                return False
            if not self.write(page):
                sys.stderr.write('Flash Error: write page at 0x%08x\n' % (address + off))
                return False
            off += WRITESIZE

        return True

    def readUnprot(self):
        if not self.version and not self.chip:
            sys.stderr.write('Not initialized\n')
            return False


        if ((not self.writeCmd(CMD_READ_UNPROT)) and
            (not self._ack())):
            return False

        # Wait for Reset
        time.sleep(0.5)

        # Reinit
        return self.write(CMD_INIT)



    def readMem(self, size, address = FLASH_ADDR):

        buf = ''
        off = 0
        while size > 0:

            tr = min(255, size)
            size -= tr

            if not self.writeCmd(CMD_READ):
                return None

            if not self.write(address + off):
                return None
            if not self.writeCmd(chr(tr-1)):
                return None

            tmp = self.read(tr)
            buf = buf + tmp
            off = off + len(tmp)

        return buf

    def go(self, address = FLASH_ADDR):
        if not self.writeCmd(CMD_GO):
            return False
        if not self.write(address):
            return None
        return True

# =====================================================================
# MAIN if used as a program

if __name__ == '__main__':

    import argparse

    parser = argparse.ArgumentParser(description=DESCRIPTION,
                                     formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-v', '--version', action='version',
                        version='%(prog)s ' + VERSION)

    parser.add_argument('-p', '--port',
                        action='store', dest='PORT', type=str,
                        required=True,
                        help="programmer board serial port")

    parser.add_argument('-b', '--bauds',
                        action='store', dest='BAUDS', type=int,
                        choices=[9600, 19200, 38400, 57600, 115200],
                        default=115200,
                        help="serial link baudrate")

    parser.add_argument('-a', '--address',
                        action='store', dest='ADDRESS', type=int,
                        help="read/write/go ADDRESS (default: 0x%08x)" % FLASH_ADDR,
                        default=FLASH_ADDR)

    parser.add_argument('-c', '--count',
                        action='store', dest='COUNT', type=int,
                        help="bytes to read or write", default=0)

    parser.add_argument('-e', '--erase',
                        action='store_true', dest='ERASE', default=None,
                        help="erase before write")

    parser.add_argument('-w', '--write',
                        action='store', dest='IFILE', type=str, default=None,
                        help="write to target from IFILE")

    parser.add_argument('-r', '--read',
                        action='store', dest='OFILE', type=str, default=None,
                        help="read from target and store into OFILE")

    parser.add_argument('-x', '--go',
                        action='store_true', dest='GO', default=False,
                        help="run code at ADDRESS")


    args = parser.parse_args()


    dfu = SerialDFU(port = args.PORT, baudrate = args.BAUDS)


    sys.stdout.write('== STM32: SERIAL DFU ==\n')
    sys.stdout.write('INIT ............. ')
    sys.stdout.flush()
    if not dfu.init():
        sys.exit(1)
    sys.stdout.write('Done\n')

    sys.stdout.write('CHIP ............. %04x\n' % (dfu.chip, ))
    sys.stdout.write('BOOT VERSION ..... %d.%d\n' % (dfu.vmaj, dfu.vmin))


    # Force ERASE if write in flash
    if (args.IFILE != None and
        args.ADDRESS >= FLASH_ADDR and
        args.ERASE == None):
        args.ERASE = True

    if args.ERASE or args.IFILE:
        sys.stdout.write('WRITE UNPROTECT .. ')
        sys.stdout.flush()
        if not dfu.writeUnprot():
            sys.stderr.write('Error\n')
            sys.exit(3)
        sys.stdout.write('Done\n')

    if args.ERASE:
        sys.stdout.write('ERASE ............ ')
        sys.stdout.flush()
        if not dfu.erase():
            sys.stderr.write('Error\n')
            sys.exit(4)
        sys.stdout.write('Done\n')


    if args.IFILE:
        try:
            f = open(args.IFILE, 'rb')
            buf = f.read()
            f.close()
        except:
            sys.stderr.write('Error: unable to open %s\n' % args.IFILE)
            sys.exit(2)

        if not args.COUNT:
            args.COUNT = len(buf)

        sys.stdout.write('WRITE ............ ')
        sys.stdout.flush()
        if not dfu.writeMem(buf, address = args.ADDRESS):
            sys.stderr.write('Error\n')
            sys.exit(5)
        sys.stdout.write('Done\n')

    if args.IFILE or args.OFILE:
        sys.stdout.write('READ UNPROTECT ... ')
        sys.stdout.flush()
        if not dfu.readUnprot():
            sys.stderr.write('Error\n')
            sys.exit(6)
        sys.stdout.write('Done\n')

        sys.stdout.write('READ ............. ')
        sys.stdout.flush()
        vbuf = dfu.readMem(size = args.COUNT, address = args.ADDRESS)
        sys.stdout.write('Done\n')

    if args.OFILE and vbuf:
        of = open(args.OFILE, 'wb')
        of.write(vbuf)

    if args.IFILE:
        success = (buf == vbuf)
        sys.stdout.write('COMPARE .......... ' + str(success) + '\n')

        if not success:
            sys.exit(7)

    if args.GO:
        sys.stdout.write('START ............ ')
        sys.stdout.flush()
        if not dfu.go(address = args.ADDRESS):
            sys.stderr.write('Unable to start\n')
            sys.exit(8)
        sys.stdout.write('Done\n')

