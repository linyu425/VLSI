// `include "./DEF.sv"

module CONTROL_UNIT (
    input [`OPCODE_BITS - 1:0] opcode,
    output reg [`ALU_TYPE_BITS - 1:0] ALUOP,
    output reg PCtoRegSrc,
    output reg ALUSrc,
    output reg RDSrc,
    output reg MemtoReg,
    output reg MemWrite,
    output reg MemRead,
    output reg RegWrite,
    output reg [`BRANCH_TYPE_BITS - 1:0] Branch,
    output reg [`IMM_TYPE - 1:0] Imm_Type,
    output reg CsrtoAlu
);
    localparam [`BRANCH_TYPE_BITS -1:0] NoBranch = `BRANCH_TYPE_BITS'b00,
                                        JalrBranch = `BRANCH_TYPE_BITS'b01,
                                        BBranch = `BRANCH_TYPE_BITS'b10,
                                        JBranch = `BRANCH_TYPE_BITS'b11;

    localparam [`IMM_TYPE - 1:0] I_Type = `IMM_TYPE'b000,
                                    S_Type = `IMM_TYPE'b001,
                                    B_Type = `IMM_TYPE'b010,
                                    U_Type = `IMM_TYPE'b011,
                                    J_Type = `IMM_TYPE'b100,
                                    CSR_Type = `IMM_TYPE'b101;

    localparam [`ALU_TYPE_BITS - 1:0] R_ALU = `ALU_TYPE_BITS'b000, //reg+reg
                                        I_ALU = `ALU_TYPE_BITS'b001, //reg+imm
                                        ADD_ALU = `ALU_TYPE_BITS'b010, //reg+reg lw
                                        JALR_ALU = `ALU_TYPE_BITS'b011, //reg+pc
                                        B_ALU = `ALU_TYPE_BITS'b100, // reg+reg b
                                        LUI_ALU = `ALU_TYPE_BITS'b101;

    always_comb begin
        case (opcode)
            `OPCODE_BITS'b0110011 : begin //R_type
                ALUOP = R_ALU;
                PCtoRegSrc = 1'b0; //dc
                ALUSrc = 1'b1; //reg
                RDSrc = 1'b0; //ALU
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                RegWrite = 1'b1;
                Branch = NoBranch;
                Imm_Type = I_Type;//dc
                CsrtoAlu = 1'b0;
            end

            /*`OPCODE_BITS'b0110011 : begin //MUL
                ALUOP <= MUL_ALU;
                PCtoRegSrc <= 1'b0; //dc
                ALUSrc <= 1'b1; //reg
                RDSrc <= 1'b0; //ALU
                MemtoReg <= 1'b0;
                MemWrite <= 1'b0;
                MemRead <= 1'b0;
                RegWrite <= 1'b1;
                Branch <= NoBranch;
                Imm_Type <= I_Type;//dc
                CsrtoAlu <= 1'b0;
            end */

            `OPCODE_BITS'b0000011 : begin //LW
                ALUOP = ADD_ALU;
                PCtoRegSrc = 1'b0; //dc
                ALUSrc = 1'b0; //imm
                RDSrc = 1'b0; //dc
                MemtoReg = 1'b1;
                MemWrite = 1'b0;
                MemRead = 1'b1;
                RegWrite = 1'b1;
                Branch = NoBranch;
                Imm_Type = I_Type; //I_Type imm
                CsrtoAlu = 1'b0;
            end

            `OPCODE_BITS'b0010011 : begin //I_type
                ALUOP = I_ALU;
                PCtoRegSrc = 1'b0; //dc
                ALUSrc = 1'b0; //imm
                RDSrc = 1'b0; //ALU
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                RegWrite = 1'b1;
                Branch = NoBranch;
                Imm_Type = I_Type; //I_Type imm
                CsrtoAlu = 1'b0;
            end

            `OPCODE_BITS'b1100111 : begin //JALR
                ALUOP = JALR_ALU;
                PCtoRegSrc = 1'b0; //pc+4
                ALUSrc = 1'b0; //imm
                RDSrc = 1'b1; //pc
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                RegWrite = 1'b1;
                Branch = JalrBranch;
                Imm_Type = I_Type; //I_Type imm
                CsrtoAlu = 1'b0;
            end

            `OPCODE_BITS'b0100011 : begin //SW
                ALUOP = ADD_ALU;
                PCtoRegSrc = 1'b0; //dc
                ALUSrc = 1'b0; //imm
                RDSrc = 1'b0; //dc
                MemtoReg = 1'b0;
                MemWrite = 1'b1;
                MemRead = 1'b0;
                RegWrite = 1'b0;
                Branch = NoBranch;
                Imm_Type = S_Type; //S_Type imm
                CsrtoAlu = 1'b0;
            end

            `OPCODE_BITS'b1100011 : begin //BBranch
                ALUOP = B_ALU;
                PCtoRegSrc = 1'b0; //dc
                ALUSrc = 1'b1; //reg
                RDSrc = 1'b0; //dc
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                RegWrite = 1'b0;
                Branch = BBranch;
                Imm_Type = B_Type; //B_Type imm
                CsrtoAlu = 1'b0;
            end

            `OPCODE_BITS'b0010111 : begin //AUIPC
                ALUOP = ADD_ALU; //dc
                PCtoRegSrc = 1'b1; //pc+imm
                ALUSrc = 1'b0; //dc
                RDSrc = 1'b1; //pc
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                RegWrite = 1'b1;
                Branch = NoBranch;
                Imm_Type = U_Type; //U_Type imm
                CsrtoAlu = 1'b0;
            end

            `OPCODE_BITS'b0110111 : begin //LUI
                ALUOP = LUI_ALU; 
                PCtoRegSrc = 1'b0; //dc
                ALUSrc = 1'b0; //imm
                RDSrc = 1'b0; //ALU
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                RegWrite = 1'b1;
                Branch = NoBranch;
                Imm_Type = U_Type; //U_Type imm
                CsrtoAlu = 1'b0;
            end

            `OPCODE_BITS'b1101111 : begin //JAL
                ALUOP = ADD_ALU; //dc
                PCtoRegSrc = 1'b0; //pc+4
                ALUSrc = 1'b0; //dc
                RDSrc = 1'b1; //pc
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                RegWrite = 1'b1;
                Branch = JBranch;
                Imm_Type = J_Type; //J_Type imm
                CsrtoAlu = 1'b0;
            end

            `OPCODE_BITS'b1110011 : begin //CSR
                ALUOP = ADD_ALU; //dc
                PCtoRegSrc = 1'b0; //dc
                ALUSrc = 1'b0; //dc
                RDSrc = 1'b0; //alu_out
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                RegWrite = 1'b1;
                Branch = NoBranch;
                Imm_Type = CSR_Type; //J_Type imm
                CsrtoAlu = 1'b1;
            end

            default: begin //JAL
                ALUOP = ADD_ALU; //dc
                PCtoRegSrc = 1'b0; //pc+4
                ALUSrc = 1'b0; //dc
                RDSrc = 1'b0; //pc
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                RegWrite = 1'b0;
                Branch = NoBranch;
                Imm_Type = I_Type; //J_Type imm
                CsrtoAlu = 1'b0;
            end
        endcase
    end
    
endmodule