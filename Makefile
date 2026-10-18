TOOLCHAIN := riscv64-unknown-elf
TESTS_DIR := ../riscv-tools/riscv-tests/isa
BUILD     := build

RTL_PKG_FILES   := $(shell find rtl -name "*_pkg.sv")
RTL_OTHER_FILES := $(shell find rtl -name "*.sv" ! -name "*_pkg.sv" ! -name "sc_cpu.sv")
RTL_FILES       := $(RTL_PKG_FILES) $(RTL_OTHER_FILES)
TB_FILES        := verify/tb/pipeline/tb_pl_cpu.sv

TEST ?= rv32ui-p-add

RV32UI := add addi and andi auipc beq bge bgeu blt bltu bne fence_i jal jalr \
          lb lbu ld_st lh lhu lui lw ma_data or ori sb sh simple sll slli     \
          slt slti sltiu sltu sra srai srl srli st_ld sub sw xor xori

RV32UM := div divu mul mulh mulhsu mulhu rem remu

RV32MI := csr illegal lh-misaligned lw-misaligned ma_addr ma_fetch mcsr \
          sbreak scall sh-misaligned shamt sw-misaligned

ALL_TESTS := $(addprefix rv32ui-p-,$(RV32UI)) \
             $(addprefix rv32um-p-,$(RV32UM)) \
             $(addprefix rv32mi-p-,$(RV32MI))

.PHONY: sim verilate test-all rv32ui rv32um rv32mi _run_tests clean

sim: verilate $(BUILD)/$(TEST).hex
	./obj_dir/Vtb_pl_cpu +itest=$(BUILD)/$(TEST).hex +dtest=$(BUILD)/$(TEST).hex

verilate:
	verilator --binary --trace-structs --trace-fst -sv --top-module tb_pl_cpu \
	    -Wno-TIMESCALEMOD \
	    -Mdir obj_dir \
	    $(RTL_FILES) $(TB_FILES)

$(BUILD)/$(TEST).hex: $(BUILD)/$(TEST).bin | $(BUILD)
	python3 -c "import sys; d=open('$<','rb').read(); d+=b'\x00'*((-len(d))%4); \
	    sys.stdout.write('\n'.join(f'{int.from_bytes(d[i:i+4],\"little\"):08x}' for i in range(0,len(d),4))+'\n')" > $@

$(BUILD)/$(TEST).bin: $(TESTS_DIR)/$(TEST) | $(BUILD)
	$(TOOLCHAIN)-objcopy -O binary $< $@

$(BUILD):
	mkdir -p $(BUILD)

rv32ui: verilate
	@$(MAKE) --no-print-directory _run_tests SUITE="$(addprefix rv32ui-p-,$(RV32UI))"

rv32um: verilate
	@$(MAKE) --no-print-directory _run_tests SUITE="$(addprefix rv32um-p-,$(RV32UM))"

rv32mi: verilate
	@$(MAKE) --no-print-directory _run_tests SUITE="$(addprefix rv32mi-p-,$(RV32MI))"

test-all: verilate
	@$(MAKE) --no-print-directory _run_tests SUITE="$(ALL_TESTS)"

_run_tests:
	@pass=0; fail=0; \
	for test in $(SUITE); do \
		$(MAKE) -B --no-print-directory "$(BUILD)/$$test.hex" TEST=$$test > /dev/null 2>&1; \
		result=$$(./obj_dir/Vtb_pl_cpu +itest=$(BUILD)/$$test.hex +dtest=$(BUILD)/$$test.hex 2>&1); \
		if echo "$$result" | grep -q "^PASS"; then \
			printf "\033[1;32mPASS\033[0m  $$test\n"; pass=$$((pass+1)); \
		else \
			printf "\033[1;31mFAIL\033[0m  $$test\n"; fail=$$((fail+1)); \
		fi; \
	done; \
	echo ""; echo "$$pass passed, $$fail failed out of $$((pass+fail)) tests"


SRCS_imm_gen := rtl/core/decode/imm_gen.sv
SRCT_imm_gen := verify/assertions/core/decode/assert_imm_gen.sv

SRCT_uart_baud := verify/tb/external/tb_uart_baud.sv
SRCT_uart_tx := verify/tb/external/tb_uart_tx.sv
SRCT_uart := verify/tb/external/tb_uart.sv

SRCT_fwd_integration := \
	verify/tb/pipeline/tb_fwd_integration.sv \
	verify/assertions/pipeline/assert_fwd_integration.sv \
	verify/bind/fwd_bind.sv

SRCT_hazard_integration :=	\
	verify/tb/pipeline/tb_hazard_integration.sv	\
	verify/assertions/pipeline/assert_hazard_integration.sv \
	verify/bind/hazard_bind.sv


