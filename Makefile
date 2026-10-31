.PHONY: all pdf test-zig test-nand test-c sim-fpga clean

all: test-nand test-c

test-nand:
	uv run --script src/fibonacci_nand_ternary.py

test-zig:
	zig test src/ultradreamstate_simd.zig

test-c:
	gcc -Wall -Wextra -Werror -std=c11 -fsyntax-only hardware/flug_os_esp32s3_kernel.h

sim-fpga:
	verilator --lint-only -Wall hardware/eightb_complex_ternary_pe64.sv hardware/omni_vietnam_axi_ternary_core.sv

pdf:
	cd paper && lualatex -interaction=nonstopmode ultradreamstate_8b_paper.tex && lualatex -interaction=nonstopmode ultradreamstate_8b_paper.tex

clean:
	rm -f paper/*.aux paper/*.log paper/*.out
