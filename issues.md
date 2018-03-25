# Issue Log

## Issue Log #0

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

I was missing all of the CMSIS and BSP code! Need to build & link it!

------------

## Issue Log #1

Loaded my code with `make debugserver; make debug;`, but after we enter the while loop in main, it was hanging. The debugger tells me I was hitting this line in startup.s:

    /**
     * @brief  This is the code that gets called when the processor receives an
     *         unexpected interrupt.  This simply enters an infinite loop, preserving
     *         the system state for examination by a debugger.
     *
     * @param  None
     * @retval : None
    */
        .section .text.Default_Handler,"ax",%progbits
    Default_Handler:
    Infinite_Loop:
      b Infinite_Loop
      .size Default_Handler, .-Default_Handler

After many confused google searches, I read the comment right above that line. We apparently hit this when we get a unhandled interrupt. Well, the interrupts vector looks correct to me in that same file. I dumped the symbol table of my elf, and it turns out the interrupt handlers were all weak symbols! Weak symbols are defined symbols that don't have an implementation. You can indicate they are weak to tell the compiler that these symbols will be linked later. Weak symbols are nice because the linker can replace these weak symbols later with a stronger symbol and won't emit a multiple definition warning. Well, there is no later! They are straight up missing.

Turns out I was linking the wrong startup.s in my make file. I should have been using the one from the example project directory.

So instead of `lib/cmsis/Device/ST/STM32F0xx/Source/Templates/system_stm32f0xx.o` it should have been `src/system_stm32f0xx.o`. I was also missing the other source file from the example project in my Makefile.

------------

