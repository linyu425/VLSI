// `include "./DEF.sv"
`include "./ALU.sv"
`include "./ALUCONTROL.sv"
`include "./COUNTER.sv"

module EXEMEMR (
    input clk,
    input rst,
    input [`ALU_TYPE_BITS - 1:0] IDEXE_ALUOP,
    input IDEXE_PCtoRegSrc,
    input IDEXE_ALUSrc,
    input IDEXE_RDSrc,
    input IDEXE_MemtoReg,
    input IDEXE_MemWrite,
    input IDEXE_MemRead,
    input IDEXE_RegWrite,
    input [`ADDR_BITS - 1:0] IDEXE_pc,
    input [`DATA_BITS - 1:0] IDEXE_rs1_data,
    input [`DATA_BITS - 1:0] IDEXE_rs2_data,
    input [`FUNCT3_BITS - 1:0] IDEXE_funct3,
    input [`FUNCT7_BITS - 1:0] IDEXE_funct7,
    input [`REG_ADDR - 1:0] IDEXE_rs1_addr,
    input [`REG_ADDR - 1:0] IDEXE_rs2_addr,
    input [`REG_ADDR - 1:0] IDEXE_rd_addr,
    input [`DATA_BITS - 1:0] IDEXE_imm,
    input [`DATA_BITS - 1:0] Forward_EXEMEM,
    input [`DATA_BITS - 1:0] Forward_MEMWB,
    input [`FORWARDMUX - 1:0] Forward_A,
    input [`FORWARDMUX - 1:0] Forward_B,
    input [`INSTR_COUNT_TYPES - 1:0] stall_type,
    input IDEXE_CsrtoAlu,

    output reg EXEMEM_RDSrc,
    output reg EXEMEM_MemtoReg,
    output reg EXEMEM_MemWrite,
    output reg EXEMEM_MemRead,
    output reg EXEMEM_RegWrite,
    output Zeroflag,
    output reg [`ADDR_BITS - 1:0] EXEMEM_pc_to_reg,
    output reg [`DATA_BITS - 1:0] EXEMEM_ALU_out,
    output reg [`DATA_BITS - 1:0] EXEMEM_rs2_data,
    output reg [`REG_ADDR - 1:0] EXEMEM_rd_addr,
    output reg [`FUNCT3_BITS - 1:0] EXEMEM_funct3,

    output [`ADDR_BITS - 1:0] pc_imm,
    output [`ADDR_BITS - 1:0] pc_immrs1
    );

    assign pc_imm = IDEXE_pc + IDEXE_imm;

    wire [`ALU_CTRL_BITS - 1:0] wire_ALU_Ctrl;

    ALUCONTROL ALUCONTROL(
        .IDEXE_ALUOP(IDEXE_ALUOP),
        .IDEXE_funct3(IDEXE_funct3),
        .IDEXE_funct7(IDEXE_funct7),
        .ALU_Ctrl(wire_ALU_Ctrl)
    );

    reg [`DATA_BITS - 1:0] wire_rs1_data;
    reg [`DATA_BITS - 1:0] wire_rs2_data;
    reg [`DATA_BITS - 1:0] wire_forward_rs2;
    wire [`DATA_BITS - 1:0] wire_ALU_out;
    reg [`ADDR_BITS - 1:0] wire_pc_to_reg;
    reg [`DATA_BITS - 1:0] wire_final_ALU_out;
    wire [`COUNTER_BITS - 1:0] wire_instret_out;
    wire [`COUNTER_BITS - 1:0] wire_cycle_out;

    assign pc_immrs1 = wire_ALU_out;

    always_comb begin
        case (Forward_A)
            `FORWARDMUX'b00 : wire_rs1_data = IDEXE_rs1_data;
            `FORWARDMUX'b01 : wire_rs1_data = Forward_EXEMEM;
            default: wire_rs1_data = Forward_MEMWB;
        endcase

        case (Forward_B)
            `FORWARDMUX'b00 : wire_forward_rs2 = IDEXE_rs2_data;
            `FORWARDMUX'b01 : wire_forward_rs2 = Forward_EXEMEM;
            default: wire_forward_rs2 = Forward_MEMWB;
        endcase

        if(IDEXE_ALUSrc) wire_rs2_data = wire_forward_rs2;
        else wire_rs2_data = IDEXE_imm;

        if(IDEXE_PCtoRegSrc) wire_pc_to_reg = IDEXE_pc + IDEXE_imm;
        else wire_pc_to_reg = IDEXE_pc + `ADDR_BITS'd4;

        if(IDEXE_CsrtoAlu)begin
            case (IDEXE_imm[11:0])
                `CSR_IMM_BITS'b110010000010 : wire_final_ALU_out = wire_instret_out[63:32];
                `CSR_IMM_BITS'b110000000010 : wire_final_ALU_out = wire_instret_out[31:0];
                `CSR_IMM_BITS'b110010000000 : wire_final_ALU_out = wire_cycle_out[63:32];
                default: wire_final_ALU_out = wire_cycle_out[31:0];
            endcase
        end
        else wire_final_ALU_out = wire_ALU_out;
    end

    
    

    COUNTER COUNTER(
        .clk(clk),
        .rst(rst),
        .stall_type(stall_type),
        .instret_out(wire_instret_out),
        .cycle_out(wire_cycle_out)
    );

    ALU ALU(
        .rs1_data(wire_rs1_data),
        .rs2_data(wire_rs2_data),
        .ALU_Ctrl(wire_ALU_Ctrl),
        .ALU_out(wire_ALU_out),
        .Zeroflag(Zeroflag)
    );

    

    always_ff @( posedge clk or posedge rst ) begin
        if(rst)begin
            EXEMEM_RDSrc <= 1'b0;
            EXEMEM_MemtoReg <= 1'b0;
            EXEMEM_MemWrite <= 1'b0;
            EXEMEM_MemRead <= 1'b0;
            EXEMEM_RegWrite <= 1'b0;
            EXEMEM_pc_to_reg <= `ADDR_BITS'd0;
            EXEMEM_ALU_out <= `DATA_BITS'd0;
            EXEMEM_rs2_data <= `DATA_BITS'd0;
            EXEMEM_rd_addr <= `REG_ADDR'd0;
            EXEMEM_funct3 <= `FUNCT3_BITS'd0;
        end
        else begin
            EXEMEM_RDSrc <= IDEXE_RDSrc;
            EXEMEM_MemtoReg <= IDEXE_MemtoReg;
            EXEMEM_MemWrite <= IDEXE_MemWrite;
            EXEMEM_MemRead <= IDEXE_MemRead;
            EXEMEM_RegWrite <= IDEXE_RegWrite;
            EXEMEM_ALU_out <= wire_final_ALU_out;
            EXEMEM_rs2_data <= wire_forward_rs2;
            EXEMEM_rd_addr <= IDEXE_rd_addr;
            EXEMEM_pc_to_reg <= wire_pc_to_reg;
            EXEMEM_funct3 <= IDEXE_funct3;
        end
    end
    
endmodule