.PHONY: all
RTL_SRC=../rtl
all: alu

LDFLAGS=
CFLAGS=-g -O3 -std=c++11 -faligned-new

%:
	verilator -Wno-fatal -I$(RTL_SRC)/ --cc $(@) --trace --exe ../$(@).cpp -Mdir sim_$(@) -CFLAGS "$(CFLAGS)"
	make -C sim_$(@) -f V$(@).mk

synth-%:
	yosys -p "prep; proc; opt; fsm; opt; show -prefix ./$(*)" $(RTL_SRC)/$(*).sv
	dot -Tpng ./$(*).dot > $(*).png
	rm *.dot *.dot.pid

clean:
	rm -rf *.o sim_*

distclean: clean
	rm -rf *~ *.txt *.vcd *.mif *.orig *.png
