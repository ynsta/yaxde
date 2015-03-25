# LICENSE #

## Modified BSD License ##
All project files are covered by "Modified BSD License" aka "New BSD License" :

Copyright (c) 2013, Stany MARCEL
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the '<'organization'>' nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


Some other files comes from other projects with different licenses.

## GCC ##
GCC license is GNU General Public License (version 3 or later) with GCC Runtime Library Exception.

GCC Patches are covered by this license:
  * [gcc-4.8.0-ada\_bare\_board.patch](http://code.google.com/p/yaxde/source/browse/toolchain/src/gcc-4.8.0-ada_bare_board.patch)
  * [gcc-4.8.0-arm-cortex-elf-multilibs.patch](http://code.google.com/p/yaxde/source/browse/toolchain/src/gcc-4.8.0-arm-cortex-elf-multilibs.patch)
  * [gcc-4.8.0-fix-gnatools-canadian.patch](http://code.google.com/p/yaxde/source/browse/toolchain/src/gcc-4.8.0-fix-gnatools-canadian.patch)
  * [gcc-4.8.0-xgnatugn-canadian.patch](http://code.google.com/p/yaxde/source/browse/toolchain/src/gcc-4.8.0-xgnatugn-canadian.patch)

## GNAT ##
GNAT files are covered by [GNAT Modified General Public License](http://en.wikipedia.org/wiki/GNAT_Modified_General_Public_License)

GNAT files are not distributed with this project but copied from GCC installation when the RTS is build.

Only system.ads is modified and included in this project as it must be implemented for each board (see also AdaRuntime).