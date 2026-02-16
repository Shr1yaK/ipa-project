module sra64(
    input [63:0] in1,
    input [63:0] in2,
    output [63:0] out,
    output  z_sra_flag
);
    wire [5:0]act_shift;
    assign act_shift=in2[5:0];
    wire [63:0]temp1,temp2,temp3,temp4,temp5,temp6;
    wire msb;
    assign msb=in1[63];
   // always @(*) begin
    assign temp1=in1[63:0];
    assign temp2=act_shift[0]?{msb,temp1[63:1]}:temp1;
    assign temp3=act_shift[1]?{{2{msb}},temp2[63:2]}:temp2;
    assign temp4=act_shift[2]?{{4{msb}},temp3[63:4]}:temp3;
    assign temp5=act_shift[3]?{{8{msb}},temp4[63:8]}:temp4;
    assign temp6=act_shift[4]?{{16{msb}},temp5[63:16]}:temp5;
    assign out=act_shift[5]?{{32{msb}},temp6[63:32]}:temp6;
    assign z_sra_flag=(out==64'b0);
endmodule