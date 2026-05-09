TOOLCHAIN := riscv64-unknown-elf
TESTS_DIR := ../riscv_test/picorv32/tests
SCRIPTS   := scripts
BUILD     := build

RTL_FILES := $(shell find rtl -name "*.sv" -not -path "*/srt2/*")
TB_FILES  := tb/core/tb_sc_cpu.sv

TEST ?= add

ALL_TESTS := add addi and andi auipc beq bge bgeu blt bltu bne div divu j jal jalr \
             lb lbu lh lhu lui lw mul mulh mulhsu mulhu or ori rem remu sb sh simple \
             sll slli slt slti sra srai srl srli sub sw xor xori

.PHONY: sim compile clean test-all

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
	$(TOOLCHAIN)-gcc -march=rv32im -mabi=ilp32 -nostdlib -nostartfiles \
	    -I$(TESTS_DIR) \
	    -DTEST_FUNC_NAME=$(TEST) \
	    '-DTEST_FUNC_TXT="$(TEST)"' \
	    -DTEST_FUNC_RET=test_ret \
	    $(TESTS_DIR)/$(TEST).S $(SCRIPTS)/start.S \
	    -T $(SCRIPTS)/link.ld \
	    -o $@

$(BUILD):
	mkdir -p $(BUILD)

test-all:
	verilator --binary --trace -sv --top-module tb_sc_cpu \
	    -Wno-TIMESCALEMOD \
	    -Mdir obj_dir \
	    $(RTL_FILES) $(TB_FILES)
	@pass=0; fail=0; \
	for test in $(ALL_TESTS); do \
		if ! $(MAKE) -B --no-print-directory compile TEST=$$test > /dev/null 2>&1; then \
			printf "\033[1;31mFAIL\033[0m  $$test  (compile error)\n"; fail=$$((fail+1)); \
		else \
			result=$$(./obj_dir/Vtb_sc_cpu 2>&1); \
			if echo "$$result" | grep -q "TIMEOUT"; then \
				printf "\033[1;31mFAIL\033[0m  $$test\n"; fail=$$((fail+1)); \
			else \
				printf "\033[1;32mPASS\033[0m  $$test\n"; pass=$$((pass+1)); \
			fi; \
		fi; \
	done; \
	echo ""; echo "$$pass passed, $$fail failed out of $$((pass+fail)) tests"

clean:
	rm -rf $(BUILD) obj_dir tb/core/program.hex sim/cpu.vcd
