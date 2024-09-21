// `include "./DEF.sv"

module  IMMG(
    input [`DATA_BITS - 1:0] instr_out,
    input [`IMM_TYPE - 1:0] Imm_Type,
    output reg [`DATA_BITS - 1:0] imm
);

    localparam [`IMM_TYPE - 1:0] I_Type = `IMM_TYPE'b000,
                                    S_Type = `IMM_TYPE'b001,
                                    B_Type = `IMM_TYPE'b010,
                                    U_Type = `IMM_TYPE'b011,
                                    J_Type = `IMM_TYPE'b100,
                                    CSR_Type = `IMM_TYPE'b101;

    always_comb begin
        case(Imm_Type)
            I_Type : imm = {{20{instr_out[31]}} , instr_out[31:20]};
            S_Type : imm = {{20{instr_out[31]}} , instr_out[31:25] , instr_out[11:7]};
            B_Type : imm = {{19{instr_out[31]}} , instr_out[31] , instr_out[7] , instr_out[30:25] , instr_out[11:8] , 1'b0};
            U_Type : imm = {instr_out[31:12] , 12'd0};
            CSR_Type : imm = {{20{instr_out[31]}}, instr_out[31:20]};
            default : imm = {{11{instr_out[31]}} , instr_out[31] , instr_out[19:12] , instr_out[20] , instr_out[30:21],1'b0};
        endcase
    end

endmodule