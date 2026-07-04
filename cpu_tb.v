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
        // The test program adds 10 and 11 (21), stores/loads the sum through
        // memory, jumps over one LOAD, runs a 3-iteration countdown loop
        // closed by JNZ, then proves JZ takes the branch at zero
        if (uut.reg_file.registers[3] !== 21)
            $display("Test failed: R3 = %0d, expected 21", uut.reg_file.registers[3]);
        else if (uut.mem.mem[40] !== 21)
            $display("Test failed: mem[40] = %0d, expected 21", uut.mem.mem[40]);
        else if (uut.reg_file.registers[4] !== 21)
            $display("Test failed: R4 = %0d, expected 21 from LDM readback", uut.reg_file.registers[4]);
        else if (uut.reg_file.registers[5] !== 0)
            $display("Test failed: R5 = %0d, expected 0 (JUMP and JZ must skip both LOAD R5s)", uut.reg_file.registers[5]);
        else if (uut.reg_file.registers[6] !== 0)
            $display("Test failed: R6 = %0d, expected 0 after the countdown loop", uut.reg_file.registers[6]);
        else if (uut.reg_file.registers[2] !== 14)
            $display("Test failed: R2 = %0d, expected 14 (loop body must run exactly 3 times)", uut.reg_file.registers[2]);
        else if (uut.mem.mem[41] !== 0)
            $display("Test failed: mem[41] = %0d, expected 0", uut.mem.mem[41]);
        else
            $display("Test passed: arithmetic, memory, JUMP, and a JNZ-closed loop of exactly 3 iterations with JZ taken at zero");

        $finish;
    end

    // Watchdog: fail instead of hanging if the CPU never halts
    initial begin
        #3000;
        $display("Test failed: watchdog timeout, CPU never halted");
        $finish;
    end
    
endmodule