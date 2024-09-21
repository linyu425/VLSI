// `include "./DEF.sv"

module ALU (
    input [`DATA_BITS - 1:0] rs1_data,
    input [`DATA_BITS - 1:0] rs2_data,
    input [`ALU_CTRL_BITS - 1:0] ALU_Ctrl,
    output reg [`DATA_BITS - 1:0] ALU_out,
    output reg Zeroflag
);
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

    wire [`DATA_BITS - 1:0] sum;
    logic [`MUL_BITS - 1:0] mul,mulh,mulhsu;

    assign sum = rs1_data + rs2_data;
    assign mul = rs1_data * rs2_data;
    assign mulh = $signed(rs1_data) * $signed(rs2_data);
    assign mulhsu = $signed(rs1_data) * $signed({1'b0,rs2_data});

    always_comb begin
        case (ALU_Ctrl)
            Ctrl_Add : ALU_out = sum;
            Ctrl_Sub : ALU_out = rs1_data - rs2_data;
            Ctrl_Sll : ALU_out = rs1_data << rs2_data[4:0];
            Ctrl_Slt : ALU_out = ($signed(rs1_data) < $signed(rs2_data)) ? `DATA_BITS'd1 : `DATA_BITS'd0;
            Ctrl_Sltu : ALU_out = (rs1_data < rs2_data) ? `DATA_BITS'd1 : `DATA_BITS'd0;
            Ctrl_Xor : ALU_out = rs1_data ^ rs2_data;
            Ctrl_Srl : ALU_out = rs1_data >> rs2_data[4:0];
            Ctrl_Sra : ALU_out = $signed(rs1_data) >>> rs2_data[4:0];
            Ctrl_Or : ALU_out = rs1_data | rs2_data;
            Ctrl_And : ALU_out = rs1_data & rs2_data;
            Ctrl_Jalr : ALU_out = {sum[31:1] , 1'b0};
            Ctrl_Imm : ALU_out = rs2_data;
            Ctrl_Mul : begin 
                ALU_out = mul[31:0];
            end
            Ctrl_Mulh : begin 
                ALU_out = mulh[63:32];
            end
            Ctrl_Mulhsu : begin 
                ALU_out = mulhsu[63:32];
            end
            Ctrl_Mulhu : begin 
                ALU_out = mul[63:32];
            end
            default: ALU_out = `DATA_BITS'd0;
        endcase

        case (ALU_Ctrl)
            Ctrl_Beq : Zeroflag = (rs1_data == rs2_data) ? 1'b1 : 1'b0;
            Ctrl_Bne : Zeroflag = (rs1_data != rs2_data) ? 1'b1 : 1'b0;
            Ctrl_Blt : Zeroflag = ($signed(rs1_data) < $signed(rs2_data)) ? 1'b1 : 1'b0;
            Ctrl_Bge : Zeroflag = ($signed(rs1_data) >= $signed(rs2_data)) ? 1'b1 : 1'b0;
            Ctrl_Bltu : Zeroflag = (rs1_data < rs2_data) ? 1'b1 : 1'b0;
            Ctrl_Bgeu : Zeroflag = (rs1_data >= rs2_data) ? 1'b1 : 1'b0;
            default: Zeroflag = 1'b0;
        endcase
    end

endmodule
