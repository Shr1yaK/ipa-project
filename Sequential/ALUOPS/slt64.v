`include "ALUOPS/sltu64.v"
module slt64(
    input [63:0] in1,
    input [63:0] in2,
    output [63:0] out,
    output  z_slt_flag
);
 wire [64:0] ina,inb;
 assign ina={1'b0, in1};
 assign inb={1'b0, in2};
 wire [63:0] interdiff1;
 wire zf1,cf1,of1;
 wire t1;
 sub64 dif(
    .in1(in1),
    .in2(in2),
    .out(interdiff1),
    .z_sub_flag(zf1),
    .c_sub_flag(cf1),
    .o_sub_flag(of1)
 );
xor xt1(t1,of1,interdiff1[63]);
assign out={63'b0,t1};
assign z_slt_flag=(out==64'b0);
// check if output of sub is -ve or +ve
// if 
endmodule