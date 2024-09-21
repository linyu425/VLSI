// `include "./DEF.sv"

module  REGFILE(
    input clk,
    input rst,
    input [`REG_ADDR - 1:0] rs1_addr,
    input [`REG_ADDR - 1:0] rs2_addr,
    input [`REG_ADDR - 1:0] rd_addr,
    input [`DATA_BITS - 1:0] rd_data,
    input reg_write,
    output [`DATA_BITS - 1:0] rs1_data,
    output [`DATA_BITS - 1:0] rs2_data
);

    reg [31:0] register[31:0];

    assign rs1_data = register[rs1_addr];
    assign rs2_data = register[rs2_addr];

    integer i;
    always_ff @( posedge clk or posedge rst ) begin
        if(rst)begin
            for(i = 0; i < 32; i++) register[i] <= `DATA_BITS'd0;
        end
        else begin
            if(reg_write && (rd_addr != `REG_ADDR'd0)) register[rd_addr] <= rd_data;
        end
    end

endmodule