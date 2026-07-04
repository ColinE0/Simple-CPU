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
    wire mem_to_reg;
    wire [2:0] reg_dst;
    wire [2:0] reg_src1;
    wire [2:0] reg_src2;
    wire [15:0] immediate;
    wire pc_update;
    wire jump_z;
    wire jump_nz;
    
    // Data paths
    wire [15:0] mem_data;
    wire [15:0] reg_data1;
    wire [15:0] reg_data2;
    wire [15:0] alu_result;
    wire alu_zero;
    wire alu_carry;
    
    // ALU second operand
    wire [15:0] alu_operand2 = alu_src ? immediate : reg_data2;

    // Conditional jump: JZ/JNZ pass the tested register through the ALU,
    // so the zero flag decides whether the immediate becomes the next PC
    wire take_branch = (jump_z & alu_zero) | (jump_nz & ~alu_zero);

    // Fetch/execute cycle: the single memory port is used for the
    // instruction fetch in FETCH and for data access in EXECUTE
    localparam FETCH   = 1'b0;
    localparam EXECUTE = 1'b1;
    reg state;

    wire [15:0] mem_address = (state == FETCH) ? pc : immediate;

    // Modules instantiation
    memory mem(
        .clk(clk),
        .address(mem_address),
        .write_data(reg_data1),
        .mem_read((state == FETCH) | mem_read),
        .mem_write(mem_write & (state == EXECUTE)),
        .read_data(mem_data)
    );
    
    register_file reg_file(
        .clk(clk),
        .reset(reset),
        .read_reg1(reg_src1),
        .read_reg2(reg_src2),
        .write_reg(reg_dst),
        .write_data(mem_to_reg ? mem_data : alu_result),
        .reg_write(reg_write & (state == EXECUTE)),
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
        .mem_to_reg(mem_to_reg),
        .reg_dst(reg_dst),
        .reg_src1(reg_src1),
        .reg_src2(reg_src2),
        .immediate(immediate),
        .pc_update(pc_update),
        .jump_z(jump_z),
        .jump_nz(jump_nz),
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
            state <= FETCH;
        end
        else if (!halt) begin
            if (state == FETCH) begin
                // Latch the instruction at PC
                ir <= mem_data;
                state <= EXECUTE;
            end
            else begin
                // Update PC after the instruction has executed:
                // unconditional JUMP or a taken JZ/JNZ loads the immediate
                if (!pc_update || take_branch)
                    pc <= immediate;
                else
                    pc <= pc + 1;
                state <= FETCH;
            end
        end
    end
    
endmodule