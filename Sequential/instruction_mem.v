module instruction_memory #(
    parameter IMEM_SIZE = 4096,
    parameter MEM_INIT_FILE = "instructions.txt"
) (
    input wire clk,
    input wire reset,
    input wire [63:0] addr,
    output wire [31:0] instr
);

    // Byte-addressable memory
    reg [7:0] memory [0:IMEM_SIZE-1];

    // Load byte file
    initial begin
        $readmemh(MEM_INIT_FILE, memory);
    end

    // Big-endian instruction assembly
    assign instr = {
        memory[addr],
        memory[addr + 1],
        memory[addr + 2],
        memory[addr + 3]
    };

endmodule