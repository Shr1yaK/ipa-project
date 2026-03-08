module xor64(
    input [63:0] in1,
    input [63:0] in2,
    output [63:0] out,
    output  z_xor_flag
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) 
        begin //: //xor_chain
            xor x1 (out[i], in1[i], in2[i]);
        end
    endgenerate
    assign z_xor_flag=(out==64'b0);
endmodule