
module reg_file #(parameter N=32)
    (input logic clk,
     input logic [3:0] address1_i,
     input logic [3:0] address2_i,
     input logic [3:0] address3_i,
     input logic [3:0] address_write_i,
     input logic [N - 1:0] write_data_i,
     input logic write_enable_i,
     input logic [N - 1:0] r15_i,
     output logic [N - 1:0] output1_o,
     output logic [N - 1:0] output2_o,
     output logic [N - 1:0] output3_o,
     output logic [N - 1:0] r15_o
);
    logic [N - 1:0] registers [0:15];

    assign output1_o = registers[address1_i];
    assign output2_o = registers[address2_i];
    assign output3_o = registers[address3_i];
    assign r15_o = registers[15];

    always @(posedge clk) begin
        if (write_enable_i) begin
            if (address_write_i == 15) begin
                registers[15] <= write_data_i;
            end else begin
                registers[address_write_i] <= write_data_i;
                registers[15] <= r15_i;
            end
        end else begin
            registers[15] <= r15_i;
        end
    end
endmodule