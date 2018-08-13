
module program_memory(
    input logic [7:0] address_i,
    output logic [31:0] instruction_o
);
    logic [7:0] instruction_memory [0:255];
    assign instruction_o[7:0] = instruction_memory[address_i];
    assign instruction_o[15:8] = instruction_memory[address_i + 1];
    assign instruction_o[23:16] = instruction_memory[address_i + 2];
    assign instruction_o[31:24] = instruction_memory[address_i + 3];

    initial begin
        $readmemh("tests/program1.hex", instruction_memory, 0, 15);
    end
endmodule
