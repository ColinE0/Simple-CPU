module register_file(
    input clk,
    input reset,
    input [2:0] read_reg1,
    input [2:0] read_reg2,
    input [2:0] write_reg,
    input [15:0] write_data,
    input reg_write,
    output [15:0] read_data1,
    output [15:0] read_data2
);
    
    // 8 registers (R0-R7)
    reg [15:0] registers [0:7];
    
    // Initialize registers
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1)
                registers[i] <= 16'b0;
        end
        else if (reg_write) begin
            registers[write_reg] <= write_data;
        end
    end
    
    // Read operations (asynchronous)
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];
    
endmodule