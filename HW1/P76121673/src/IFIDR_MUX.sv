// `include "./DEF.sv"
`include "./PC_MUX.sv"

module  IFIDR_MUX(
    input clk,
    input rst,
    input Instr_Flush,
    input IFID_RegWrite,
    input [`DATA_BITS - 1:0] instr_out,
    input pc_write,
    input [`ADDR_BITS - 1:0] pc_immrs1,
    input [`ADDR_BITS - 1:0] pc_imm,
    input [`BRANCH_CTRL_BITS - 1:0] BranchCtrl,

    output reg [`DATA_BITS - 1:0] IFID_Instr_out,
    output reg [`ADDR_BITS - 1:0] IFID_pc_out,
    output [`ADDR_BITS - 1:0] pc_out
);

localparam [`BRANCH_CTRL_BITS - 1:0] PC4 = `BRANCH_CTRL_BITS'b10,
                                        PCIMM = `BRANCH_CTRL_BITS'b01,
                                        PCIMMR = `BRANCH_CTRL_BITS'b00;

wire [`ADDR_BITS - 1 :0] wire_pc_out;
reg [`ADDR_BITS - 1:0] pc_in;
wire [`ADDR_BITS - 1:0] pc_4;

assign pc_4 = wire_pc_out + `ADDR_BITS'd4;

assign pc_out = wire_pc_out;

PC_MUX PC_MUX(
    .clk(clk),
    .rst(rst),
    .pc_write(pc_write),
    .pc_in(pc_in),
    .pc_out(wire_pc_out)
);

always_comb begin : MUX
    case (BranchCtrl)
        PCIMMR : pc_in = pc_immrs1;
        PCIMM : pc_in = pc_imm;
        default: pc_in = pc_4;
    endcase
end

always_ff @(posedge clk or posedge rst)begin
    if(rst)begin
        IFID_Instr_out <= `DATA_BITS'd0;
        IFID_pc_out <= `ADDR_BITS'd0;
    end
    else begin
        if(IFID_RegWrite)begin
            IFID_pc_out <= wire_pc_out;
            if(Instr_Flush) IFID_Instr_out <= `DATA_BITS'd0;
            else IFID_Instr_out <= instr_out;
        end
    end
end

endmodule