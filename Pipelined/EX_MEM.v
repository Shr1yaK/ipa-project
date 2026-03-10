module EX_MEM(
    input clk,
    input reset,

    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input MemtoReg_in,

    input [63:0] alu_result_in,
    input [63:0] write_data_in,
    input [4:0] rd_in,

    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemtoReg_out,

    output reg [63:0] alu_result_out,
    output reg [63:0] write_data_out,
    output reg [4:0] rd_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        RegWrite_out <= 0;
        MemRead_out <= 0;
        MemWrite_out <= 0;
        MemtoReg_out <= 0;

        alu_result_out <= 0;
        write_data_out <= 0;
        rd_out <= 0;
    end
    else begin
        RegWrite_out <= RegWrite_in;
        MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        MemtoReg_out <= MemtoReg_in;

        alu_result_out <= alu_result_in;
        write_data_out <= write_data_in;
        rd_out <= rd_in;
    end
end

endmodule