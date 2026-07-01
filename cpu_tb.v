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
        if (alu_out !== 21) $display("Test failed: ALU output incorrect");
        else $display("Test passed: ALU output correct");
        
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