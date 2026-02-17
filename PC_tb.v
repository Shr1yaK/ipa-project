`timescale 1ns / 1ps

`include "PC.v"

module pc_tb;
    reg clk;
    reg reset;
    reg [63:0] pc_in;
    wire [63:0] pc_out;
    
    // Test counter
    integer test_count = 0;
    integer pass_count = 0;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Instantiate the PC module
    pc uut(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );
    task run_test;
        input [63:0] test_pc_in;
        input test_reset;
        input [63:0] expected_pc_out;
        begin
            test_count = test_count + 1;
            pc_in = test_pc_in;
            reset = test_reset;
            
            @(posedge clk);
            #2; // Wait for outputs to stabilize
            
            $display("\nTest Case %0d:", test_count);
            $display("Test: pc_in = %h", pc_in);
            $display("      reset = %b", reset);
            $display("      Expected pc_out = %h", expected_pc_out);
            $display("      Actual pc_out = %h", pc_out);
            
            if (pc_out === expected_pc_out) begin
                $display("      Status: PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("      Status: FAIL");
                $display("      Output mismatch!");
            end
        end
    endtask
    
    initial begin
        $dumpfile("PC_TB.vcd");
        $dumpvars(1, uut);
        
        // Initialize signals
        reset = 0;
        pc_in = 64'h0;
        #10;
        
        // Test 1: Reset behavior
        run_test(64'hDEADBEEFDEADBEEF, 1, 64'h0); // Should reset to 0
        
        // Test 2: Normal operation after reset
        run_test(64'h0000000000000004, 0, 64'h0000000000000004); // Load new PC value
        
        // Test 3: Large jump
        run_test(64'h0000000080000000, 0, 64'h0000000080000000); // Test large address jump
        
        // Test 4: Maximum value
        run_test(64'hFFFFFFFFFFFFFFFC, 0, 64'hFFFFFFFFFFFFFFFC); // Test maximum valid PC value
        
        // Test 5: Reset during operation
        run_test(64'h0000000000001000, 1, 64'h0); // Should reset to 0 regardless of input
        
        // Test 6: Recovery after reset
        run_test(64'h0000000000000008, 0, 64'h0000000000000008); // Normal operation after reset
        
        // Test 7: Consecutive normal operations
        run_test(64'h000000000000000C, 0, 64'h000000000000000C); // Normal increment
        run_test(64'h0000000000000010, 0, 64'h0000000000000010); // Normal increment
        
        // Test 8: Reset assertion during normal operation
        run_test(64'h0000000000002000, 0, 64'h0000000000002000); // Set normal value
        run_test(64'h0000000000002004, 1, 64'h0); // Assert reset
        
        // Report Results
        #10;
        $display("\n=== Test Summary ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", test_count - pass_count);
        $display("==================\n");
        
        $finish;
    end

endmodule