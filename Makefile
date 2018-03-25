CORE_OBJS = src/main.o \
            src/stm32f0xx_it.o \
            src/system_stm32f0xx.o
            # src/vm.o \
            # src/mem.o \
            # src/bot.o \
            # src/servo.o \
            # src/ps2ctrl.o \
            # src/trajectory.o

HAL_OBJS = lib/hal/Src/stm32f0xx_hal.o \
           lib/hal/Src/stm32f0xx_hal_gpio.o \
           lib/hal/Src/stm32f0xx_hal_rcc.o \
           lib/hal/Src/stm32f0xx_hal_cortex.o
           # lib/hal/Src/stm32f0xx_hal_uart.o \
           # lib/hal/Src/stm32f0xx_hal_rcc_ex.o \
           # lib/hal/Src/stm32f0xx_hal_tim.o \
           # lib/hal/Src/stm32f0xx_hal_tim_ex.o \
           # lib/hal/Src/stm32f0xx_hal_adc.o \
           # lib/hal/Src/stm32f0xx_hal_adc_ex.o \
           # lib/hal/Src/stm32f0xx_hal_pcd.o \
           # lib/hal/Src/stm32f0xx_hal_pcd_ex.o \
           # lib/hal/Src/stm32f0xx_hal_spi.o

BSP_OBJS = lib/bsp/stm32f072b_discovery.o

USB_OBJS = lib/cmsis/Device/ST/STM32F0xx/Source/Templates/gcc/startup_stm32f072xb.o
           # lib/cmsis/Device/ST/STM32F0xx/Source/Templates/system_stm32f0xx.o \
           # lib/usb/Core/Src/usbd_core.o \
           # lib/usb/Core/Src/usbd_ctlreq.o \
           # lib/usb/Core/Src/usbd_ioreq.o \
           # lib/usb/Class/CDC/Src/usbd_cdc.o
           # src/usbd_cdc_if.o \
           # src/usbd_conf.o \
           # src/usbd_desc.o \
           # src/usb_device.o \

OBJS = $(CORE_OBJS) $(HAL_OBJS) $(BSP_OBJS) $(USB_OBJS)

PROJ_NAME=main

LDSCRIPT_INC=ld
LDSCRIPT=STM32F072RBTx_FLASH.ld

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy
OBJDUMP=arm-none-eabi-objdump
SIZE=arm-none-eabi-size

# Can also try -Og -- which will optimize while keeping debugging capabilities.
CFLAGS  = -Wall -Werror -g -std=c11 -Os -DSTM32F072xB
CFLAGS += -mlittle-endian -mcpu=cortex-m0 -mthumb
# -nostdlib
CFLAGS += -ffunction-sections -fdata-sections --specs=nosys.specs
CFLAGS += -Wl,--gc-sections
CFLAGS += -DUSE_FULL_ASSERT

LDFLAGS  =

###################################################

CFLAGS += -I inc
CFLAGS += -I lib/hal/Inc
CFLAGS += -I lib/bsp
CFLAGS += -I lib/cmsis/Device/ST/STM32F0xx/Include
CFLAGS += -I lib/cmsis/Include
# CFLAGS += -I lib/usb/Core/Inc
# CFLAGS += -I lib/usb/Class/CDC/Inc

all: main.bin main.lst

%.o: %.s
    @echo "[AS]   $@"
    @$(CC) -c $(CFLAGS) -o $@ $<

%.o: %.c
    @echo "[CC]   $@"
    @$(CC) -c $(CFLAGS) -o $@ $<

$(PROJ_NAME).elf: $(OBJS)
    @echo "[LD]   $@"
    @$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -L$(LDSCRIPT_INC) -T$(LDSCRIPT)
    $(SIZE) $@

%.bin: %.elf
    @echo "[BIN]  $@"
    @$(OBJCOPY) -O binary $< $@

%.lst: %.elf
    @echo "[LST]  $@"
    @$(OBJDUMP) -d $< > $@

# hw/bom.md: hw/bom.csv
#   csvtomd $< > $@

debugserver: main.bin
    openocd -f ocd/target.cfg

debug: main.elf
    arm-none-eabi-gdb -x ocd/gdb $<

clean:
    @echo "[CLEAN]"
    @rm -f $(OBJS)
    @rm -f $(PROJ_NAME).elf
    @rm -f $(PROJ_NAME).bin
    @rm -f $(PROJ_NAME).lst

wc:
    find . -name "*.[hc]" | grep -v "/lib/" | xargs wc -l | sort -n