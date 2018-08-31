// Single-port memory module.
module memory(
    input logic clk,
    input logic [31:0] address_i,
    input logic write_enable_i,
    input logic [7:0] write_data_i,
    output logic [7:0] data_o,
    input logic [31:0] instruction_address_i,
    output logic [31:0] instruction_o
);
    logic [7:0] ram [0:255]; // 256 bytes of RAM

    assign data_o = ram[address_i];
    assign instruction_o[7:0] = ram[instruction_address_i];
    assign instruction_o[15:8] = ram[instruction_address_i + 1];
    assign instruction_o[23:16] = ram[instruction_address_i + 2];
    assign instruction_o[31:24] = ram[instruction_address_i + 3];

    always @(posedge clk) begin
        if (write_enable_i) begin
            ram[address_i] <= write_data_i;
        end
    end

    initial begin
        $readmemh("tests/test.vhex", ram);
    end
endmodule
