// Single-port memory module.
module memory(
    input logic clk,
    input logic [31:0] address_i,
    input logic write_enable_i,
    input logic [31:0] write_data_i,
    output logic [31:0] data_o
);
    logic [31:0] ram [0:255]; // 256 bytes of RAM

    assign data_o = ram[address_i];

    always @(posedge clk) begin
        if (write_enable_i) begin
            ram[address_i] = write_data_i;
        end
    end
endmodule
