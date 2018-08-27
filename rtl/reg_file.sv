
module reg_file #(parameter N=32)
    (input logic clk,
     input logic [3:0] address1_i,
     input logic [3:0] address2_i,
     input logic [3:0] address3_i,
     input logic [3:0] address_write1_i,
     input logic [N - 1:0] write_data1_i,
     input logic write_enable1_i,
     input logic [3:0] address_write2_i,
     input logic [N - 1:0] write_data2_i,
     input logic write_enable2_i,
     input logic [N - 1:0] r15_i,
     output logic [N - 1:0] output1_o,
     output logic [N - 1:0] output2_o,
     output logic [N - 1:0] output3_o,
     output logic [N - 1:0] r15_o
);
    logic [N - 1:0] registers [0:15];
    logic [N - 1:0] next_registers [0:15]; // Next state of the register file.

    assign output1_o = registers[address1_i];
    assign output2_o = registers[address2_i];
    assign output3_o = registers[address3_i];
    assign r15_o = registers[15];

    // Since we have multiple write ports (1, 2 and R15) conflicts can occur.
    // The following logic makes sure that the following priority list
    // is enforced: (port 2 > port 1 > r15).
    // This allows instructions like mov pc, #0 to work without R15 being
    // overwritten by r15_i.

    always_comb begin
        next_registers = registers;
        next_registers[15] = r15_i;
        if (write_enable1_i) begin
            next_registers[address_write1_i] = write_data1_i;
        end
        if (write_enable2_i) begin
            next_registers[address_write2_i] = write_data2_i;
        end
    end

    always @(posedge clk) registers <= next_registers;
endmodule