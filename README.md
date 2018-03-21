http://regalis.com.pl/en/arm-cortex-stm32-gnulinux/

Install cmake

arm-none-eabi-gcc – The GNU Compiler Collection – cross compiler for ARM EABI (bare-metal) target
arm-none-eabi-gdb – The GNU Debugger for the ARM EABI (bare-metal) target
arm-none-eabi-binutils – A set of programs to assemble and manipulate binary and object files for the ARM EABI (bare-metal) target
openocd – Debugging, in-system programming and boundary-scan testing for embedded target devices
vim – The text editor of my choice

`sudo apt install gcc-arm-none-eabi` etc.

    ahris ~/grive/linux/adult_work/tamagodai
    ✦ arm-none-eabi-
    arm-none-eabi-addr2line   arm-none-eabi-elfedit     arm-none-eabi-gcc-ranlib  arm-none-eabi-nm          arm-none-eabi-size
    arm-none-eabi-ar          arm-none-eabi-g++         arm-none-eabi-gcov        arm-none-eabi-objcopy     arm-none-eabi-strings
    arm-none-eabi-as          arm-none-eabi-gcc         arm-none-eabi-gdb         arm-none-eabi-objdump     arm-none-eabi-strip
    arm-none-eabi-c++         arm-none-eabi-gcc-4.9.3   arm-none-eabi-gprof       arm-none-eabi-ranlib
    arm-none-eabi-c++filt     arm-none-eabi-gcc-ar      arm-none-eabi-ld          arm-none-eabi-readelf
    arm-none-eabi-cpp         arm-none-eabi-gcc-nm      arm-none-eabi-ld.bfd      arm-none-eabi-run


Make an account with ST.

download STM32Cube, which comes with drivers, HAL, example code, and more.
http://www.st.com/content/st_com/en/products/embedded-software/mcus-embedded-software/stm32-embedded-software/stm32cube-mcu-packages/stm32cubef0.html

---

# Build an Example

## Directory

`STM32Cube_FW_F0_V1.9.0/Projects/STM32F072B-Discovery/Examples/GPIO/GPIO_EXTI`


## Building

    arm-none-eabi-gcc -Wall -mcpu=cortex-m0 -mlittle-endian -mthumb -I/home/ahris/grive/linux/adult_work/GameEgg/STM32Cube_FW_F0_V1.9.0/Drivers/CMSIS/Device/ST/STM32F0xx/Include/ -I/home/ahris/grive/linux/adult_work/GameEgg/STM32Cube_FW_F0_V1.9.0/Drivers/CMSIS/Include/ -DSTM32F072xB -Os -c Src/system_stm32f0xx.c -o ./build/system_stm32f0xx.o

    arm-none-eabi-gcc -Wall -mcpu=cortex-m0 -mlittle-endian -mthumb -I/home/ahris/grive/linux/adult_work/GameEgg/STM32Cube_FW_F0_V1.9.0/Drivers/CMSIS/Device/ST/STM32F0xx/Include/ -I/home/ahris/grive/linux/adult_work/GameEgg/STM32Cube_FW_F0_V1.9.0/Drivers/CMSIS/Include/ -IInc -I/home/ahris/grive/linux/adult_work/GameEgg/STM32Cube_FW_F0_V1.9.0/Drivers/STM32F0xx_HAL_Driver/Inc/ -I/home/ahris/grive/linux/adult_work/GameEgg/STM32Cube_FW_F0_V1.9.0/Drivers/BSP/STM32F072B-Discovery/ -DSTM32F072xB -Os -c Src/main.c -o ./build/main.o

    arm-none-eabi-gcc -Wall -mcpu=cortex-m0 -mlittle-endian -mthumb -I/home/ahris/grive/linux/adult_work/GameEgg/STM32Cube_FW_F0_V1.9.0/Drivers/CMSIS/Device/ST/STM32F0xx/Include/ -I/home/ahris/grive/linux/adult_work/GameEgg/STM32Cube_FW_F0_V1.9.0/Drivers/CMSIS/Include/ -IInc -I/home/ahris/grive/linux/adult_work/GameEgg/STM32Cube_FW_F0_V1.9.0/Drivers/STM32F0xx_HAL_Driver/Inc/ -I/home/ahris/grive/linux/adult_work/GameEgg/STM32Cube_FW_F0_V1.9.0/Drivers/BSP/STM32F072B-Discovery/ -DSTM32F072xB -Os -c Src/stm32f0xx_it.c -o ./build/stm32f0xx_it.o


## Linking

    arm-none-eabi-gcc -mcpu=cortex-m0 -mlittle-endian -mthumb -DSTM32F072xB -TSW4STM32/STM32F072B-Discovery/STM32F072RBTx_FLASH.ld -Wl,--gc-sections ./build/system_stm32f0xx.o ./build/main.o ./build/stm32f0xx_it.o -o ./build/main.elf


## Convert ELF to Intel Hex format

    arm-none-eabi-objcopy -Oihex ./build/main.elf ./build/main.hex


## Flashing

    sudo apt-get install openocd

Run OpenOCD

    openocd -f /usr/share/openocd/scripts/board/stm32f0discovery.cfg

Connect

    telnet localhost 4444

    reset halt
    flash write_image erase ./build/main.hex
    reset run


-------------

# Discovery board data sheet
http://www.st.com/content/ccc/resource/technical/document/user_manual/3b/8d/46/57/b7/a9/49/b4/DM00099401.pdf/files/DM00099401.pdf/jcr:content/translations/en.DM00099401.pdf

B1 USER: User and Wake-Up button connected to the I/O PA0 of the STM32F072RBT6.

------------

# GDB

    arm-none-eabi-gdb ./build/main.elf
    (gdb) target remote localhost:4444

------------

    arm-none-eabi-nm -S -n ./build/main.elf

The way I compiled + linked is probably wrong!! NM shows a bunch of undefined symbols:

     arm-none-eabi-nm -S -n ./build/main.elf
     U BSP_LED_Init
     U BSP_LED_Toggle
     w __deregister_frame_info
     U _exit
     U free
     U HAL_GPIO_EXTI_IRQHandler
     U HAL_GPIO_Init
     U HAL_IncTick


https://stackoverflow.com/questions/2329722/nm-u-the-symbol-is-undefined

An undefined symbol is a symbol that the library uses but was not defined in any of the object files that went into creating the library.

Usually the symbol is defined in another library which also needs to be linked in to your application. Alternatively the symbol is undefined because you've forgotten to build the code that defines the symbol or you've forgotten to include the object file with that symbol into your library.

------------

