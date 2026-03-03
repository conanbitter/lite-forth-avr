PROJECT = lfa

F_CPU = 16000000
MCU = atmega328p
ARCH = avr5
MACHINE = uno
UART_ECHO = 1

FILES = main.S dictionary.S errors.S uart.S io.S divmul.S core.S asmcodes.S

# Common section

# Directories
BUILD_DIR = build
SRC_DIR = src

# Compilers and other
AS := avr-gcc
LINKER := avr-gcc
OBJCOPY := avr-objcopy
AVRSIZE := avr-size
QEMU := qemu-system-avr

# File lists
OBJS := $(patsubst %.S,$(BUILD_DIR)/release/%.o,$(FILES))
OBJS_DEBUG := $(patsubst %.S,$(BUILD_DIR)/debug/%.o,$(FILES))

# Compiler setings
INC_FLAG := -I$(SRC_DIR)
ASFLAGS := $(INC_FLAG) -DF_CPU=$(F_CPU) -DUART_ECHO=$(UART_ECHO) -mmcu=$(MCU) -x assembler-with-cpp -c -nostdlib -nostartfiles
ASFLAGS_DEBUG := $(ASFLAGS) -g -Wa,--gstabs -Wa,-g
LDFLAGS := $(INC_FLAG) -mmcu=$(MCU) -nostdlib -nostartfiles # -m $(ARCH) 

#Targets

.PHONY: clean build debug qemu qemu_debug

clean:
	del /q /s $(BUILD_DIR)\*

# ======== DEBUG

debug:  $(BUILD_DIR)/debug/$(PROJECT).elf

qemu_debug:  $(BUILD_DIR)/debug/$(PROJECT).elf
	$(QEMU) -machine $(MACHINE) -bios $(BUILD_DIR)/debug/$(PROJECT).elf -s -S -monitor stdio

$(BUILD_DIR)/debug/$(PROJECT).elf: $(OBJS_DEBUG)
	$(LINKER) $(OBJS_DEBUG) -o $@ $(LDFLAGS)

$(BUILD_DIR)/debug/%.o: $(SRC_DIR)/%.S | $(BUILD_DIR)/debug
	@if not exist $(BUILD_DIR)\\NUL mkdir $(BUILD_DIR)
	$(AS) $(ASFLAGS_DEBUG) -o $@ -Wa,-alm=$@.lst $<

$(BUILD_DIR)/debug:
	mkdir $(BUILD_DIR)\debug

# ======== RELEASE

build: $(BUILD_DIR)/$(PROJECT).hex

$(BUILD_DIR)/$(PROJECT).hex: $(BUILD_DIR)/release/$(PROJECT).elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $(BUILD_DIR)/$(PROJECT).hex

$(BUILD_DIR)/release/$(PROJECT).elf: $(OBJS)
	$(LINKER) $(OBJS) -o $@ $(LDFLAGS)
	$(AVRSIZE) -C --mcu=$(MCU) $@

$(BUILD_DIR)/release/%.o: $(SRC_DIR)/%.S | $(BUILD_DIR)/release
	@if not exist $(BUILD_DIR)\\NUL mkdir $(BUILD_DIR)
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/release:
	mkdir $(BUILD_DIR)\release

# ======== QEMU RUN

qemu:  $(BUILD_DIR)/debug/$(PROJECT).elf
	$(QEMU) -machine $(MACHINE) -bios $(BUILD_DIR)/debug/$(PROJECT).elf -monitor stdio














