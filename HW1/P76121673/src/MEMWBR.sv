// `include "./DEF.sv"

module MEMWBR (
    input clk,
    input rst,
    input EXEMEM_RDSrc,
    input EXEMEM_MemtoReg,
    input EXEMEM_MemWrite,
    input EXEMEM_MemRead,
    input EXEMEM_RegWrite,
    input [`ADDR_BITS - 1:0] EXEMEM_pc_to_reg,
    input [`DATA_BITS - 1:0] EXEMEM_ALU_out,
    input [`DATA_BITS - 1:0] EXEMEM_rs2_data,
    input [`REG_ADDR - 1:0] EXEMEM_rd_addr,
    input [`FUNCT3_BITS - 1:0] EXEMEM_funct3,
    input [`DATA_BITS - 1:0] DM_Dout,

    output reg MEMWB_MemtoReg,
    output reg MEMWB_RegWrite,
    output reg [`DATA_BITS - 1:0] MEMWB_rd_data, 
    output reg [`DATA_BITS - 1:0] MEMWB_Dout,
    output reg [`REG_ADDR - 1:0] MEMWB_rd_addr,
    output reg [`DATA_BITS - 1:0] Din,
    output reg [3:0] wire_writeEnable,
    output chipSelect,
    output [`DATA_BITS - 1:0] wire_MEM_rd_data

);

    assign wire_MEM_rd_data = (EXEMEM_RDSrc) ? EXEMEM_pc_to_reg : EXEMEM_ALU_out;
    assign chipSelect = EXEMEM_MemRead | EXEMEM_MemWrite;

    always_comb begin //S_Data
        Din = `DATA_BITS'd0;
        case (EXEMEM_funct3)
            3'b000: // B
                Din[{EXEMEM_ALU_out[1:0], 3'b0}+:8] = EXEMEM_rs2_data[7:0];
            3'b001: // H
                Din[{EXEMEM_ALU_out[1], 4'b0}+:16] = EXEMEM_rs2_data[15:0];
            default : // W
                Din = EXEMEM_rs2_data;
        endcase
    end

    always_comb begin //???
        if(EXEMEM_MemWrite) begin
            wire_writeEnable = 4'd0;
            case (EXEMEM_funct3)
                3'b000: // B
                    wire_writeEnable[EXEMEM_ALU_out[1:0]] = 1'b0;
                3'b001: // H
                    wire_writeEnable[{EXEMEM_ALU_out[1],1'b0}+:2] = 2'b00;
                default: // W
                    wire_writeEnable = 4'b0000;
            endcase
        end
        else wire_writeEnable = 4'b1111;
    end

    wire [`DATA_BITS - 1:0] wire_rd_data;
    
    assign wire_rd_data = (EXEMEM_RDSrc == 1'b1) ? EXEMEM_pc_to_reg : EXEMEM_ALU_out;

    always_ff @( posedge clk or posedge rst ) begin 
        if(rst)begin
            MEMWB_MemtoReg <= 1'b0;
            MEMWB_RegWrite <= 1'b0;
            MEMWB_rd_data <= `DATA_BITS'd0;
            MEMWB_rd_addr <= `REG_ADDR'd0;
            MEMWB_Dout <= `DATA_BITS'd0;
        end
        else begin
            MEMWB_MemtoReg <= EXEMEM_MemtoReg;
            MEMWB_RegWrite <= EXEMEM_RegWrite;
            MEMWB_rd_data <= wire_rd_data;
            MEMWB_rd_addr <= EXEMEM_rd_addr;

            case (EXEMEM_funct3)
                `FUNCT3_BITS'b000 : MEMWB_Dout <= {{24{DM_Dout[7]}} , DM_Dout[7:0]}; //B
                `FUNCT3_BITS'b001 : MEMWB_Dout <= {{16{DM_Dout[15]}} , DM_Dout[15:0]}; //H
                `FUNCT3_BITS'b010 : MEMWB_Dout <= DM_Dout; //W
                `FUNCT3_BITS'b100 : MEMWB_Dout <= {24'd0 , DM_Dout[7:0]}; //BU
                default : MEMWB_Dout <= {16'd0 , DM_Dout[15:0]}; //BU   
            endcase
        end
    end
    
endmodule