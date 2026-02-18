module top_cpu(
    input clk,
    input reset,
    output [31:0] instruction_out
);

    // =========================
    // Program Counter
    // =========================

    wire [63:0] pc_out;
    wire [63:0] pc_in;

    // PC increment logic (no branch yet)
    assign pc_in = pc_out + 64'd4;

    pc pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // =========================
    // Instruction Memory
    // =========================

    wire [31:0] instruction;

    instruction_memory imem_inst (
        .clk(clk),
        .reset(reset),
        .addr(pc_out),
        .instr(instruction)
    );

    assign instruction_out = instruction;

    // =========================
    // Instruction Field Extraction
    // =========================

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];

    // =========================
    // Register File
    // =========================

    wire [63:0] read_data1;
    wire [63:0] read_data2;
    wire [63:0] write_back_data;
    wire RegWrite;

    // Placeholder: disable writes for now
    assign RegWrite = 1'b0;
    assign write_back_data = 64'd0;

    register_file reg_file_inst (
        .clk(clk),
        .reset(reset),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(write_back_data),
        .reg_write_en(RegWrite),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // =========================
    // ALU (Temporary Placeholder Logic)
    // =========================

    wire [63:0] alu_input2;
    wire [63:0] alu_result;

    // Placeholder control signals
    wire ALUSrc;
    wire MemtoReg;
    wire MemRead;
    wire MemWrite;

    assign ALUSrc   = 1'b0;
    assign MemtoReg = 1'b0;
    assign MemRead  = 1'b0;
    assign MemWrite = 1'b0;

    // MUX for ALU input 2 (immediate not implemented yet)
    assign alu_input2 = (ALUSrc) ? 64'd0 : read_data2;

    // Temporary ALU operation (ADD)
    assign alu_result = read_data1 + alu_input2;

    // =========================
    // Data Memory
    // =========================

    wire [63:0] mem_read_data;

    data_mem data_mem_inst (
        .clk(clk),
        .reset(reset),
        .address(alu_result),
        .write_data(read_data2),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .read_data(mem_read_data)
    );

    // =========================
    // Writeback MUX
    // =========================

    assign write_back_data = (MemtoReg) ? mem_read_data : alu_result;

endmodule