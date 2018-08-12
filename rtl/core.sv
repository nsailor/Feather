`include "alu.sv"
`include "reg_file.sv"
`include "program_memory.sv"
`include "memory.sv"
`include "immediate_shifter.sv"

module core(input logic clk,
            input logic reset_i);
    logic [7:0] pc;
    logic [31:0] instruction;

    // Whether the instruction should be executed at all.
    // It should be AND'ed with any write enable signal.
    logic condition_result;

    // Update the program counter.
    logic next_pc = reset_i ? 0 : pc + 4;
    always @(posedge clk) begin
        pc = next_pc;
    end

    program_memory u_program_memory(
        .address_i(pc),
        .instruction_o(instruction)
    );

    logic [3:0] alu_control;
    logic [31:0] alu_input_a;
    logic [31:0] alu_input_b;
    logic [31:0] alu_result;
    logic [3:0] alu_nzcv;

    alu u_alu(
        .control_i(alu_control),
        .operand_a_i(alu_input_a),
        .operand_b_i(alu_input_b),
        .result_o(alu_result),
        .nzcv_o(alu_nzcv)
    );

    logic [3:0] reg_file_a1,
                reg_file_a2,
                reg_file_a3,
                reg_file_wa;
    logic [31:0] reg_file_wd,
                 reg_file_o1,
                 reg_file_o2,
                 reg_file_o3;
    logic reg_file_write_enable;

    reg_file u_reg_file(
        .clk(clk),
        .address1_i(reg_file_a1),
        .address2_i(reg_file_a2),
        .address3_i(reg_file_a3),
        .address_write_i(reg_file_wa),
        .write_data_i(reg_file_wd),
        .write_enable_i(reg_file_write_enable),
        .r15_i(next_pc),
        .output1_o(reg_file_o1),
        .output2_o(reg_file_o2),
        .output3_o(reg_file_o3)
    );
endmodule
