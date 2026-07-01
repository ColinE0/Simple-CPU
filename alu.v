module alu(
    input [3:0] opcode,
    input [15:0] operand1,
    input [15:0] operand2,
    output reg [15:0] result,
    output reg zero_flag,
    output reg carry_flag
);
    
    // Operation codes (4-bit binary)
    parameter ADD  = 4'b0000;
    parameter SUB  = 4'b0001;
    parameter MUL  = 4'b0010;
    parameter DIV  = 4'b0011;
    parameter AND  = 4'b0100;
    parameter OR   = 4'b0101;
    parameter NOT  = 4'b0110;
    parameter XOR  = 4'b0111;
    parameter MOV  = 4'b1000;
    
    // Combinational logic for ALU operations
    always @(*) begin
        carry_flag = 0;
        zero_flag = 0;
        
        case(opcode)
            ADD: begin
                {carry_flag, result} = operand1 + operand2;
            end
            SUB: begin
                result = operand1 - operand2;
                if (operand2 > operand1) carry_flag = 1;
            end
            MUL: begin
                result = operand1 * operand2;
            end
            DIV: begin
                result = operand1 / operand2;
            end
            AND: begin
                result = operand1 & operand2;
            end
            OR: begin
                result = operand1 | operand2;
            end
            NOT: begin
                result = ~operand1;
            end
            XOR: begin
                result = operand1 ^ operand2;
            end
            MOV: begin
                result = operand2;
            end
            default: begin
                result = 16'b0;
            end
        endcase
        
        // Set zero flag if result is zero
        if (result == 16'b0) zero_flag = 1;
    end
    
endmodule