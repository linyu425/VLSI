`include "./DEF.sv"
`include "./IFIDR_MUX.sv"
`include "./IDEXER.sv"
`include "./EXEMEMR.sv"
`include "./MEMWBR.sv"
`include "./WB.sv"
`include "./SRAM_wrapper.sv"
`include "./FORWARDUNIT.sv"
`include "./BRANCHCONTROL.sv"
`include "./HAZARDCONTROL.sv"

module top (
    input clk,
    input rst
);

    wire wire_Instr_flush;
    wire wire_IFID_RegWrite;
    wire [`DATA_BITS - 1:0] wire_instr_out;
    wire wire_PC_write;
    wire [`ADDR_BITS - 1:0] wire_pcimmrs1;
    wire [`ADDR_BITS - 1:0] wire_pcimm;
    wire [`BRANCH_CTRL_BITS - 1:0] wire_BranchCtrl;

    wire [`DATA_BITS - 1:0] wire_IFID_Instr_out;
    wire [`ADDR_BITS - 1:0] wire_IFID_pc_out;
    wire [`ADDR_BITS - 1:0] wire_pc_out;

    IFIDR_MUX  IFIDR_MUX(
    .clk(clk),
    .rst(rst),
    .Instr_Flush(wire_Instr_flush),
    .IFID_RegWrite(wire_IFID_RegWrite),
    .instr_out(wire_instr_out),
    .pc_write(wire_PC_write),
    .pc_immrs1(wire_pcimmrs1),
    .pc_imm(wire_pcimm),
    .BranchCtrl(wire_BranchCtrl),

    .IFID_Instr_out(wire_IFID_Instr_out),
    .IFID_pc_out(wire_IFID_pc_out),
    .pc_out(wire_pc_out)
    );

    SRAM_wrapper IM1 (
      .CK(~clk),
      .CS(1'b1),
      .OE(1'b1),
      .WEB(4'b1111),  // low active
      .A(wire_pc_out[15:2]),
      .DI(32'b0),
      .DO(wire_instr_out)
    );

    wire [`DATA_BITS - 1:0] wire_MEMWB_rd_data;//
    wire [`REG_ADDR - 1:0] wire_MEMWB_rd_addr;
    wire wire_CtrlSignalFlush; //
    wire wire_WB_reg_write;
    wire [`DATA_BITS - 1:0] wire_WB_rd_data;
    wire [`REG_ADDR - 1:0] wire_WB_rd_addr;

    wire [`ADDR_BITS - 1:0] wire_IDEXE_pc;
    wire [`DATA_BITS - 1:0] wire_IDEXE_rs1_data;
    wire [`DATA_BITS - 1:0] wire_IDEXE_rs2_data;
    wire [`FUNCT3_BITS - 1:0] wire_IDEXE_funct3;
    wire [`FUNCT7_BITS - 1:0] wire_IDEXE_funct7;
    wire [`REG_ADDR - 1:0] wire_IDEXE_rs1_addr;
    wire [`REG_ADDR - 1:0] wire_IDEXE_rs2_addr;
    wire [`REG_ADDR - 1:0] wire_IDEXE_rd_addr;
    wire [`DATA_BITS - 1:0] wire_IDEXE_imm;
    wire [`ALU_TYPE_BITS - 1:0] wire_IDEXE_ALUOP;
    wire wire_IDEXE_PCtoRegSrc;
    wire wire_IDEXE_ALUSrc;
    wire wire_IDEXE_RDSrc;
    wire wire_IDEXE_MemtoReg;
    wire wire_IDEXE_MemWrite;
    wire wire_IDEXE_MemRead;
    wire wire_IDEXE_RegWrite;
    wire [`BRANCH_TYPE_BITS - 1:0] wire_IDEXE_Branch;
    wire [`REG_ADDR - 1:0] wire_rs1_addr;
    wire [`REG_ADDR - 1:0] wire_rs2_addr;
    wire wire_IDEXE_CsrtoAlu;


    IDEXER IDEXER (
    .clk(clk),
    .rst(rst),
    .instr(wire_IFID_Instr_out),
    .ID_pc(wire_IFID_pc_out),
    .MEMWB_rd_data(wire_WB_rd_data),
    .MEMWB_rd_addr(wire_WB_rd_addr),
    .CtrlSignalFlush(wire_CtrlSignalFlush),
    .WB_reg_write(wire_WB_reg_write),
    

    .IDEXE_pc(wire_IDEXE_pc),
    .IDEXE_rs1_data(wire_IDEXE_rs1_data),
    .IDEXE_rs2_data(wire_IDEXE_rs2_data),
    .IDEXE_funct3(wire_IDEXE_funct3),
    .IDEXE_funct7(wire_IDEXE_funct7),
    .IDEXE_rs1_addr(wire_IDEXE_rs1_addr),
    .IDEXE_rs2_addr(wire_IDEXE_rs2_addr),
    .IDEXE_rd_addr(wire_IDEXE_rd_addr),
    .IDEXE_imm(wire_IDEXE_imm),
    .IDEXE_ALUOP(wire_IDEXE_ALUOP),
    .IDEXE_PCtoRegSrc(wire_IDEXE_PCtoRegSrc),
    .IDEXE_ALUSrc(wire_IDEXE_ALUSrc),
    .IDEXE_RDSrc(wire_IDEXE_RDSrc),
    .IDEXE_MemtoReg(wire_IDEXE_MemtoReg),
    .IDEXE_MemWrite(wire_IDEXE_MemWrite),
    .IDEXE_MemRead(wire_IDEXE_MemRead),
    .IDEXE_RegWrite(wire_IDEXE_RegWrite),
    .IDEXE_Branch(wire_IDEXE_Branch),
    .IDEXE_CsrtoAlu(wire_IDEXE_CsrtoAlu),
    .rs1_addr(wire_rs1_addr),
    .rs2_addr(wire_rs2_addr)
    );

    wire [`REG_ADDR - 1:0] wire_EXEMEM_rd_addr; //
    wire [`FORWARDMUX - 1:0] wire_Forward_A; //
    wire [`FORWARDMUX - 1:0] wire_Forward_B; //
    wire [`INSTR_COUNT_TYPES - 1:0] wire_stall_type;

    wire wire_EXEMEM_RDSrc;
    wire wire_EXEMEM_MemtoReg;
    wire wire_EXEMEM_MemWrite;
    wire wire_EXEMEM_MemRead;
    wire wire_EXEMEM_RegWrite;
    wire wire_Zeroflag; //
    wire [`ADDR_BITS - 1:0] wire_EXEMEM_pc_to_reg;
    wire [`DATA_BITS - 1:0] wire_EXEMEM_ALU_out;
    wire [`DATA_BITS - 1:0] wire_EXEMEM_rs2_data;
    wire [`FUNCT3_BITS - 1:0] wire_EXEMEM_funct3;
    wire [`DATA_BITS - 1:0] wire_MEM_rd_data;
    

    EXEMEMR EXEMEMR (
    .clk(clk),
    .rst(rst),
    .IDEXE_ALUOP(wire_IDEXE_ALUOP),
    .IDEXE_PCtoRegSrc(wire_IDEXE_PCtoRegSrc),
    .IDEXE_ALUSrc(wire_IDEXE_ALUSrc),
    .IDEXE_RDSrc(wire_IDEXE_RDSrc),
    .IDEXE_MemtoReg(wire_IDEXE_MemtoReg),
    .IDEXE_MemWrite(wire_IDEXE_MemWrite),
    .IDEXE_MemRead(wire_IDEXE_MemRead),
    .IDEXE_RegWrite(wire_IDEXE_RegWrite),
    .IDEXE_pc(wire_IDEXE_pc),
    .IDEXE_rs1_data(wire_IDEXE_rs1_data),
    .IDEXE_rs2_data(wire_IDEXE_rs2_data),
    .IDEXE_funct3(wire_IDEXE_funct3),
    .IDEXE_funct7(wire_IDEXE_funct7),
    .IDEXE_rs1_addr(wire_IDEXE_rs1_addr),
    .IDEXE_rs2_addr(wire_IDEXE_rs2_addr),
    .IDEXE_rd_addr(wire_IDEXE_rd_addr),
    .IDEXE_imm(wire_IDEXE_imm),
    .Forward_EXEMEM(wire_MEM_rd_data),
    .Forward_MEMWB(wire_WB_rd_data),
    .Forward_A(wire_Forward_A),
    .Forward_B(wire_Forward_B),
    .stall_type(wire_stall_type),
    .IDEXE_CsrtoAlu(wire_IDEXE_CsrtoAlu),

    .EXEMEM_RDSrc(wire_EXEMEM_RDSrc),
    .EXEMEM_MemtoReg(wire_EXEMEM_MemtoReg),
    .EXEMEM_MemWrite(wire_EXEMEM_MemWrite),
    .EXEMEM_MemRead(wire_EXEMEM_MemRead),
    .EXEMEM_RegWrite(wire_EXEMEM_RegWrite),
    .Zeroflag(wire_Zeroflag),
    .EXEMEM_pc_to_reg(wire_EXEMEM_pc_to_reg),
    .EXEMEM_ALU_out(wire_EXEMEM_ALU_out),
    .EXEMEM_rs2_data(wire_EXEMEM_rs2_data),
    .EXEMEM_rd_addr(wire_EXEMEM_rd_addr),
    .EXEMEM_funct3(wire_EXEMEM_funct3),
    

    .pc_imm(wire_pcimm),
    .pc_immrs1(wire_pcimmrs1)
    );

    

    wire [`DATA_BITS - 1:0] wire_Dout;

    wire wire_MEMWB_MemtoReg;
    wire wire_MEMWB_RegWrite;
    wire [`DATA_BITS - 1:0] wire_MEMWB_Dout;//
    wire [`DATA_BITS - 1:0] wire_Din;//
    wire [3:0] wire_writeEnable;//
    wire wire_chipSelect;
    

    MEMWBR MEMWBR (
    .clk(clk),
    .rst(rst),
    .EXEMEM_RDSrc(wire_EXEMEM_RDSrc),
    .EXEMEM_MemtoReg(wire_EXEMEM_MemtoReg),
    .EXEMEM_MemWrite(wire_EXEMEM_MemWrite),
    .EXEMEM_MemRead(wire_EXEMEM_MemRead),
    .EXEMEM_RegWrite(wire_EXEMEM_RegWrite),
    .EXEMEM_pc_to_reg(wire_EXEMEM_pc_to_reg),
    .EXEMEM_ALU_out(wire_EXEMEM_ALU_out),
    .EXEMEM_rs2_data(wire_EXEMEM_rs2_data),
    .EXEMEM_rd_addr(wire_EXEMEM_rd_addr),
    .EXEMEM_funct3(wire_EXEMEM_funct3),
    .DM_Dout(wire_Dout),

    .MEMWB_MemtoReg(wire_MEMWB_MemtoReg),
    .MEMWB_RegWrite(wire_MEMWB_RegWrite),
    .MEMWB_rd_data(wire_MEMWB_rd_data), 
    .MEMWB_Dout(wire_MEMWB_Dout),
    .MEMWB_rd_addr(wire_MEMWB_rd_addr),
    .Din(wire_Din),
    .wire_writeEnable(wire_writeEnable),
    .wire_MEM_rd_data(wire_MEM_rd_data),
    .chipSelect(wire_chipSelect)
    );

    SRAM_wrapper DM1 (
      .CK (~clk),
      .CS (wire_chipSelect),
      .OE (wire_EXEMEM_MemRead),
      //.WEB({4{~EXE_MemWrite}}),
      .WEB(wire_writeEnable),
      .A  (wire_EXEMEM_ALU_out[15:2]),
      //.DI(EXE_rs2_data),
      .DI (wire_Din),
      .DO (wire_Dout)
    );

    WB WB (
    .clk(clk),
    .rst(rst),
    .MEMWB_MemtoReg(wire_MEMWB_MemtoReg),
    .MEMWB_RegWrite(wire_MEMWB_RegWrite),
    .MEMWB_rd_data(wire_MEMWB_rd_data),
    .MEMWB_Dout(wire_MEMWB_Dout),
    .MEMWB_rd_addr(wire_MEMWB_rd_addr),

    .WB_RegWrite(wire_WB_reg_write),
    .WB_rd_data(wire_WB_rd_data),
    .WB_rd_addr(wire_WB_rd_addr)
    );

    FORWARDUNIT FORWARDUNIT (
    .IDEXE_rs1_addr(wire_IDEXE_rs1_addr),
    .IDEXE_rs2_addr(wire_IDEXE_rs2_addr),
    .EXEMEM_rd_addr(wire_EXEMEM_rd_addr),
    .MEMWB_rd_addr(wire_MEMWB_rd_addr),
    .EXEMEM_reg_write(wire_EXEMEM_RegWrite),
    .MEMWB_reg_write(wire_MEMWB_RegWrite),

    .Forward_A(wire_Forward_A),
    .Forward_B(wire_Forward_B)
    );

    BRANCHCONTROL BRANCHCONTROL (
    .Branch(wire_IDEXE_Branch),
    .Zeroflag(wire_Zeroflag),
    .BranchCtrl(wire_BranchCtrl)
    );

    HAZARDCONTROL HAZARDCONTROL (
    .rs1_addr(wire_rs1_addr),
    .rs2_addr(wire_rs2_addr),
    .IDEXE_rd_addr(wire_IDEXE_rd_addr),
    .BranchCtrl(wire_BranchCtrl),
    .IDEXE_MemRead(wire_IDEXE_MemRead),

    .PC_write(wire_PC_write),
    .Instr_flush(wire_Instr_flush),
    .IFID_RegWrite(wire_IFID_RegWrite),
    .CtrlSignalFlush(wire_CtrlSignalFlush),
    .Stall_type(wire_stall_type)
    );

endmodule