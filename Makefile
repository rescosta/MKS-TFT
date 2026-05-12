TARGET  = MKS-TFT32
BUILD   = build
TOOLCHAIN = /opt/homebrew/Cellar/arm-gcc-bin@10/10.3-2021.10_1/bin
CC      = $(TOOLCHAIN)/arm-none-eabi-gcc
CXX     = $(TOOLCHAIN)/arm-none-eabi-g++
AS      = $(TOOLCHAIN)/arm-none-eabi-gcc -x assembler-with-cpp
OBJCOPY = $(TOOLCHAIN)/arm-none-eabi-objcopy
SIZE    = $(TOOLCHAIN)/arm-none-eabi-size

DEFS = -DSTM32F107xC -DMKS_TFT -DILI9328 -DR61505 -DUSE_HAL_DRIVER

INCS = \
  -IInc \
  -ISrc \
  -IIcons \
  -IFonts \
  -IDrivers/CMSIS/Include \
  -IDrivers/CMSIS/Device/ST/STM32F1xx/Include \
  -IDrivers/STM32F1xx_HAL_Driver/Inc \
  -IDrivers/STM32F1xx_HAL_Driver/Inc/Legacy \
  -IMiddlewares/Third_Party/FreeRTOS/Source/include \
  -IMiddlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS \
  -IMiddlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM3 \
  -IMiddlewares/Third_Party/FatFs/src \
  -IMiddlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc \
  -IMiddlewares/ST/STM32_USB_Host_Library/Core/Inc

CPU     = -mcpu=cortex-m3 -mthumb
OPT     = -Os -g3
WARN    = -Wall
COMMON  = $(CPU) $(OPT) $(WARN) -fdata-sections -ffunction-sections -funroll-loops $(DEFS) $(INCS)

CFLAGS   = $(COMMON) -std=c11
CXXFLAGS = $(COMMON) -std=c++11 -fno-exceptions -fno-rtti
ASFLAGS  = $(CPU) -Wa,--gdwarf-2 $(DEFS) $(INCS)
LDFLAGS  = $(CPU) -TSTM32F107VC_FLASH.ld \
           -u _scanf_float -u _printf_float \
           -lstdc++ -lm \
           -Wl,--gc-sections \
           -specs=nosys.specs

C_SRCS = \
  Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/system_stm32f1xx.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_cortex.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_dma.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash_ex.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio_ex.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_hcd.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_i2c.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_pwr.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc_ex.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_spi.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_spi_ex.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim_ex.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_uart.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_ll_usb.c \
  Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc.c \
  Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc_bot.c \
  Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc_scsi.c \
  Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_core.c \
  Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_ctlreq.c \
  Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_ioreq.c \
  Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_pipes.c \
  Middlewares/Third_Party/FatFs/src/diskio.c \
  Middlewares/Third_Party/FatFs/src/ff.c \
  Middlewares/Third_Party/FatFs/src/ff_gen_drv.c \
  Middlewares/Third_Party/FatFs/src/option/ccsbcs.c \
  Middlewares/Third_Party/FatFs/src/option/syscall.c \
  Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS/cmsis_os.c \
  Middlewares/Third_Party/FreeRTOS/Source/croutine.c \
  Middlewares/Third_Party/FreeRTOS/Source/event_groups.c \
  Middlewares/Third_Party/FreeRTOS/Source/list.c \
  Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM3/port.c \
  Middlewares/Third_Party/FreeRTOS/Source/portable/MemMang/heap_4.c \
  Middlewares/Third_Party/FreeRTOS/Source/queue.c \
  Middlewares/Third_Party/FreeRTOS/Source/tasks.c \
  Middlewares/Third_Party/FreeRTOS/Source/timers.c \
  Src/eeprom.c \
  Src/fatfs.c \
  Src/main.c \
  Src/spiflash_w25q16dv.c \
  Src/spisd_diskio.c \
  Src/stm32f1xx_hal_msp.c \
  Src/stm32f1xx_hal_timebase_TIM.c \
  Src/stm32f1xx_it.c \
  Src/usb_host.c \
  Src/usbh_conf.c \
  Src/usbh_diskio.c

CPP_SRCS = \
  Fonts/glcd17x22.cpp \
  Icons/HomeIcons.cpp \
  Icons/KeyIcons.cpp \
  Icons/MiscIcons.cpp \
  Icons/NozzleIcons.cpp \
  Src/Buzzer.cpp \
  Src/Display.cpp \
  Src/FileManager.cpp \
  Src/Mem.cpp \
  Src/MessageLog.cpp \
  Src/Misc.cpp \
  Src/PanelDue.cpp \
  Src/Print.cpp \
  Src/RequestTimer.cpp \
  Src/SerialIo.cpp \
  Src/UTFT.cpp \
  Src/UTouch.cpp \
  Src/UserInterface.cpp

AS_SRCS = \
  Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/startup_stm32f107xc.s

C_OBJS   = $(patsubst %.c,   $(BUILD)/%.o, $(C_SRCS))
CPP_OBJS = $(patsubst %.cpp, $(BUILD)/%.o, $(CPP_SRCS))
AS_OBJS  = $(patsubst %.s,   $(BUILD)/%.o, $(AS_SRCS))
ALL_OBJS = $(C_OBJS) $(CPP_OBJS) $(AS_OBJS)

.PHONY: all clean flash

all: $(BUILD)/$(TARGET).bin

$(BUILD)/$(TARGET).bin: $(BUILD)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@
	$(SIZE) $<
	@echo "Binary: $@"

$(BUILD)/$(TARGET).elf: $(ALL_OBJS)
	$(CXX) $(LDFLAGS) -o $@ $^

$(BUILD)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD)/%.o: %.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

flash: $(BUILD)/$(TARGET).bin
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg \
	  -c "init; reset halt; flash write_image erase $(BUILD)/$(TARGET).bin 0x08000000; reset run; exit"

clean:
	rm -rf $(BUILD)
