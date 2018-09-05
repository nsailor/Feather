#include "testbench.h"
#include "Vcore.h"

class TB_CORE : public TB_SEQUENTIAL<Vcore>
{
public:
  bool run_program()
  {
    m_dut->reset_i = 1;
    tick();
    m_dut->reset_i = 0;
    const int max_cycles = 100;
    while (!Verilated::gotFinish() && (tick_count() <= max_cycles * 2)) {
      tick();
      dump_registers();
    }
    return true;
  }

  void dump_registers()
  {
    for (int i = 0; i < 16; i++) {
      printf("R%d: %x%c",
        i,
        m_dut->core__DOT__u_reg_file__DOT__registers[i],
        (i == 15) ? '\n' : '\t');
    }
  }
};

int
main(int argc, char** argv)
{
  Verilated::commandArgs(argc, argv);
  TB_CORE tb;
  tb.opentrace("out.vcd");
  return tb.run_program() ? 0 : 1;
}
