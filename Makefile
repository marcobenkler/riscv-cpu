TOOLCHAIN := riscv64-unknown-elf
TESTS_DIR := ../riscv_test/picorv32/tests
SCRIPTS   := scripts
BUILD     := build

RTL_FILES := $(shell find rtl -name "*.sv" -not -path "*/muldiv/*")
TB_FILES  := tb/core/tb_sc_cpu.sv

TEST ?= add

.PHONY: sim compile clean

sim: tb/core/program.hex
	verilator --binary --trace -sv --top-module tb_sc_cpu \
	    -Wno-TIMESCALEMOD \
	    -Mdir obj_dir \
	    $(RTL_FILES) $(TB_FILES)
	./obj_dir/Vtb_sc_cpu

compile: tb/core/program.hex

tb/core/program.hex: $(BUILD)/$(TEST).bin
	python3 -c "import sys; data=open('$<','rb').read(); sys.stdout.write('\n'.join('%02x' % b for b in data) + '\n')" > $@

$(BUILD)/$(TEST).bin: $(BUILD)/$(TEST).elf
	$(TOOLCHAIN)-objcopy -O binary $< $@

$(BUILD)/$(TEST).elf: $(TESTS_DIR)/$(TEST).S $(SCRIPTS)/start.S $(SCRIPTS)/link.ld | $(BUILD)
	$(TOOLCHAIN)-gcc -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles \
	    -I$(TESTS_DIR) \
	    -DTEST_FUNC_NAME=$(TEST) \
	    '-DTEST_FUNC_TXT="$(TEST)"' \
	    -DTEST_FUNC_RET=test_ret \
	    $(TESTS_DIR)/$(TEST).S $(SCRIPTS)/start.S \
	    -T $(SCRIPTS)/link.ld \
	    -o $@

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD) obj_dir tb/core/program.hex sim/cpu.vcd
