
parameter ALU_AND = 4'b0000;
parameter ALU_XOR = 4'b0001;
parameter ALU_SUB = 4'b0010;
parameter ALU_RSB = 4'b0011;
parameter ALU_ADD = 4'b0100;
parameter ALU_ORR = 4'b1100;

module alu #(parameter N=32)
          (input logic [3:0] control, // Control bits.
           input logic [N - 1:0] a,   // First operand.
           input logic [N - 1:0] b,   // Second operand.
           output logic [N - 1:0] y,  // Result
           output logic [3:0] nzcv);  // NZCV flags
    logic [N - 1:0] lhs;
    logic [N - 1:0] rhs;
    logic [N:0] sum;
    always_comb begin
        // To implement subtraction we reuse the addition logic,
        // effectively implementing a - b = a + (-b) and
        // b - a = b + (-a). This approach allows us to not
        // duplicate our NZCV logic.
        case (control)
            ALU_SUB: begin
                lhs = a;
                rhs = -b;
            end
            ALU_RSB: begin
                lhs = b;
                rhs = -a;
            end
            default: begin
                lhs = a;
                rhs = b;
            end
        endcase
        sum = lhs + rhs;
        case (control)
            ALU_AND: begin
                y = a & b;
            end
            ALU_XOR: begin
                y = a ^ b;
            end
            ALU_ADD, ALU_SUB, ALU_RSB: begin
                y = sum[N - 1:0];
            end
            ALU_ORR: begin
                y = a | b;
            end
            default: begin 
                y = {N{1'bx}};
            end
        endcase
    end

    assign nzcv[3] = y[N - 1]; // Use the sign bit for the negative (N) flag.
    assign nzcv[2] = (y == 0); // Zero flag, check for equality with zero.
    assign nzcv[1] = sum[N];   // Carry flag, simply the MSB of the real sum.

    // An overflow occurs when we are adding two numbers
    // of the same sign but the result has a different sign.
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
    assign nzcv[0] = (msb_lhs == msb_rhs) && (msb_sum != msb_lhs);
endmodule
