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
        // The test program should have loaded 10 and 11, added them (21), and stored at address 12
        if (uut.reg_file.registers[3] !== 21)
            $display("Test failed: R3 = %0d, expected 21", uut.reg_file.registers[3]);
        else if (uut.mem.mem[12] !== 21)
            $display("Test failed: mem[12] = %0d, expected 21", uut.mem.mem[12]);
        else
            $display("Test passed: R3 = 21 and mem[12] = 21");

        $finish;
    end

    // Watchdog: fail instead of hanging if the CPU never halts
    initial begin
        #3000;
        $display("Test failed: watchdog timeout, CPU never halted");
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t PC=%h IR=%h ALU=%h R1=%h R2=%h", 
                 $time, pc_out, uut.ir, alu_out, reg_data_out, uut.reg_data2);
    end
    always @(posedge clk) begin
        $display("FETCH: PC=%h -> MEM[PC]=%h", uut.pc, uut.mem.mem[uut.pc]);
    end
endmodule