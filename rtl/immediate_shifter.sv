// Implements the operation imm8 >> (2 * rot),
// necessary for decoding ARM immediate values.
module immediate_shifter(
    input logic [7:0] imm8_i,
    input logic [3:0] rot_i,
    output logic [31:0] result_o
);
    assign result_o = imm8_i >> (rot_i << 1);
endmodule