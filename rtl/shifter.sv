// Shifting module, implementing the four shifting
// modes available on the ARM architecture.
module shifter(input logic [4:0] shamt5_i,
               input logic [1:0] sh_i,
               input logic [31:0] data_i,
               output logic [31:0] result_o);

    localparam LSL = 2'b00; // Logical shift left
    localparam LSR = 2'b01; // Logical shift right
    localparam ASR = 2'b10; // Arithmetic shift right
    localparam ROR = 2'b11; // Rotate right

    always_comb
        case (sh_i)
            LSL: result_o = data_i << shamt5_i;
            LSR: result_o = data_i >> shamt5_i;
            ASR: result_o = data_i >>> shamt5_i;
            ROR: result_o = data_i; // ROR not supported yet.
        endcase
endmodule
