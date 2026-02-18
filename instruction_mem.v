module instruction_memory #(
    parameter IMEM_SIZE = 4095,
    parameter MEM_INIT_FILE = "instructions.txt"
) (
    input wire clk,
    input wire reset,  // Added reset signal
    input wire [63:0] addr,
    output wire [31:0] instr
);
endmodule