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

    // Zero-fill, then overlay the program image at address 0
    integer i;
    initial begin
        for (i = 0; i < 65536; i = i + 1)
            mem[i] = 16'h0000;
        $readmemh("program.hex", mem);
    end

    // Synchronous write operation
    always @(posedge clk) begin
        if (mem_write)
            mem[address] <= write_data;
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