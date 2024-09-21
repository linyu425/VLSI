// `include "./DEF.sv"

module WB (
    input clk,
    input rst,
    input MEMWB_MemtoReg,
    input MEMWB_RegWrite,
    input [`DATA_BITS - 1:0] MEMWB_rd_data, 
    input [`DATA_BITS - 1:0] MEMWB_Dout,
    input [`REG_ADDR - 1:0] MEMWB_rd_addr,

    output WB_RegWrite,
    output [`DATA_BITS - 1:0] WB_rd_data,
    output [`REG_ADDR - 1:0] WB_rd_addr
);

    assign WB_RegWrite = MEMWB_RegWrite;
    assign WB_rd_data = (MEMWB_MemtoReg == 1'b1) ? MEMWB_Dout : MEMWB_rd_data;
    assign WB_rd_addr = MEMWB_rd_addr;
    
endmodule