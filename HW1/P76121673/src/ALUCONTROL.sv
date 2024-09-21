// `include "./DEF.sv"

module ALUCONTROL (
    input [`ALU_TYPE_BITS - 1:0] IDEXE_ALUOP,
    input [`FUNCT3_BITS - 1:0] IDEXE_funct3,
    input [`FUNCT7_BITS - 1:0] IDEXE_funct7,
    output reg [`ALU_CTRL_BITS - 1:0] ALU_Ctrl
);
    localparam [`ALU_TYPE_BITS - 1:0] R_ALU = `ALU_TYPE_BITS'b000, //reg+reg
                                        I_ALU = `ALU_TYPE_BITS'b001, //reg+imm
                                        ADD_ALU = `ALU_TYPE_BITS'b010, //reg+reg lw
                                        JALR_ALU = `ALU_TYPE_BITS'b011, //reg+pc
                                        B_ALU = `ALU_TYPE_BITS'b100, // reg+reg b
                                        LUI_ALU = `ALU_TYPE_BITS'b101;
    
    localparam [`ALU_CTRL_BITS - 1:0]   Ctrl_Add = `ALU_CTRL_BITS'b00000,//0
                                        Ctrl_Sub = `ALU_CTRL_BITS'b00001,//1
                                        Ctrl_Sll = `ALU_CTRL_BITS'b00010,//2
				                Ctrl_Slt = `ALU_CTRL_BITS'b00011,//3
				                Ctrl_Sltu = `ALU_CTRL_BITS'b00100,//4
				                Ctrl_Xor = `ALU_CTRL_BITS'b00101,//5
				                Ctrl_Srl = `ALU_CTRL_BITS'b00110,//6
				                Ctrl_Sra = `ALU_CTRL_BITS'b00111,//7
				                Ctrl_Or = `ALU_CTRL_BITS'b01000,//8
				                Ctrl_And = `ALU_CTRL_BITS'b01001,//9
				                Ctrl_Jalr = `ALU_CTRL_BITS'b01010,//10
				                Ctrl_Beq = `ALU_CTRL_BITS'b01011,//11
				                Ctrl_Bne = `ALU_CTRL_BITS'b01100,//12
				                Ctrl_Blt = `ALU_CTRL_BITS'b01101,//13
				                Ctrl_Bge = `ALU_CTRL_BITS'b01110,//14
				                Ctrl_Bltu = `ALU_CTRL_BITS'b01111,//15
				                Ctrl_Bgeu = `ALU_CTRL_BITS'b10000,//16
				                Ctrl_Imm = `ALU_CTRL_BITS'b10001,//17
				                Ctrl_Mul = `ALU_CTRL_BITS'b10010,//18
				                Ctrl_Mulh = `ALU_CTRL_BITS'b10011,//19
				                Ctrl_Mulhsu = `ALU_CTRL_BITS'b10100,//20
				                Ctrl_Mulhu = `ALU_CTRL_BITS'b10101;//21


    always_comb begin
        case (IDEXE_ALUOP)
            R_ALU : begin
                case (IDEXE_funct3)
                    `FUNCT3_BITS'b000 : begin
                        if(IDEXE_funct7 == `FUNCT7_BITS'b0000000) ALU_Ctrl = Ctrl_Add;
                        else if(IDEXE_funct7 == `FUNCT7_BITS'b0000001) ALU_Ctrl = Ctrl_Mul;
                        else ALU_Ctrl = Ctrl_Sub;
                    end 
                    `FUNCT3_BITS'b001 : begin
                        if(IDEXE_funct7 == `FUNCT7_BITS'b0000000) ALU_Ctrl = Ctrl_Sll;
                        else ALU_Ctrl = Ctrl_Mulh;
                    end
                    `FUNCT3_BITS'b010 : begin
                        if(IDEXE_funct7 == `FUNCT7_BITS'b0000000) ALU_Ctrl = Ctrl_Slt;
                        else ALU_Ctrl = Ctrl_Mulhsu;
                    end
                    `FUNCT3_BITS'b011 : begin
                        if(IDEXE_funct7 == `FUNCT7_BITS'b0000000) ALU_Ctrl = Ctrl_Sltu;
                        else ALU_Ctrl = Ctrl_Mulhu;
                    end
                    `FUNCT3_BITS'b100 : ALU_Ctrl = Ctrl_Xor;
                    `FUNCT3_BITS'b101 : begin
                        if(IDEXE_funct7 == `FUNCT7_BITS'b0000000) ALU_Ctrl = Ctrl_Srl;
                        else ALU_Ctrl = Ctrl_Sra;
                    end 
                    `FUNCT3_BITS'b110 : ALU_Ctrl = Ctrl_Or;
                    default: ALU_Ctrl = Ctrl_And;
                endcase
            end 

            /*MUL_ALU : begin
                case (IDEXE_funct3)
                    `FUNCT3_BITS'b000 : ALU_Ctrl <= Mul;
                    `FUNCT3_BITS'b001 : ALU_Ctrl <= Mulh;
                    `FUNCT3_BITS'b010 : ALU_Ctrl <= Mulhsu;
                    default: ALU_Ctrl <= Mulhu;
                endcase
            end*/

            I_ALU : begin
                case (IDEXE_funct3)
                    `FUNCT3_BITS'b000 : ALU_Ctrl = Ctrl_Add;
                    `FUNCT3_BITS'b001 : ALU_Ctrl = Ctrl_Sll;
                    `FUNCT3_BITS'b010 : ALU_Ctrl = Ctrl_Slt;
                    `FUNCT3_BITS'b011 : ALU_Ctrl = Ctrl_Sltu;
                    `FUNCT3_BITS'b100 : ALU_Ctrl = Ctrl_Xor;
                    `FUNCT3_BITS'b101 : begin
                        if(IDEXE_funct7 == `FUNCT7_BITS'd0) ALU_Ctrl = Ctrl_Srl;
                        else ALU_Ctrl = Ctrl_Sra;
                    end
                    `FUNCT3_BITS'b110 : ALU_Ctrl = Ctrl_Or;
                    default: ALU_Ctrl = Ctrl_And;
                endcase
            end

            ADD_ALU : ALU_Ctrl = Ctrl_Add;

            JALR_ALU : ALU_Ctrl = Ctrl_Add;

            B_ALU : begin
                case (IDEXE_funct3)
                    `FUNCT3_BITS'b000 : ALU_Ctrl = Ctrl_Beq;
                    `FUNCT3_BITS'b001 : ALU_Ctrl = Ctrl_Bne;
                    `FUNCT3_BITS'b100 : ALU_Ctrl = Ctrl_Blt;
                    `FUNCT3_BITS'b101 : ALU_Ctrl = Ctrl_Bge;
                    `FUNCT3_BITS'b110 : ALU_Ctrl = Ctrl_Bltu;
                    default : ALU_Ctrl = Ctrl_Bgeu;
                endcase
            end

            default : ALU_Ctrl = Ctrl_Imm;
        endcase
    end
    
endmodule
