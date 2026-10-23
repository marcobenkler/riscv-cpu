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


################
### FREERTOS ###
################
# Build mem and elf files for freertos boot
################

CROSS := riscv64-unknown-elf-
CC := $(CROSS)gcc
OBJCOPY := $(CROSS)objcopy
OBJDUMP := $(CROSS)objdump
SIZE := $(CROSS)size

#In official GNU, march for the machine architecture,
#mabi for machine application binary interface (how big are datatypes, pointer etc)
AARCH := -march=rv32im_zicsr -mabi=ilp32

TARGET   := firmware
BUILD_OS := build_os
FREERTOS := freertos/kernel
BSP := freertos/bsp
PORT 	 = $(FREERTOS)/portable/GCC/RISC-V

SRCS += $(wildcard $(FREERTOS)/*.c)
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
#sections: Each function and data gets own section => Linker can throw away unused
CFLAGS += -ffunction-sections -fdata-sections
#MMD MP: Create .d file so make builds again, if header changes
CFLAGS += -MMD -MP
CFLAGS += -I$(FREERTOS)/include
CFLAGS += -I$(PORT)
CFLAGS += -I$(PORT)/chip_specific_extensions/RISCV_MTIME_CLINT_no_extensions
CFLAGS += -Ifreertos/app

#-T link.ld: Use this link script. nostartfiles: Exclude default start.S file, got my own
LDFLAGS += $(AARCH) -T $(BSP)/link.ld -nostartfiles
#gc-section: garbage collect unused sections, Map: Build map file that is a great overview
#Wl: GCC doesnt know all linker options, so don't throw error, just pass to linker
LDFLAGS += -Wl,--gc-sections -Wl,-Map=$(BUILD_OS)/$(TARGET).map

# Define Goal: make sees this and walks recursively mem -> bin -> elf -> .o -> .c
os: $(BUILD_OS)/imem.mem $(BUILD_OS)/dmem.mem $(BUILD_OS)/$(TARGET).dis

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

# j: only copy these sections => one image per memory, no gap between IMEM and DMEM
$(BUILD_OS)/imem.bin: $(BUILD_OS)/$(TARGET).elf
	$(OBJCOPY) -O binary -j .init -j .text $< $@

$(BUILD_OS)/dmem.bin: $(BUILD_OS)/$(TARGET).elf
	$(OBJCOPY) -O binary -j .rodata -j .data $< $@

# % matches imem and dmem, so one rule for both
$(BUILD_OS)/%.mem: $(BUILD_OS)/%.bin
	god -An -v -tx4 -w4 $< | tr -d ' ' > $@

$(BUILD_OS)/$(TARGET).dis: $(BUILD_OS)/$(TARGET).elf
	$(OBJDUMP) -d $< > $@

-include $(OBJS:.o=.d)

clean_os:
	rm -rf $(BUILD_OS)

.PHONY: os, clean_os


############################
########## COSIM ###########
############################
# Build mem and elf file for offline lockstep with spike
############################

CROSS_COSIM 	:= riscv64-unknown-elf-
CC_COSIM 	:= $(CROSS)gcc
OBJCOPY_COSIM 	:= $(CROSS)objcopy
OBJDUMP_COSIM	:= $(CROSS)objdump
SIZE_COSIM 	:= $(CROSS)size

AARCH_COSIM 	:= -march=rv32im_zicsr -mabi=ilp32

TARGET_COSIM 	:= cosim
BUILD_COSIM 	:= build_cosim
COSIM_SRC	:= verify/cosim
SW_SRC		:= $(COSIM_SRC)/code
SPIKE		:= $(COSIM_SRC)/spike

SRCS_COSIM += $(wildcard $(SW_SRC)/*.c)
SRCS_COSIM += $(SPIKE)/start.S

OBJS_COSIM := $(addprefix $(BUILD_COSIM)/, $(addsuffix .o, $(basename $(SRCS_COSIM))))

CFLAGS_COSIM += $(AARCH_COSIM) -Og -g -Wall
CFLAGS_COSIM += -ffunction-sections -fdata-sections
CFLAGS_COSIM += -MMD -MP
CFLAGS_COSIM += -I$(SW_SRC)

LDFLAGS_COSIM += $(AARCH_COSIM) -T $(SPIKE)/link.ld -nostartfiles

LDFLAGS_COSIM += -Wl,--gc-sections,-Map=$(BUILD_COSIM)/$(TARGET_COSIM).map

cosim_build: $(BUILD_COSIM)/imem.mem $(BUILD_COSIM)/dmem.mem $(BUILD_COSIM)

$(BUILD_COSIM)/%.o : %.c
	@mkdir -p $(dir $@)
	$(CC_COSIM) $(CFLAGS_COSIM) -c $< -o $@

$(BUILD_COSIM)/%.o : %.S
	@mkdir -p $(dir $@)
	$(CC_COSIM) $(CFLAGS_COSIM) -c $< -o $@

$(BUILD_COSIM)/$(TARGET_COSIM).elf: $(OBJS_COSIM)
	$(CC_COSIM) $(LDFLAGS_COSIM) $^ -o $@
	$(SIZE_COSIM) $@

$(BUILD_COSIM)/imem.bin: $(BUILD_COSIM)/$(TARGET_COSIM).elf
	$(OBJCOPY_COSIM) -O binary -j .init -j .text $< $@

$(BUILD_COSIM)/dmem.bin: $(BUILD_COSIM)/$(TARGET_COSIM).elf
	$(OBJCOPY_COSIM) -O binary -j .rodata -j .data $< $@

$(BUILD_COSIM)/%.mem: $(BUILD_COSIM)/%.bin
	god -An -v -tx4 -w4 $< | tr -d ' ' > $@

$(BUILD_COSIM)/$(TARGET_COSIM).dis: $(BUILD_COSIM)/$(TARGET_COSIM).elf
	$(OBJDUMP_COSIM) -d $< > $@

-include $(OBJS_COSIM:.o=.d)

clean_cosim_build:
	rm -rf $(BUILD_COSIM)

.PHONY: cosim_build, clean_cosim_build


#####################################

### Execute spike with built elf, execute uvm run, compare with python

#####################################

#### Execute Spike ####

COSIM_RES := cosim
SPIKE_SRG := -m0x10000:0x4000,0x80000000:0x8000 #imem from 0x10000 4000 big, dmem from 800... 8000 big
SPIKE_CMD := --log-commits --isa=rv32im_zicsr $(SPIKE_SRG)

$(COSIM_RES)/spike_commits.log: $(BUILD_COSIM)/$(TARGET_COSIM).elf
	@mkdir -p $(COSIM_RES)
	spike $(SPIKE_CMD) $< 2> $@


# add python script as requirement, so it checks spike.jsonl against logtojsonl.py, if .py is newer, jsonl should be created again
# tldr: make recognises changes in source
$(COSIM_RES)/spike.jsonl: $(COSIM_RES)/spike_commits.log $(COSIM_SRC)/scripts/spike_logtojsonl.py
	python $(COSIM_SRC)/scripts/spike_logtojsonl.py



#### Execute UVM RTL ####

UVM_TOP_LOCKSTEP := tb_cosim
TEST_LOCKSTEP := cosim_test
OBJ_LOCKSTEP := $(COSIM_RES)/$(UVM_TOP_LOCKSTEP)
FILES_LOCKSTEP := verify/uvm/hvl/tests/cosim/files_cosim.f

VFLAGS_LOCKSTEP := --binary \
	  --timing \
	  --top-module $(UVM_TOP_LOCKSTEP) \
          --Mdir $(OBJ_LOCKSTEP) \
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
	  -f $(FILES_LOCKSTEP)

$(COSIM_RES)/rtl.jsonl: $(BUILD_COSIM)/imem.mem $(BUILD_COSIM)/dmem.mem
	@mkdir -p $(OBJ_LOCKSTEP)
	verilator $(VFLAGS_LOCKSTEP)
#+IMEM= .. testbench can read files via $value$plusargs and put the path in $readmem => Sim and Synth both valid
#currently mem are read directly in the mem module and plusargs are not used for first testing
	$(OBJ_LOCKSTEP)/V$(UVM_TOP_LOCKSTEP) +UVM_TESTNAME=$(TEST_LOCKSTEP) \
	+TRACE=$@ +IMEM=$(BUILD_COSIM)/imem.mem +DMEM=$(BUILD_COSIM)/dmem.mem
	verilator_coverage --annotate annotated --annotate-all --annotate-points --annotate-min 1 coverage.dat

cosim: clean_cosim $(COSIM_RES)/spike.jsonl $(COSIM_RES)/rtl.jsonl

clean_cosim:
	rm -rf $(COSIM_RES)

.PHONY: cosim clean_cosim

#Delete the target, if a part fails, like spike exits wrong, commit.log is deleted
.DELETE_ON_ERROR: