module control_unit(
    input [15:0] instruction,
    output reg [3:0] alu_op,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg alu_src,
    output reg mem_to_reg,
    output reg [2:0] reg_dst,
    output reg [2:0] reg_src1,
    output reg [2:0] reg_src2,
    output reg [15:0] immediate,
    output reg pc_update,
    output reg jump_z,
    output reg jump_nz,
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
    parameter LDM    = 4'b1100;
    parameter JZ     = 4'b1101;
    parameter JNZ    = 4'b1110;
    parameter HALT   = 4'b1111;
    
    always @(*) begin
        // Default values
        alu_op = 4'b0;
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        alu_src = 0;
        mem_to_reg = 0;
        reg_dst = 3'b0;
        reg_src1 = 3'b0;
        reg_src2 = 3'b0;
        immediate = 16'b0;
        pc_update = 1;
        jump_z = 0;
        jump_nz = 0;
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
            LDM: begin
                // Format: LDM Rd, addr (load from memory)
                reg_dst = instruction[11:9];
                immediate = {7'b0, instruction[8:0]};
                mem_read = 1;
                mem_to_reg = 1;
                reg_write = 1;
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
            JZ, JNZ: begin
                // Format: JZ/JNZ Rs, addr (conditional jump on Rs)
                // Rs is ORed with itself so the ALU zero flag reflects it
                reg_src1 = instruction[11:9];
                reg_src2 = instruction[11:9];
                immediate = {7'b0, instruction[8:0]};
                alu_op = 4'b0101; // OR operation
                jump_z  = (instruction[15:12] == JZ);
                jump_nz = (instruction[15:12] == JNZ);
            end
            HALT: begin
                halt = 1;
                pc_update = 0;
            end
            // Other register-register ALU operations
            MUL, DIV, AND, OR, NOT, XOR: begin
                reg_dst = instruction[11:9];
                reg_src1 = instruction[8:6];
                reg_src2 = instruction[5:3];
                reg_write = 1;
                // Map instruction opcode to the ALU's operation encoding
                case (instruction[15:12])
                    MUL: alu_op = 4'b0010;
                    DIV: alu_op = 4'b0011;
                    AND: alu_op = 4'b0100;
                    OR:  alu_op = 4'b0101;
                    NOT: alu_op = 4'b0110;
                    XOR: alu_op = 4'b0111;
                endcase
            end
            default: ; // Unknown opcode: treated as NOP
        endcase
    end
    
endmodule