// `include "./DEF.sv"

module PC_MUX(
    input clk,
    input rst,
    input pc_write,
    input [`ADDR_BITS - 1:0] pc_in,

    output reg [`ADDR_BITS - 1:0] pc_out
); 

always_ff @( posedge clk or posedge rst ) begin : PC
    if(rst) pc_out <= `ADDR_BITS'd0;
    else begin
        if(pc_write) pc_out <= pc_in;
    end
end

endmodule