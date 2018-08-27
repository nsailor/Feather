#include "Vprogram_memory.h"
#include "testbench.h"
#include <stdio.h>

class TB_PROGRAM_MEMORY : public TB_COMBINATIONAL<Vprogram_memory>
{
public:
  void dump_contents()
  {
    for (int i = 0; i < 256; i++) {
      m_dut->address_i = i * 4;
      tick();
      printf("%02x: %08x\n", i, m_dut->instruction_o);
    }
    tick();
  }
};

int
main(int argc, char** argv)
{
  Verilated::commandArgs(argc, argv);
  TB_PROGRAM_MEMORY tb;
  tb.opentrace("out.vcd");
  tb.dump_contents();
  return 0;
}
