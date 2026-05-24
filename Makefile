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
	./obj_dir/Vtb_pl_cpu +test=$(BUILD)/$(TEST).hex

verilate:
	verilator --binary --trace -sv --top-module tb_pl_cpu \
	    -Wno-TIMESCALEMOD \
	    -Mdir obj_dir \
	    $(RTL_FILES) $(TB_FILES)

$(BUILD)/$(TEST).hex: $(BUILD)/$(TEST).bin | $(BUILD)
	python3 -c "import sys; data=open('$<','rb').read(); \
	    sys.stdout.write('\n'.join('%02x' % b for b in data) + '\n')" > $@

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
		result=$$(./obj_dir/Vtb_pl_cpu +test=$(BUILD)/$$test.hex 2>&1); \
		if echo "$$result" | grep -q "^PASS"; then \
			printf "\033[1;32mPASS\033[0m  $$test\n"; pass=$$((pass+1)); \
		else \
			printf "\033[1;31mFAIL\033[0m  $$test\n"; fail=$$((fail+1)); \
		fi; \
	done; \
	echo ""; echo "$$pass passed, $$fail failed out of $$((pass+fail)) tests"

clean:
	rm -rf $(BUILD) obj_dir

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