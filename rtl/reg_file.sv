
module reg_file #(parameter N=32)
    (input logic clk,
     input logic [3:0] address1_i,
     input logic [3:0] address2_i,
     input logic [3:0] address3_i,
     input logic [N - 1:0] write_data_i,
     input logic write_enable_i,
     input logic [N - 1:0] r15_i,
     output logic [N - 1:0] output1_o,
     output logic [N - 1:0] output2_o
);
    logic [N - 1:0] registers [0:15];

    assign output1_o = registers[address1_i];
    assign output2_o = registers[address2_i];

    always @(posedge clk) begin
        registers[15] = r15_i;
    end

    // Note: writing to R15 (the PC), is illegal in our implementation of the
    // ARM ISA. However, there is no universal way to define an assertion both
    // in Yosys and in Verilator, so this goes unchecked.

    always @(posedge clk) begin
        if (write_enable_i) begin
            registers[address3_i] = write_data_i;
        end
    end
endmodule