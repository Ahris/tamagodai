# Issue Log

My insane ramblings and things I learned along the way. This page primarily serves as notes and scratch space for myself.

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

## Issue Log #2

I don't know how to hook up my buttons to the board. Embedded.fm just so happens to have a blog that explains how the user button on the Discovery board works!

https://www.embedded.fm/blog/2016/11/1/discovery-buttons

I used my life line and called my buddy Will to help break all of that down.

The RC circuit is used for button debouncing. That is R38 and C38 in the diagram from the blog post.

![Button Circuit, Figure 1](https://static1.squarespace.com/static/50834ba9c4aa1a31c651078b/t/581971e3bebafb322e6504f4/1478062576062/?format=500w)

When the button is not pressed, the capacitor holds charge; they are like tiny batteries in that sense. It also acts like a really high value resistor. It charges up over a very small amount of time. Because it acts like a resistor, no current flows through that branch of the circuit, so you have 0V at the node between C38 and R35, that means your GPIO will see a value of 0. Similarly, when your button is not pressed, there is an air gap between the terminals. The air gap, when dealing with these small voltages, can be considered a really big resistance like gigaohms per millimeter (from the blog post).

When your button is pressed, current starts flowing and there's no longer an electric potential difference across the capacitor, so it starts to discharge. The time it takes to discharge looks like this graph:

![Discharge rate](https://cdn.miniphysics.com/wp-content/uploads/2015/01/RC-charging-and-discharging.jpg)

Once it has discharged enough, enough current will flow to the GPIO to surpass its threshold for a high (non-low) input value and the processor will see a 1 at that input! Kinda handy wave-y, but cool!!

Can read more about time constants and discharge time here: https://www.electronics-tutorials.ws/rc/rc_1.html

Impedance (Z) is a value that describes __resistance__ and __reactance__. Resistance is how much a component prevents the flow of electrons. Reactance is how a component stores or releases charge as current and voltage fluctuates. Impedance is a function of these two values. A capacitor's impedance matters since it holds charge, so it has reactance. Need to read this page for info on how to calculate impedance. http://whatis.techtarget.com/definition/impedance

Anyways, I don't need this RC circuit. It's just a nice to have. I can always do software debouncing.

Next, I need to calculate the resistor values. Need to find the amount of power GPIO can take in (taking into consideration that it has its own internal resistor)

What is a voltage divider?

It's when two resisters are in series. The voltage at n1 is (VDD / (R1 + R2)) * R2. If R1 > R2, then that value is less than half because (hand wave-y explanation) R2 is a large amount of resistance, so less current gets through. If R1 == R2, then the voltage is halved.

    VDD --- R1 --- n1 ---- R2 ---- |||
                   |

Why a hardware debouncer instead of software debouncer?

You can just set it once and forget about it if you need a constant debounce value. You don't need software resources like a timer and it can't be misconfigured in the future.

Can I short my board by misconfiguring the buttons?

Probs not. Need to make sure the resistor to ground has a sufficiently high value (in the hundreds for 5V? I'm currently using 10k) so that there is not too much draw from power. Also the board is powered over USB, which has a hundred-ish milliamps of power draw? I need to learn what that implies. :^)

------------

