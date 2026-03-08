// IF_ID reg file takes 32 bit instruction input, has a flush flag and write flag
module IF_ID(
    input wire clk,
    input wire reset,
    input wire flush,
    input wire IF_ID_write,
    input wire [63:0] IF_ID_pc_in,
    input wire [31:0] instr_in,
    output wire [63:0] IF_ID_pc_out,
    output wire [31:0] instr_out,
    output wire [4:0] rs1_IF_ID_out,
    output wire [4:0] rs2_IF_ID_out,
    output wire [4:0] rd_IF_ID_out
);

    reg [31:0] temp;
    reg [63:0] pc_in_reg;
    reg[4:0] rs1_temp;
    reg[4:0] rs2_temp;
    reg[4:0] rd_temp;
    // Outputs <= Reg
    assign instr_out = temp;
    assign IF_ID_pc_out = pc_in_reg;
    assign rs1_IF_ID_out=rs1_temp;
    assign rs2_IF_ID_out=rs2_temp;
    assign rd_IF_ID_out=rd_temp;
    // Reg <= Next(input) 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            temp <= 32'b0;
            pc_in_reg <= 64'b0;
            rs1_temp <= 5'b0;
            rs2_temp <= 5'b0;
            rd_temp <= 5'b0;
        end
        else if (flush) begin
            temp <= 32'b0;
            pc_in_reg <= 64'b0;
            rs1_temp <= 5'b0;
            rs2_temp <= 5'b0;
            rd_temp <= 5'b0;
        end
        else if (IF_ID_write) begin
            temp <= instr_in;
            pc_in_reg <= IF_ID_pc_in;
            rs1_temp <= instr_in[19:15];
            rs2_temp <= instr_in[24:20];
            rd_temp <= instr_in[11:7];
        end
        else begin
            temp <= temp;
            pc_in_reg <= pc_in_reg;
            s1_temp <= instr_in[19:15];
            rs2_temp <= instr_in[24:20];
            rd_temp <= instr_in[11:7];
        end
    end

endmodule