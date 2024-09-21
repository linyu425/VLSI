// `include "./DEF.sv"

module FORWARDUNIT (
    input [`REG_ADDR - 1:0] IDEXE_rs1_addr,
    input [`REG_ADDR - 1:0] IDEXE_rs2_addr,
    input [`REG_ADDR - 1:0] EXEMEM_rd_addr,
    input [`REG_ADDR - 1:0] MEMWB_rd_addr,
    input EXEMEM_reg_write,
    input MEMWB_reg_write,
    output reg [`FORWARDMUX - 1:0] Forward_A,
    output reg [`FORWARDMUX - 1:0] Forward_B
);

    always_comb begin
        if(EXEMEM_reg_write && (EXEMEM_rd_addr == IDEXE_rs1_addr)) Forward_A = `FORWARDMUX'b01;
        else if(MEMWB_reg_write && (MEMWB_rd_addr == IDEXE_rs1_addr)) Forward_A = `FORWARDMUX'b10;
        else Forward_A = `FORWARDMUX'b00;

        if(EXEMEM_reg_write && (EXEMEM_rd_addr == IDEXE_rs2_addr)) Forward_B = `FORWARDMUX'b01;
        else if(MEMWB_reg_write && (MEMWB_rd_addr == IDEXE_rs2_addr)) Forward_B = `FORWARDMUX'b10;
        else Forward_B = `FORWARDMUX'b00;
    end
    
endmodule