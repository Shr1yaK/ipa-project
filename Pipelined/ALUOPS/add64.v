module fa1(
    output sum,
    output cout,
    input a,
    input b,
    input cin
);
    wire i1, i2, i3, i4;
    //xor x1(sum, a, b, c); // sum=a^b^cin
    xor x2(i1, a, b);
    xor x1(sum, i1, cin);
    and a1(i2, i1, cin);
    and a2(i3, a, b);     // cout=a*b + cin*(a^b)
    or o1(cout, i2, i3);
endmodule

module add64(
    input [63:0] in1,
    input [63:0] in2,
    output [63:0] out,
    output z_add_flag,
    output c_add_flag,
    output o_add_flag
);
    wire [64:0] carr;
    assign carr[0]=0;

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) 
        begin 
            fa1 full1(
                .sum(out[i]),
                .cout(carr[i+1]),
                .a(in1[i]),
                .b(in2[i]),
                .cin(carr[i])
            );
        end
    endgenerate
    assign z_add_flag=(out==64'b0);
    assign c_add_flag=(carr[64]==1);
    wire i1;
    xor(i1,in1[63],in2[63]);
    wire i2;
    assign i2 = (in1[63]==out[63])? 0: 1;
    assign o_add_flag= i1 ? 0 : i2;


endmodule