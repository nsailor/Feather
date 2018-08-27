module control(input logic clk,
               input logic [31:0] instruction_i,
               input logic [3:0] nzcv_i,
               output logic reg_write_src_o, // Only applies to port 1
               output logic reg_file_write_enable1_o,
               output logic reg_file_write_enable2_o,
               output logic memory_write_enable_o);

    localparam INSTRUCTION_TYPE_DATA_PROCESSING = 2'b00;
    localparam INSTRUCTION_TYPE_MEMORY = 2'b01;
    localparam INSTRUCTION_TYPE_BRANCH = 2'b10;

    logic [3:0] nzcv;
    initial nzcv = 4'b0000;

    logic n, z, c, v;
    assign n = nzcv[3];
    assign z = nzcv[2];
    assign c = nzcv[1];
    assign v = nzcv[0];

    logic [1:0] instruction_type;
    assign instruction_type = instruction_i[27:26];
    logic is_load_instruction;
    assign is_load_instruction = instruction_i[20];

    logic should_update_nzcv;
    assign should_update_nzcv = instruction_i[20]
        & (instruction_type == INSTRUCTION_TYPE_DATA_PROCESSING);

    always @(posedge clk)
        if (should_update_nzcv)
            nzcv <= nzcv_i;

    logic cond_res;
    logic [3:0] condition;
    assign condition = instruction_i[31:28];

    localparam EQ = 4'h0;
    localparam NE = 4'h1;
    localparam CS = 4'h2;
    localparam CC = 4'h3;
    localparam MI = 4'h4;
    localparam PL = 4'h5;
    localparam VS = 4'h6;
    localparam VC = 4'h7;
    localparam HI = 4'h8;
    localparam LS = 4'h9;
    localparam GE = 4'hA;
    localparam LT = 4'hB;
    localparam GT = 4'hC;
    localparam LE = 4'hD;
    localparam AL = 4'hE;

    always_comb
        case (condition)
            EQ: cond_res = z;
            NE: cond_res = ~z;
            CS: cond_res = c;
            CC: cond_res = ~c;
            MI: cond_res = n;
            PL: cond_res = ~n;
            VS: cond_res = v;
            VC: cond_res = ~v;
            HI: cond_res = ~z & c;
            LS: cond_res = z | ~c;
            GE: cond_res = ~(n ^ v);
            LT: cond_res = n ^ v;
            GT: cond_res = ~z & ~(n ^ v);
            LE: cond_res = z | (n ^ v);
            AL: cond_res = 1'b1;
        endcase

        assign reg_write_src_o = (instruction_type == INSTRUCTION_TYPE_MEMORY);

    // Write to a register in data processing and load
    // instructions.
    assign reg_file_write_enable1_o =
        ((instruction_type == INSTRUCTION_TYPE_DATA_PROCESSING)
        | ((instruction_type == INSTRUCTION_TYPE_MEMORY)
            & is_load_instruction)) & cond_res;

    // To be used in memory instructions.
    assign reg_file_write_enable2_o = 1'b0;

    assign memory_write_enable_o =
        ((instruction_type == INSTRUCTION_TYPE_MEMORY)
        & ~is_load_instruction) & cond_res;
endmodule