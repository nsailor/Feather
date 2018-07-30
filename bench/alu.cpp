#include "Valu.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <stdint.h>
#include <iostream>
using namespace std;

#define CATCH_CONFIG_RUNNER
#include "catch.hpp"

Valu *top;
vluint64_t main_time = 0; ///< Simulation time
VerilatedVcdC *tfp;

double sc_time_stamp() {
    return main_time; // Converts to double, to match SystemC specifications.
}

/**
 * Uses the ALU module to evaluate an ALU operation while adding the result to the
 * trace file.
 * 
 * @param a The first operand.
 * @param b The second operand.
 * @param control The control bits, set on the lower 4 bits of the byte.
 * @param nzcv Location to save the NZCV flag values, on the lower 4 bits.
 * 
 * @return The result returned by the ALU.
 */
int32_t alu_eval_signed(int32_t a, int32_t b, uint8_t control, uint8_t *nzcv) {
    top->a = a;
    top->b = b;
    top->control = control;
    top->eval();
    tfp->dump(main_time);
    main_time++;

    (*nzcv) = top->nzcv;
    return top->y;
}

/**
 * Uses the ALU to evaluate an ALU operation using unsigned integer types.
 * @see alu_eval_signed for more information
 */
uint32_t alu_eval_unsigned(uint32_t a, uint32_t b, uint8_t control, uint8_t *nzcv) {
    return (uint32_t)alu_eval_signed((uint32_t)a, (uint32_t)b, control, nzcv);
}

/// @todo Find a way to not duplicate the constant definitions
/// in C++ and SystemVerilog.
#define ALU_AND 0x0
#define ALU_XOR 0x1
#define ALU_SUB 0x2
#define ALU_RSB 0x3
#define ALU_ADD 0x4
#define ALU_ORR 0xC

#define ALU_N   (1 << 3)
#define ALU_Z   (1 << 2)
#define ALU_C   (1 << 1)
#define ALU_V   (1 << 0)

TEST_CASE("ALU sum works") {
    uint8_t nzcv;
    SECTION("Test positive sums.") {
        CHECK(alu_eval_signed(1, 1, ALU_ADD, &nzcv) == 2);
        CHECK(alu_eval_signed(2, 3, ALU_ADD, &nzcv) == 5);
    }
    
    SECTION("Test signed sum.") {
        CHECK(alu_eval_signed(2, -2, ALU_ADD, &nzcv) == 0);
        CHECK((nzcv & ALU_Z) > 0);
        CHECK(alu_eval_signed(5, -2, ALU_ADD, &nzcv) == 3);
        CHECK((nzcv & ALU_N) == 0);
        CHECK(alu_eval_signed(2, -5, ALU_ADD, &nzcv) == -3);
        CHECK((nzcv & ALU_N) > 0);
    }
    
    SECTION("Test overflow flag.") {
        alu_eval_signed(0x7FFFFFFF, 0x1, ALU_ADD, &nzcv);
        CHECK((nzcv & ALU_V) > 0);
        alu_eval_signed(44, 57, ALU_ADD, &nzcv);
        CHECK((nzcv & ALU_V) == 0);
    }
    
    SECTION("Test carry flag.") {
        CHECK(alu_eval_unsigned(3, 2, ALU_ADD, &nzcv) == 5);
        CHECK((nzcv & ALU_C) == 0);
        CHECK(alu_eval_unsigned(0xFFFFFFFF, 0x2, ALU_ADD, &nzcv) == 0x1);
        CHECK((nzcv & ALU_C) > 0);
    }
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    top = new Valu;
    top->eval();

    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    
    top->trace(tfp, 99);
    std::string vcd_name = argv[0];
    vcd_name += ".vcd";
    tfp->open(vcd_name.c_str());

    int result = Catch::Session().run(argc, argv);

    top->final();
    tfp->close();

    delete tfp;
    delete top;

    return 0;
}