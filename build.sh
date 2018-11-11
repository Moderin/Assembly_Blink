#!/bin/bash

# Remove old files
rm *.out

# Build
arm-none-eabi-as -mthumb start.S
arm-none-eabi-ld -T start.ld -o a.elf a.out
arm-none-eabi-objcopy -O binary a.elf  a.bin

# Upload
st-flash write a.bin 0x08000000
