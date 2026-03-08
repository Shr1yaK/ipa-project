`include "ALUOPS/sub64.v"
module sltu64(
    input [63:0] in1,
    input [63:0] in2,
    output [63:0] out,
    output  z_sltu_flag
);
 wire [64:0] ina,inb;
 assign ina={1'b0, in1};
 assign inb={1'b0, in2};
 wire [63:0] interdiff;
 wire zf,cf,of;
 wire t;
 sub64 dif(
    .in1(in1),
    .in2(in2),
    .out(interdiff),
    .z_sub_flag(zf),
    .c_sub_flag(cf),
    .o_sub_flag(of)
 );
xor xt(t,cf,1'b0);
assign out={63'b0,t};
assign z_sltu_flag=(out==64'b0);
endmodule