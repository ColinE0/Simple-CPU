module cpu_tb;
    
    reg clk;
    reg reset;
    wire [15:0] pc_out;
    wire [15:0] alu_out;
    wire [15:0] mem_data_out;
    wire [15:0] reg_data_out;
    wire halt;
    
    // Instantiate CPU
    cpu uut(
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .alu_out(alu_out),
        .mem_data_out(mem_data_out),
        .reg_data_out(reg_data_out),
        .halt(halt)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        #10;
        reset = 0;
        
        // Wait for halt
        wait(halt);
        #20;

        // Verify results
        // The test program loads 10 and 11, adds them (21), stores the sum at
        // address 12, loads it back into R4 with LDM, then jumps over LOAD R5
        if (uut.reg_file.registers[3] !== 21)
            $display("Test failed: R3 = %0d, expected 21", uut.reg_file.registers[3]);
        else if (uut.mem.mem[12] !== 21)
            $display("Test failed: mem[12] = %0d, expected 21", uut.mem.mem[12]);
        else if (uut.reg_file.registers[4] !== 21)
            $display("Test failed: R4 = %0d, expected 21 from LDM readback", uut.reg_file.registers[4]);
        else if (uut.reg_file.registers[5] !== 0)
            $display("Test failed: R5 = %0d, expected 0 (JUMP should skip LOAD R5)", uut.reg_file.registers[5]);
        else
            $display("Test passed: R3 = 21, mem[12] = 21, LDM read back 21, JUMP skipped LOAD R5");

        $finish;
    end

    // Watchdog: fail instead of hanging if the CPU never halts
    initial begin
        #3000;
        $display("Test failed: watchdog timeout, CPU never halted");
        $finish;
    end
    
endmodule