
module program_memory(
    input logic [7:0] address_i,
    output logic [31:0] instruction_i
);
    logic [7:0] instruction_memory [0:255];
    assign instruction_i[7:0] = instruction_memory[address_i];
    assign instruction_i[15:8] = instruction_memory[address_i + 1];
    assign instruction_i[23:16] = instruction_memory[address_i + 2];
    assign instruction_i[31:24] = instruction_memory[address_i + 3];

    initial begin
        $readmemh("tests/program1.hex", instruction_memory, 0, 11);
    end
endmodule
