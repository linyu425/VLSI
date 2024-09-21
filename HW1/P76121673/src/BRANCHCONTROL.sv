// `include "./DEF.sv"

module BRANCHCONTROL (
    input [`BRANCH_TYPE_BITS - 1:0] Branch,
    input Zeroflag,
    output reg [`BRANCH_CTRL_BITS - 1:0] BranchCtrl
);

    localparam [`BRANCH_TYPE_BITS -1:0] NoBranch = `BRANCH_TYPE_BITS'b00,
                                        JalrBranch = `BRANCH_TYPE_BITS'b01,
                                        BBranch = `BRANCH_TYPE_BITS'b10,
                                        JBranch = `BRANCH_TYPE_BITS'b11;

    localparam [`BRANCH_CTRL_BITS - 1:0] PC4 = `BRANCH_CTRL_BITS'b10,
                                        PCIMM = `BRANCH_CTRL_BITS'b01,
                                        PCIMMR = `BRANCH_CTRL_BITS'b00;                                    

    always_comb begin
        case (Branch)
            NoBranch : BranchCtrl = PC4; //pc4
            JalrBranch : BranchCtrl = PCIMMR; //imm+rs1
            BBranch : begin
                if(Zeroflag) BranchCtrl = PCIMM; //imm
                else BranchCtrl = PC4;
            end
            default: BranchCtrl = PCIMM; //imm
        endcase
    end
    
endmodule