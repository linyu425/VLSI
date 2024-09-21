// `include "./DEF.sv"

module COUNTER (
    input clk,
    input rst,
    input [`INSTR_COUNT_TYPES - 1:0] stall_type, 
    output reg [`COUNTER_BITS - 1:0] instret_out,
    output reg [`COUNTER_BITS - 1:0] cycle_out
);
    localparam B_stall = `INSTR_COUNT_TYPES'b00,
                LU_stall = `INSTR_COUNT_TYPES'b01,
                no_stall = `INSTR_COUNT_TYPES'b10;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            instret_out <= `COUNTER_BITS'd0;
            cycle_out <= `COUNTER_BITS'd0;
        end
        else begin
            cycle_out <= cycle_out + `COUNTER_BITS'd1;
            if(cycle_out > `COUNTER_BITS'd1) begin
                case (stall_type)
                    B_stall : instret_out <= instret_out - `COUNTER_BITS'd1;
                    LU_stall : instret_out <= instret_out;
                    default: instret_out <=  instret_out + `COUNTER_BITS'd1;
                endcase
            end
        end
    end

endmodule