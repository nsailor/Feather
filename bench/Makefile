.PHONY: all
RTL_SRC=../rtl
all: alu

LDFLAGS=
CFLAGS=-g -O3 -std=c++11 -faligned-new

ARM_CC=arm-none-eabi-gcc
ARM_AS=arm-none-eabi-as
ARM_OBJCOPY=arm-none-eabi-objcopy

test-program:
	${ARM_AS} tests/test.s -o tests/test
	${ARM_OBJCOPY} -O verilog tests/test tests/test.vhex
	rm tests/test

verify: verify-alu verify-reg_file verify-program_memory

verify-%:
	verilator -Wno-fatal -I$(RTL_SRC)/ --cc $(*) --trace --exe ../$(*).cpp \
		-Mdir sim_$(*) -CFLAGS "$(CFLAGS)" --top-module $(*)
	make -C sim_$(*) -f V$(*).mk
	sim_$(*)/V$(*)

synth-%:
	yosys -p "prep; proc; opt; fsm; opt; show -prefix ./$(*) -format ps" $(RTL_SRC)/$(*).sv
	dot -Tpng ./$(*).dot > $(*).png
	rm *.dot *.dot.pid

clean:
	rm -rf *.o sim_*

distclean: clean
	rm -rf *~ *.txt *.vcd *.mif *.orig *.png tests/*.vhex
