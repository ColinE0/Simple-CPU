module memory (
    input wire clk,
    input wire [15:0] address,      // 16-bit address bus
    input wire [15:0] write_data,   // 16-bit data input
    input wire mem_read,            // Read enable
    input wire mem_write,           // Write enable
    output reg [15:0] read_data     // 16-bit data output
);

    // 64KB memory (16-bit words)
    reg [15:0] mem [0:65535];

    // Initialize memory from hex file
    initial begin
        $readmemh("padded_program.hex", mem);  // Load contents from program.hex
    end
    // Optional: Display initial memory contents for debugging
    initial begin
  $display("Memory[0:3] = %h %h %h %h", mem[0], mem[1], mem[2], mem[3]);
    end
    // end

    // Synchronous write operation
    always @(posedge clk) begin
        if (mem_write) begin
            mem[address] <= write_data;
            // Optional: Display writes during simulation
            $display("Memory Write: Addr=%h Data=%h", address, write_data);
        end
    end

    // Asynchronous read operation; drives 0 when idle (no internal
    // tri-state bus, so the design stays synthesizable)
    always @(*) begin
        if (mem_read)
            read_data = mem[address];
        else
            read_data = 16'h0000;
    end

endmodule