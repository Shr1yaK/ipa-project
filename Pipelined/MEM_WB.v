module MEM_WB(
    input wire clk, rst,
    input wire [63:0] alu_result_in, mem_data_in,
    input wire [4:0] rd_in,
    input wire RegWrite_in, MemtoReg_in,
    output reg [63:0] alu_result_out, mem_data_out,
    output reg [4:0] rd_out,
    output reg RegWrite_out, MemtoReg_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out <= 64'b0;
            mem_data_out <= 64'b0;
            rd_out <= 5'b0;
            RegWrite_out <= 1'b0;
            MemtoReg_out <= 1'b0;
        end else begin
            alu_result_out <= alu_result_in;
            mem_data_out <= mem_data_in;
            rd_out <= rd_in;
            RegWrite_out <= RegWrite_in;
            MemtoReg_out <= MemtoReg_in;
        end
    end
endmodule