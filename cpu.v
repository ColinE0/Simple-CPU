module cpu(
    input clk,
    input reset,
    output [15:0] pc_out,
    output [15:0] alu_out,
    output [15:0] mem_data_out,
    output [15:0] reg_data_out,
    output halt
);
    
    // Program Counter
    reg [15:0] pc;
    assign pc_out = pc;
    
    // Instruction register
    reg [15:0] ir;
    
    // Control signals
    wire [3:0] alu_op;
    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire alu_src;
    wire [2:0] reg_dst;
    wire [2:0] reg_src1;
    wire [2:0] reg_src2;
    wire [15:0] immediate;
    wire pc_update;
    
    // Data paths
    wire [15:0] mem_data;
    wire [15:0] reg_data1;
    wire [15:0] reg_data2;
    wire [15:0] alu_result;
    wire alu_zero;
    wire alu_carry;
    
    // ALU second operand
    wire [15:0] alu_operand2 = alu_src ? immediate : reg_data2;
    
    // Modules instantiation
    memory mem(
        .clk(clk),
        .address(pc),
        .write_data(reg_data1),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(mem_data)
    );
    
    register_file reg_file(
        .clk(clk),
        .reset(reset),
        .read_reg1(reg_src1),
        .read_reg2(reg_src2),
        .write_reg(reg_dst),
        .write_data(alu_result),
        .reg_write(reg_write),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );
    
    alu alu_unit(
        .opcode(alu_op),
        .operand1(reg_data1),
        .operand2(alu_operand2),
        .result(alu_result),
        .zero_flag(alu_zero),
        .carry_flag(alu_carry)
    );
    
    control_unit ctrl(
        .instruction(ir),
        .alu_op(alu_op),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_dst(reg_dst),
        .reg_src1(reg_src1),
        .reg_src2(reg_src2),
        .immediate(immediate),
        .pc_update(pc_update),
        .halt(halt)
    );
    
    // Assign outputs for testbench
    assign alu_out = alu_result;
    assign mem_data_out = mem_data;
    assign reg_data_out = reg_data1;
    
    // CPU operation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 16'b0;
            ir <= 16'b0;
        end
        else if (!halt) begin
            // Instruction fetch
            ir <= mem_data;
            
            // Update PC
            if (pc_update)
                pc <= pc + 1;
            else
                pc <= immediate;
        end
    end
    
endmodule