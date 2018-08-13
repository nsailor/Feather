#include <stdio.h>
#include "testbench.h"
#include "Vprogram_memory.h"

class TB_PROGRAM_MEMORY : public TB_COMBINATIONAL<Vprogram_memory> {
public:
    void dump_contents() {
        for (int i = 0; i < 4; i++) {
            m_dut->address_i = i * 4;
            tick();
            printf("%08x\n", m_dut->instruction_o);
        }
        tick();
    }
};

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    TB_PROGRAM_MEMORY tb;
    tb.opentrace("out.vcd");
    tb.dump_contents();
    return 0;
}
