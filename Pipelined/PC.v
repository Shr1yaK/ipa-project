module pc(
    input clk,
    input reset,
    input [63:0] pc_in,
    output [63:0] pc_out
);
reg [63:0] pc_temp;
always @(posedge clk or posedge reset) begin
    if(reset) begin
        pc_temp <= 64'b0;
    end 
    else 
    begin
        pc_temp <= pc_in;
    end
end
assign pc_out = pc_temp;
endmodule