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
    top->operand_a_i = a;
    top->operand_b_i = b;
    top->control_i = control;
    top->eval();
    tfp->dump(main_time);
    main_time++;

    (*nzcv) = top->nzcv_o;
    return top->result_o;
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

TEST_CASE("ALU subtraction works") {
    uint8_t nzcv;
    SECTION("Test unsigned") {
        CHECK(alu_eval_unsigned(5, 3, ALU_SUB, &nzcv) == 2);
        CHECK(alu_eval_unsigned(365, 55, ALU_SUB, &nzcv) == (365 - 55));
        CHECK(alu_eval_unsigned(16, 16, ALU_SUB, &nzcv) == 0);
        CHECK((nzcv & ALU_Z) > 0);
    }

    SECTION("Test signed") {
        CHECK(alu_eval_signed(3, 10, ALU_SUB, &nzcv) == -7);
        CHECK((nzcv & ALU_N) > 0);
        CHECK(alu_eval_signed(-3, 2, ALU_SUB, &nzcv) == -5);
        CHECK(alu_eval_signed(-5, -10, ALU_SUB, &nzcv) == 5);
    }

    SECTION("Test reverse subtraction") {
        CHECK(alu_eval_unsigned(3, 5, ALU_RSB, &nzcv) == 2);
        CHECK(alu_eval_signed(2, -3, ALU_RSB, &nzcv) == -5);
    }
}

TEST_CASE("Logic operations work") {
    uint8_t nzcv;
    SECTION("AND works") {
        CHECK(alu_eval_unsigned(0x3, 0x2, ALU_AND, &nzcv) == 0x2); // 11 & 10 => 10
        CHECK(alu_eval_unsigned(0xDEADBEEF, 0xDEADBEEF, ALU_AND, &nzcv) == 0xDEADBEEF);
    }

    SECTION("OR works") {
        CHECK(alu_eval_unsigned(0x1, 0x2, ALU_ORR, &nzcv) == 0x3); // 01 | 10 => 11
        CHECK(alu_eval_unsigned(0xA3F4, 0x0, ALU_ORR, &nzcv) == 0xA3F4);
    }

    SECTION("XOR works") {
        CHECK(alu_eval_unsigned(0x1, 0x3, ALU_XOR, &nzcv) == 0x2); // 01 xor 11 => 10
        CHECK(alu_eval_unsigned(0xA3F4, 0xA3F4, ALU_XOR, &nzcv) == 0x0);
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