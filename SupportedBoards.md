# Supported Boards #


---

## ada-stm32f4 ##
  * target: arm-none-eabi
  * cpu: cortex-m4
  * arch: armv7e-m
  * float-abi: hard
  * fpu: fpv4-sp-d16
  * rts-arm-none-eabi\_armv7e-m\_hard

### Test Board ###

Tested with STM32F4-Discovery

### Implemented Features ###

  * Boot
  * Linker Script
  * Debug rules with stlink
  * Basic Ada Runtime (no io, no last chance handler)


---

## ada-qemu-lm3s6965evb ##
  * target: arm-none-eabi
  * cpu: cortex-m3
  * arch: armv7-m
  * float-abi: soft
  * fpu: soft
  * rts-arm-none-eabi\_armv7-m

### Test Board ###

qemu-system-arm -M lm3s6965evb only

### Implemented Features ###
  * Boot
  * Linker Script
  * qemu rules
  * Basic Ada Runtime (basic io and last chance handler implemented)