sim-%:
	verilator --binary --trace-fst --assert --trace-structs --sv --coverage \
		-Wno-DECLFILENAME \
		-Wno-SYNCASYNCNET \
		-Wno-UNUSEDSIGNAL \
		-Wno-UNUSEDPARAM \
		-Wno-UNDRIVEN \
		-Mdir obj_dir -o sim_$* \
		$(RTL_PKG_FILES) $(RTL_OTHER_FILES) $(SRCT_$*) \
		--top-module tb_$*
	./obj_dir/sim_$*
	verilator_coverage --annotate logs/coverage_$* coverage.dat
	mv coverage.dat logs/coverage_$*.dat

### UVM ###

UVM_TOP := tb_uart_loopback
TEST := uart_loopback_test
OBJ := ./obj_dir/$(UVM_TOP)
FILES := verify/uvm/hvl/tests/uart/files_loopback.f

VFLAGS := --binary \
	  --timing \
	  --top-module $(UVM_TOP) \
          --Mdir $(OBJ) \
          --timescale 1ns/1ps \
          -j 6 \
          +incdir+$(UVM_HOME) \
          +incdir+$(CURDIR) \
          +define+UVM_NO_DPI \
          --coverage-user \
          --coverage-line \
          --coverage-toggle \
          -Wno-fatal \
          --error-limit 500 \
	  -f $(FILES)

.PHONY: build run clean

uvm_build:
	mkdir -p $(OBJ)
	verilator $(VFLAGS)

uvm: clean uvm_build
	$(OBJ)/V$(UVM_TOP) +UVM_TESTNAME=$(TEST)
	verilator_coverage --annotate annotated --annotate-all --annotate-points --annotate-min 1 coverage.dat

clean:
	rm -rf build obj_dir annotated coverage.dat coverage.info *.fst *.log

### FREERTOS ###
CROSS := riscv64-unknown-elf-
CC := $(CROSS)gcc
OBJCOPY := $(CROSS)objcopy
OBJDUMP := $(CROSS)objdump
SIZE := $(CROSS)size

#In official GNU, march for the machine architecture,
#mabi for machine application binary interface (how big are datatypes, pointer etc)
AARCH := -march=rv32i_zicsr -mabi=ilp32

TARGET   := firmware
BUILD_OS := build_os
FREERTOS := freertos/kernel
BSP := freertos/bsp
PORT 	 = $(FREERTOS)/portable/GCC/RISC-V

SRCS += $(wildcard $(FREERTOS)/portable/*.c)
SRCS += $(BSP)/start.S
SRCS += $(FREERTOS)/portable/MemMang/heap_1.c
SRCS += $(PORT)/port.c
SRCS += $(PORT)/portASM.S
SRCS += $(wildcard freertos/app/*.c)

# Declare what files are needed. basenam: remove ending, addsuffix: add ending, addprefix ...
OBJS := $(addprefix $(BUILD_OS)/, $(addsuffix .o, $(basename $(SRCS))))

# Og: optimize, but keep it readable for debugging. g: debug infos in the .elf file
# Wall: Enable All Warnings
CFLAGS += $(AARCH) -Og -g -Wall
#sections: Each function and data gehts own section => Linker can throw away unused
CFLAGS += -ffunction-sections -fdata-sections
#MMD MP: Create .d file so make builds again, if header changes
CFLAGS += -MMD -MP
CFLAGS += -I$(FREERTOS)/include
CFLAGS += -I$(PORT)
CFLAGS += -I$(PORT)/chip_specific_extension/RISCV_MTIME_CLINT_no_extensions
CFLAGS += -Ifreertos/app

#-T link.ld: Use this link script. nostartfiles: Exclude default start.S file, got my own
LDFLAGS += $(ARCH) -T $(BSP)/link.ld -nostartfiles
#gc-section: garbage collect unused sections, Map: Build map file that is a great overview
#Wl: GCC doesnt know all linker options, so don't throw error, just pass to linker
LDFLAGS += -Wl,--gc-sections -Wl,-Map=$(BUILD)/$(TARGET).map

# Define Goal: make sees this and walks recursively mem -> bin -> elf -> .o -> .c
os: $(BUILD_OS)/$(TARGET).mem $(BUILD_OS)/$(TARGET).dis

$(BUILD_OS)/%.o: %.c
# @ before terminal command just makes it invisible for better overview
# $@ is goal of the rule (whats left of ":" in our case %.o), i.e. buidl_os/app/main.o
# $< is first requirement (whats right of ":" in our case %.c), i.e. app/main.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_OS)/%.o: %.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_OS)/$(TARGET).elf: $(OBJS)
# $^ all requirements (right side of ":")
	$(CC) $(LDFLAGS) $^ -o $@
	$(SIZE) $@

$(BUILD_OS)/$(TARGET).bin: $(BUILD_OS)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(BUILD_OS)/$(TARGET).mem: $(BUILD_OS)/$(TARGET).bin
	od -An -v -tx4 -w4 $< | tr -d ' ' > $@

$(BUILD_OS)/$(TARGET).dis: $(BUILD_OS)/$(TARGET).elf
	$(OBJDUMP) -d $< > $@

-include $(OBJS:.o=.d)

clean_os:
	rm -rf $(BUILD_OS)

.PHONY: os, clean_os
