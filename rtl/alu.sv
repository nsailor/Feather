
parameter ALU_AND = 4'b0000;
parameter ALU_XOR = 4'b0001;
parameter ALU_SUB = 4'b0010;
parameter ALU_RSB = 4'b0011; // Reverse subtract (b - a)
parameter ALU_ADD = 4'b0100;
parameter ALU_ORR = 4'b1100;
parameter ALU_MOV = 4'b1101;

module alu #(parameter N=32)
          (input logic [3:0] control_i, // Control bits.
           input logic [N - 1:0] operand_a_i,   // First operand.
           input logic [N - 1:0] operand_b_i,   // Second operand.
           output logic [N - 1:0] result_o,  // Result
           output logic [3:0] nzcv_o);  // NZCV flags
    logic [N - 1:0] lhs;
    logic [N - 1:0] rhs;
    logic [N:0] sum;

    always_comb begin
        // To implement subtraction we reuse the addition logic,
        // effectively implementing a - b = a + (-b) and
        // b - a = b + (-a). This approach allows us to not
        // duplicate our NZCV logic.
        case (control_i)
            ALU_SUB: begin
                lhs = operand_a_i;
                rhs = -operand_b_i;
            end
            ALU_RSB: begin
                lhs = operand_b_i;
                rhs = -operand_a_i;
            end
            default: begin
                lhs = operand_a_i;
                rhs = operand_b_i;
            end
        endcase
        sum = lhs + rhs;
        case (control_i)
            ALU_AND: begin
                result_o = operand_a_i & operand_b_i;
            end
            ALU_XOR: begin
                result_o = operand_a_i ^ operand_b_i;
            end
            ALU_ADD, ALU_SUB, ALU_RSB: begin
                result_o = sum[N - 1:0];
            end
            ALU_ORR: begin
                result_o = operand_a_i | operand_b_i;
            end
            ALU_MOV: begin
                result_o = operand_b_i;
            end
            default: begin
                result_o = {N{1'bx}};
            end
        endcase
    end

    // Use the sign bit for the negative (N) flag.
    assign nzcv_o[3] = result_o[N - 1];

    // Zero flag, check for equality with zero.
    assign nzcv_o[2] = (result_o == 0);

    // Carry flag, simply the MSB of the real sum.
    assign nzcv_o[1] = sum[N];

    // An overflow occurs when we are adding two numbers
    // of the same sign but the result has operand_a_i different sign.
    // For instance:
    //   01 -> 1   | Notice how the sign of the result
    //  +01 -> 1   | is different to that of the operands.
    //  ----       | To detect an overflow, we simply apply
    //   11 -> -1  | this procedure to the MSB's of the LHS
    //             | and RHS of the sum.
    //
    logic msb_lhs = lhs[N - 1];
    logic msb_rhs = rhs[N - 1];
    logic msb_sum = sum[N - 1];
    assign nzcv_o[0] = (msb_lhs == msb_rhs) && (msb_sum != msb_lhs);
endmodule
