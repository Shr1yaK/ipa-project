module instruction_memory #(
    parameter IMEM_SIZE = 4095,
    parameter MEM_INIT_FILE = "instructions.txt"
) (
    input wire clk,
    input wire reset,  // Added reset signal
    input wire [63:0] addr,
    output wire [31:0] instr
);
 // Memory array
    reg [7:0] mem [0:MEM_SIZE-1];
    
    // File reading variables
    integer file, status, i;
    reg [7:0] hex_value;
endmodule