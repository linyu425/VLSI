// `include "./DEF.sv"
`include "./IMMG.sv"
`include "./REGFILE.sv"
`include "./CONTROL_UNIT.sv"

module IDEXER (
    input clk,
    input rst,
    input [`DATA_BITS - 1:0] instr,
    input [`ADDR_BITS - 1:0] ID_pc,
    input [`DATA_BITS - 1:0] MEMWB_rd_data,
    input [`REG_ADDR - 1:0] MEMWB_rd_addr,
    input CtrlSignalFlush,
    input WB_reg_write,

    output reg [`ADDR_BITS - 1:0] IDEXE_pc,
    output reg [`DATA_BITS - 1:0] IDEXE_rs1_data,
    output reg [`DATA_BITS - 1:0] IDEXE_rs2_data,
    output reg [`FUNCT3_BITS - 1:0] IDEXE_funct3,
    output reg [`FUNCT7_BITS - 1:0] IDEXE_funct7,
    output reg [`REG_ADDR - 1:0] IDEXE_rs1_addr,
    output reg [`REG_ADDR - 1:0] IDEXE_rs2_addr,
    output reg [`REG_ADDR - 1:0] IDEXE_rd_addr,
    output reg [`DATA_BITS - 1:0] IDEXE_imm,
    output reg [`ALU_TYPE_BITS - 1:0] IDEXE_ALUOP,
    output reg IDEXE_PCtoRegSrc,
    output reg IDEXE_ALUSrc,
    output reg IDEXE_RDSrc,
    output reg IDEXE_MemtoReg,
    output reg IDEXE_MemWrite,
    output reg IDEXE_MemRead,
    output reg IDEXE_RegWrite,
    output reg [`BRANCH_TYPE_BITS - 1:0] IDEXE_Branch,
    output reg IDEXE_CsrtoAlu,

    output [`REG_ADDR - 1:0] rs1_addr,
    output [`REG_ADDR - 1:0] rs2_addr
);
    
    wire [`DATA_BITS - 1:0] wire_imm;
    wire [`IMM_TYPE - 1:0] wire_Imm_Type;

    IMMG IMMG(
        .instr_out(instr),
        .Imm_Type(wire_Imm_Type),
        .imm(wire_imm)
    );

    wire [`DATA_BITS - 1:0] wire_rs1_data;
    wire [`DATA_BITS - 1:0] wire_rs2_data;

    REGFILE REGFILE(
        .clk(~clk),
        .rst(rst),
        .rs1_addr(instr[19:15]),
        .rs2_addr(instr[24:20]),
        .rd_addr(MEMWB_rd_addr),
        .rd_data(MEMWB_rd_data),
        .reg_write(WB_reg_write),
        .rs1_data(wire_rs1_data),
        .rs2_data(wire_rs2_data)
    );

    wire [`ALU_TYPE_BITS - 1:0] wire_ALUOP;
    wire wire_PCtoRegSrc;
    wire wire_ALUSrc;
    wire wire_RDSrc;
    wire wire_MemtoReg;
    wire wire_MemWrite;
    wire wire_MemRead;
    wire wire_RegWrite;
    wire [`BRANCH_TYPE_BITS - 1:0] wire_Branch;
    wire wire_CsrtoAlu;

    CONTROL_UNIT CONTROL_UNIT(
        .opcode(instr[6:0]),
        .ALUOP(wire_ALUOP),
        .PCtoRegSrc(wire_PCtoRegSrc),
        .ALUSrc(wire_ALUSrc),
        .RDSrc(wire_RDSrc),
        .MemtoReg(wire_MemtoReg),
        .MemWrite(wire_MemWrite),
        .MemRead(wire_MemRead),
        .RegWrite(wire_RegWrite),
        .Branch(wire_Branch),
        .Imm_Type(wire_Imm_Type),
        .CsrtoAlu(wire_CsrtoAlu)
    );

    always_ff @( posedge clk or posedge rst ) begin : blockName
        if(rst)begin
            IDEXE_pc <= `ADDR_BITS'd0;
            IDEXE_rs1_data <= `DATA_BITS'd0;
            IDEXE_rs2_data <= `DATA_BITS'd0;
            IDEXE_funct3 <= `FUNCT3_BITS'd0;
            IDEXE_funct7 <= `FUNCT7_BITS'd0;
            IDEXE_rs1_addr <= `REG_ADDR'd0;
            IDEXE_rs2_addr <= `REG_ADDR'd0;
            IDEXE_rd_addr <= `REG_ADDR'd0;
            IDEXE_imm <= `DATA_BITS'd0;

            IDEXE_ALUOP <= `ALU_TYPE_BITS'd0;
            IDEXE_PCtoRegSrc <= 1'd0;
            IDEXE_ALUSrc <= 1'd0;
            IDEXE_RDSrc <= 1'd0;
            IDEXE_MemtoReg <= 1'd0;
            IDEXE_MemWrite <= 1'd0;
            IDEXE_MemRead <= 1'd0;
            IDEXE_RegWrite <= 1'd0;
            IDEXE_Branch <= `BRANCH_TYPE_BITS'd0;
            IDEXE_CsrtoAlu <= 1'd0;
        end
        else begin
            IDEXE_pc <= ID_pc;
            IDEXE_rs1_data <= wire_rs1_data;
            IDEXE_rs2_data <= wire_rs2_data;
            IDEXE_funct3 <= instr[14:12];
            IDEXE_funct7 <= instr[31:25];
            IDEXE_rs1_addr <= instr[19:15];
            IDEXE_rs2_addr <= instr[24:20];
            IDEXE_rd_addr <= instr[11:7];
            IDEXE_imm <= wire_imm;

            IDEXE_ALUOP <= wire_ALUOP;
            IDEXE_PCtoRegSrc <= wire_PCtoRegSrc;
            IDEXE_ALUSrc <= wire_ALUSrc;
            IDEXE_RDSrc <= wire_RDSrc;
            IDEXE_MemtoReg <= wire_MemtoReg;
            IDEXE_CsrtoAlu <= wire_CsrtoAlu;
            if(!CtrlSignalFlush)begin
                IDEXE_MemWrite <= wire_MemWrite;
                IDEXE_MemRead <= wire_MemRead;
                IDEXE_RegWrite <= wire_RegWrite;
                IDEXE_Branch <= wire_Branch;
            end
            else begin
                IDEXE_MemWrite <= 1'd0;
                IDEXE_MemRead <= 1'd0;
                IDEXE_RegWrite <= 1'd0;
                IDEXE_Branch <= `BRANCH_TYPE_BITS'd0;
            end
        end
    end

    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
endmodule