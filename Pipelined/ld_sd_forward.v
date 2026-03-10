module ld_sd_forward(
    input wire [4:0] ld_rd,
    input wire [4:0] sd_rs2_data,
    input wire ld_sd_mem_to_reg,  // load
    input wire ld_sd_mem_write,   // store
    output wire ld_sd_sel               
);
    reg ld_sd_sel_reg;
    assign ld_sd_sel = ld_sd_sel_reg;

    always @(*) begin
        // Assume no forwarding
        ld_sd_sel_reg = 1'b0;
        
        // set forwarding if true
        if (ld_sd_mem_to_reg && 
            (ld_rd == sd_rs2_data) && 
            (ld_rd != 5'b0) && ld_sd_mem_write) begin
            ld_sd_sel_reg = 1'b1; // Forward from MEM/WB
        end
    end
endmodule