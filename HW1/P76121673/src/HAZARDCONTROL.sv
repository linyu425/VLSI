// `include "./DEF.sv"

module HAZARDCONTROL (
    input [`REG_ADDR - 1:0] rs1_addr,
    input [`REG_ADDR - 1:0] rs2_addr,
    input [`REG_ADDR - 1:0] IDEXE_rd_addr,
    input [`BRANCH_CTRL_BITS - 1:0] BranchCtrl,
    input IDEXE_MemRead,

    output reg PC_write,
    output reg Instr_flush,
    output reg IFID_RegWrite,
    output reg CtrlSignalFlush,
    output reg [`INSTR_COUNT_TYPES - 1:0] Stall_type 
);
    localparam [`BRANCH_CTRL_BITS - 1:0] PC4 = `BRANCH_CTRL_BITS'b10,
                                        PCIMM = `BRANCH_CTRL_BITS'b01,
                                        PCIMMR = `BRANCH_CTRL_BITS'b00;

    localparam B_stall = `INSTR_COUNT_TYPES'b00,
                LU_stall = `INSTR_COUNT_TYPES'b01,
                no_stall = `INSTR_COUNT_TYPES'b10;    

    always_comb begin
        if(BranchCtrl != PC4)begin
            PC_write = 1'b1;
            Instr_flush = 1'b1;
            IFID_RegWrite = 1'b1;
            CtrlSignalFlush = 1'b1;
            Stall_type = B_stall;
        end
        else if(IDEXE_MemRead && ((IDEXE_rd_addr == rs1_addr) || (IDEXE_rd_addr == rs2_addr)))begin
            PC_write = 1'b0;
            Instr_flush = 1'b0;
            IFID_RegWrite = 1'b0;
            CtrlSignalFlush = 1'b1;
            Stall_type = LU_stall;
        end
        else begin
            PC_write = 1'b1;
            Instr_flush = 1'b0;
            IFID_RegWrite = 1'b1;
            CtrlSignalFlush = 1'b0;
            Stall_type = no_stall;
        end
    end
    
endmodule