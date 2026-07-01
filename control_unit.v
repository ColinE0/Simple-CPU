module control_unit(
    input [15:0] instruction,
    output reg [3:0] alu_op,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg alu_src,
    output reg [2:0] reg_dst,
    output reg [2:0] reg_src1,
    output reg [2:0] reg_src2,
    output reg [15:0] immediate,
    output reg pc_update,
    output reg halt
);
    
    // Instruction opcodes
    parameter LOAD   = 4'b0001;
    parameter STORE  = 4'b0011;
    parameter ADD    = 4'b0010;
    parameter SUB    = 4'b0100;
    parameter MUL    = 4'b0101;
    parameter DIV    = 4'b0110;
    parameter AND    = 4'b0111;
    parameter OR     = 4'b1000;
    parameter NOT    = 4'b1001;
    parameter XOR    = 4'b1010;
    parameter JUMP   = 4'b1011;
    parameter HALT   = 4'b1111;
    
    always @(*) begin
        // Default values
        alu_op = 4'b0;
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        alu_src = 0;
        reg_dst = 3'b0;
        reg_src1 = 3'b0;
        reg_src2 = 3'b0;
        immediate = 16'b0;
        pc_update = 1;
        halt = 0;
        
        case(instruction[15:12])
            LOAD: begin
                // Format: LOAD Rd, imm
                reg_dst = instruction[11:9];
                immediate = {7'b0, instruction[8:0]};
                alu_src = 1;
                alu_op = 4'b1000; // MOV operation
                reg_write = 1;
            end
            STORE: begin
                // Format: STORE Rs, addr
                reg_src1 = instruction[11:9];
                immediate = {7'b0, instruction[8:0]};
                mem_write = 1;
            end
            ADD: begin
                // Format: ADD Rd, Rs1, Rs2
                reg_dst = instruction[11:9];
                reg_src1 = instruction[8:6];
                reg_src2 = instruction[5:3];
                alu_op = 4'b0000; // ADD operation
                reg_write = 1;
            end
            SUB: begin
                // Format: SUB Rd, Rs1, Rs2
                reg_dst = instruction[11:9];
                reg_src1 = instruction[8:6];
                reg_src2 = instruction[5:3];
                alu_op = 4'b0001; // SUB operation
                reg_write = 1;
            end
            JUMP: begin
                // Format: JUMP addr
                immediate = {4'b0, instruction[11:0]};
                pc_update = 0; // PC will be updated with immediate
            end
            HALT: begin
                halt = 1;
                pc_update = 0;
            end
            // Other operations similar to ADD/SUB
            default: begin
                // Handle other ALU operations
                if (instruction[15:12] >= 4'b0100 && instruction[15:12] <= 4'b1010) begin
                    reg_dst = instruction[11:9];
                    reg_src1 = instruction[8:6];
                    reg_src2 = instruction[5:3];
                    alu_op = instruction[15:12];
                    reg_write = 1;
                end
            end
        endcase
    end
    
endmodule