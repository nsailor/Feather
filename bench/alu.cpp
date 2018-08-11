#include <vector>
#include <stdio.h>
#include "testbench.h"
#include "Valu.h"

class TB_ALU : public TB_COMBINATIONAL<Valu> {
public:
    /// @todo Find a way to not duplicate the constant definitions
    /// in C++ and SystemVerilog.
    enum ALU_CONTROL {
        ALU_AND = 0x0,
        ALU_XOR = 0x1,
        ALU_SUB = 0x2,
        ALU_RSB = 0x3,
        ALU_ADD = 0x4,
        ALU_ORR = 0xC
    };

    struct test_case {
        vluint8_t control;
        vluint32_t a;
        vluint32_t b;
        vluint32_t result;
        vluint8_t nzcv;
    };

    enum NZCV_FLAGS {
        N = 0x8,
        Z = 0x4,
        C = 0x2,
        V = 0x1,
    };

    std::vector<test_case> test_vector;

    TB_ALU() {
        test_vector = {{ ALU_ADD, 1, 1, 2, 0x0 },
                       { ALU_ADD, 2, 3, 5, 0x0 },
                       { ALU_ADD, 2, (vluint32_t)-2, 0, Z | C },
                       { ALU_ADD, 5, (vluint32_t)-2, 3, C },
                       { ALU_ADD, 2, (vluint32_t)-5, (vluint32_t)-3, N },
                       { ALU_ADD, 0x7FFFFFFF, 0x1, 0x80000000, N | V },
                       { ALU_ADD, 0xFFFFFFFF, 0x2, 0x1, C },
                       { ALU_SUB, 5, 3, 2, C },
                       { ALU_SUB, 365, 55, 310, C },
                       { ALU_SUB, 16, 16, 0, Z | C },
                       { ALU_SUB, 3, 10, (vluint32_t)-7, N },
                       { ALU_RSB, 3, 5, 2, C },
                       { ALU_AND, 0x3, 0x2, 0x2, 0x0 },
                       { ALU_AND, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, N | C },
                       { ALU_ORR, 0x1, 0x2, 0x3, 0x0 },
                       { ALU_ORR, 0xA3F4, 0x0, 0xA3F4, 0x0 },
                       { ALU_XOR, 0x1, 0x3, 0x2, 0x0 },
                       { ALU_XOR, 0xA3F4, 0xA3F4, 0x0, Z }};
    }

    bool verify() {
        for (test_case t : test_vector) {
            m_dut->control_i = t.control;
            m_dut->operand_a_i = t.a;
            m_dut->operand_b_i = t.b;
            tick();
            if ((m_dut->result_o != t.result)
                || (m_dut->nzcv_o != t.nzcv)) {
                printf("Test failed.\n");
                tick();
                return false;
            }
        }
        tick(); // Get the final test case in the trace dump.
        return true;
    }
};

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    TB_ALU tb;
    tb.opentrace("out.vcd");
    return tb.verify() ? 0 : 1;
}
