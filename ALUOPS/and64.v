module and64(
    input [63:0] in1,
    input [63:0] in2,
    output [63:0] out,
    output z_and_flag
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) 
        begin //: //xor_chain
            and a1 (out[i], in1[i], in2[i]);
        end
    endgenerate
    assign z_and_flag=(out==64'b0);
endmodule
/// 8=> 01000
/// -9=> 01001 10110 11111 == 11100
/// -7=> 00110 11010 00010 
/// 00100
