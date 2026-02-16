module sll64(
    input [63:0] in1,
    input [63:0] in2,
    output [63:0] out,
    output  z_sll_flag
);
    wire [5:0]act_shift;
    assign act_shift=in2[5:0];
    wire [63:0]temp1,temp2,temp3,temp4,temp5,temp6;
   // always @(*) begin
    assign temp1=in1[63:0];
    assign temp2=act_shift[0]?{temp1[62:0],1'b0}:temp1;
    assign temp3=act_shift[1]?{temp2[61:0],2'b0}:temp2;
    assign temp4=act_shift[2]?{temp3[59:0],4'b0}:temp3;
    assign temp5=act_shift[3]?{temp4[55:0],8'b0}:temp4;
    assign temp6=act_shift[4]?{temp5[47:0],16'b0}:temp5;
    assign out=act_shift[5]?{temp6[31:0],32'b0}:temp6;
    //end
    //assign out=temp;
    assign z_sll_flag=(out==64'b0);
    // genvar i;
    // generate
    //     for(i=0;i<6;i=i+1)
    //     begin
    //         assign temp= {}
    //     end
    //endgenerate
endmodule