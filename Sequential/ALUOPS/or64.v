module or64(
    input [63:0] in1,
    input [63:0] in2,
    output [63:0] out,
    output z_or_flag
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) 
        begin 
            or o1 (out[i], in1[i], in2[i]);
        end
    endgenerate
    assign z_or_flag=(out==64'b0);
endmodule