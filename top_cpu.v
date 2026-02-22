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

    wire [6:0] opcode;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    assign opcode = instruction[6:0];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign rd     = instruction[11:7];

    // =========================
    // Control Unit
    // =========================

    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire MemtoReg;
    wire ALUSrc;
    wire Branch;
    wire [1:0] ALUOp;

    control_unit cu_inst (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    // =========================
    // Register File
    // =========================

    wire [63:0] read_data1;
    wire [63:0] read_data2;
    wire [63:0] write_back_data;

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
    // Immediate Generator
    // =========================

    wire [63:0] imm_out;

    imm_gen imm_inst (
        .instruction(instruction),
        .imm(imm_out)
    );

    // =========================
    // ALU Control
    // =========================

    wire [3:0] ALUControl;

    alu_control alu_ctrl_inst (
        .ALUOp(ALUOp),
        .funct3(instruction[14:12]),
        .funct7(instruction[30]),  // Correct bit for SUB
        .ALUControl(ALUControl)
    );

    // =========================
    // ALU
    // =========================

    wire [63:0] alu_input2;
    wire [63:0] alu_result;
    wire zero_flag;

    assign alu_input2 = (ALUSrc) ? imm_out : read_data2;

    alu_64_bit alu_inst (
        .a(read_data1),
        .b(alu_input2),
        .opcode(ALUControl),
        .result(alu_result),
        .carry_flag(),
        .overflow_flag(),
        .zero_flag(zero_flag)
    );

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

    // =========================
    // Branch Logic + PC Update
    // =========================

    wire take_branch;

    assign take_branch = Branch & zero_flag;

    assign pc_in = (take_branch) ? (pc_out + imm_out)
                                 : (pc_out + 64'd4);

    pc pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

endmodule