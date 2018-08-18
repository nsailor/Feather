`include "alu.sv"
`include "reg_file.sv"
`include "program_memory.sv"
`include "memory.sv"
`include "immediate_shifter.sv"
`include "control.sv"

module core(input logic clk,
            input logic reset_i);
    logic [7:0] pc, next_pc;
    logic [31:0] instruction;

    // Whether the instruction should be executed at all.
    // It should be AND'ed with any write enable signal.
    logic condition_result;
    assign condition_result = 1'b1; // Don't check conditions for now.

    // Update the program counter.
    assign next_pc = reset_i ? 0 : pc + 4;
    always @(posedge clk) begin
        pc <= next_pc;
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

    logic memory_write_enable;

    logic [4:0] shifter_shamt5;
    logic [31:0] shifter_input;
    logic [1:0] shifter_sh;
    logic [31:0] shifter_result;

    shifter u_shifter(
        .shamt5_i(shifter_shamt5),
        .sh_i(shifter_sh),
        .data_i(shifter_input),
        .result_o(shifter_result)
    );

    logic [7:0] imm_shifter_input;
    logic [3:0] imm_shifter_rot;
    logic [31:0] imm_shifter_result;

    immediate_shifter u_imm_shifter(
        .imm8_i(imm_shifter_input),
        .rot_i(imm_shifter_rot),
        .result_o(imm_shifter_result)
    );

    logic reg_write_src;
    control u_control(
        .clk(clk),
        .instruction_i(instruction),
        .nzcv_i(alu_nzcv),
        .reg_write_src_o(reg_write_src),
        .reg_file_write_enable_o(reg_file_write_enable),
        .memory_write_enable_o(memory_write_enable)
    );

    assign alu_control = instruction[24:21];
    assign alu_input_a = reg_file_o1;
    assign reg_file_a1 = instruction[19:16];
    assign reg_file_a2 = instruction[3:0];
    assign reg_file_a3 = instruction[11:8];
    assign reg_file_wa = instruction[15:12];

    assign shifter_shamt5 = instruction[4] ?
        reg_file_o3[4:0] : instruction[11:7];

    assign shifter_sh = instruction[6:5];
    assign shifter_input = reg_file_o2;

    assign imm_shifter_input = instruction[7:0];
    assign imm_shifter_rot = instruction[11:8];

    assign alu_input_b = instruction[25] ? imm_shifter_result : shifter_result;

    assign reg_file_wd = reg_write_src ? 32'b0 : alu_result;
endmodule
