module ID_EX(
    input wire clk, reset, flush,
    input wire RegWrite_in, MemRead_in, MemWrite_in, MemToReg_in, Branch_in, ALUSrc_in,
    input wire [1:0] ALUOp_in,
    input wire [63:0] pc_in, read_data1_in, read_data2_in, imm_in,
    input wire [4:0] rs1_in, rs2_in, rd_in,
    input wire [2:0] funct3_in,
    input wire funct7_in,
    output reg RegWrite_out, MemRead_out, MemWrite_out, MemToReg_out, Branch_out, ALUSrc_out,
    output reg [1:0] ALUOp_out,
    output reg [63:0] pc_out, read_data1_out, read_data2_out, imm_out,
    output reg [4:0] rs1_out, rs2_out, rd_out,
    output reg [2:0] funct3_out,
    output reg funct7_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            {RegWrite_out, MemRead_out, MemWrite_out, MemToReg_out, Branch_out, ALUSrc_out, ALUOp_out} <= 0;
            {pc_out, read_data1_out, read_data2_out, imm_out} <= 0;
            {rs1_out, rs2_out, rd_out} <= 0;
            funct3_out <= 0;
            funct7_out <= 0;
        end else begin
            RegWrite_out <= RegWrite_in; 
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in; 
            MemToReg_out <= MemToReg_in;
            Branch_out <= Branch_in; 
            ALUSrc_out <= ALUSrc_in;
            ALUOp_out <= ALUOp_in;
            pc_out <= pc_in; 
            read_data1_out <= read_data1_in;
            read_data2_out <= read_data2_in; 
            imm_out <= imm_in;
            rs1_out <= rs1_in; 
            rs2_out <= rs2_in; 
            rd_out <= rd_in;
            funct3_out <= funct3_in;
            funct7_out <= funct7_in;
        end
    end
endmodule