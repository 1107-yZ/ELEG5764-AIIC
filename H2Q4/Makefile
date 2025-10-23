# Makefile for Sum Calculator Project

# 工具设置
VCS = vcs
VERDI = verdi
SIMV = ./simv

# 编译选项
VCS_OPTS = -full64 -sverilog +v2k -debug_access+all -kdb -lca +define+VCS -timescale=1ns/1ps

# 源文件
RTL_SRC = rtl/sum_calculator.sv
TB_SRC = tb/testbench.sv
ALL_SRC = $(RTL_SRC) $(TB_SRC)

# 目标
all: compile simulate

compile:
	@echo "Compiling design..."
	$(VCS) $(VCS_OPTS) $(ALL_SRC) -o simv -l compile.log

simulate:
	@echo "Running simulation..."
	$(SIMV) +vcdpluson -l simulation.log

verdi:
	@echo "Launching Verdi..."
	$(VERDI) -sv -f $(RTL_SRC) -f $(TB_SRC) -ssf waveforms.vpd &

clean:
	rm -rf simv* csrc* *.log *.vpd *.key *.fsdb verdiLog novas.* ucli*

help:
	@echo "Available targets:"
	@echo "  all      : Compile and simulate"
	@echo "  compile  : Compile the design"
	@echo "  simulate : Run simulation"
	@echo "  verdi    : Launch Verdi for waveform viewing"
	@echo "  clean    : Clean generated files"
	@echo "  help     : Show this help message"

.PHONY: all compile simulate verdi clean help
