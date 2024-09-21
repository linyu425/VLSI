`include "CPU.sv"
`include "Master.sv"
`include "AXI_define.svh"
`include "L1C_data.sv"
`include "L1C_inst.sv"

`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"
module CPU_wrapper(
    input clk,
    input rst,
    //MASTER 0:
    //WA master0
    output logic [`AXI_ID_BITS-1:0] AWID_master0,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_master0,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_master0,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_master0,
    output logic [1:0] AWBURST_master0,
    output logic AWVALID_master0,
    input AWREADY_master0,

    //WD master0
    output logic [`AXI_DATA_BITS-1:0] WDATA_master0,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_master0,
    output logic WLAST_master0,
    output logic WVALID_master0,
    input WREADY_master0,

    //WR master0
    input [`AXI_ID_BITS-1:0] BID_master0,
    input [1:0] BRESP_master0,
    input BVALID_master0,
    output logic BREADY_master0,

    //RA master0
    output logic [`AXI_ID_BITS-1:0] ARID_master0,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_master0,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_master0,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_master0,
    output logic [1:0] ARBURST_master0,
    output logic ARVALID_master0,
    input ARREADY_master0,
    //RD master0
    input [`AXI_ID_BITS-1:0] RID_master0,
    input [`AXI_DATA_BITS-1:0] RDATA_master0,
    input [1:0] RRESP_master0,
    input RLAST_master0,
    input RVALID_master0,
    output logic RREADY_master0,

    //MASTER 1:
    //WA master1
    output logic [`AXI_ID_BITS-1:0] AWID_master1,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_master1,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_master1,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_master1,
    output logic [1:0] AWBURST_master1,
    output logic AWVALID_master1,
    input AWREADY_master1,

    //WD master1
    output logic [`AXI_DATA_BITS-1:0] WDATA_master1,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_master1,
    output logic WLAST_master1,
    output logic WVALID_master1,
    input WREADY_master1,

    //WR master1
    input [`AXI_ID_BITS-1:0] BID_master1,
    input [1:0] BRESP_master1,
    input BVALID_master1,
    output logic BREADY_master1,

    //RA master1
    output logic [`AXI_ID_BITS-1:0] ARID_master1,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_master1,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_master1,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_master1,
    output logic [1:0] ARBURST_master1,
    output logic ARVALID_master1,
    input ARREADY_master1,
    //RD master1
    input [`AXI_ID_BITS-1:0] RID_master1,
    input [`AXI_DATA_BITS-1:0] RDATA_master1,
    input [1:0] RRESP_master1,
    input RLAST_master1,
    input RVALID_master1,
    output logic RREADY_master1,


    //hw3
    input interrupt,
    input timeout
);

logic [`AXI_ADDR_BITS-1:0] instr_addr;
logic [`AXI_DATA_BITS-1:0] IM_instr;
logic DM_read;
logic DM_write;
logic [3:0] WEB;
logic [`AXI_ADDR_BITS-1:0] DM_addr;
logic [`AXI_DATA_BITS-1:0] store_data;
logic [`AXI_DATA_BITS-1:0] load_data;

logic IM_stall, DM_stall, lock_DM;

//cache
logic [`DATA_BITS-1:0] I_out;
logic I_wait;
logic I_req;
logic [`DATA_BITS-1:0] I_addr;
logic I_write;
logic [`DATA_BITS-1:0] I_in;
logic [`CACHE_TYPE_BITS-1:0] I_type;
logic [3:0] I_blk_size;

logic [`DATA_BITS-1:0] D_out;
logic D_wait;
logic D_req;
logic [`DATA_BITS-1:0] D_addr;
logic D_write;
logic [`DATA_BITS-1:0] D_in;
logic [`CACHE_TYPE_BITS-1:0] D_type;
logic [3:0] D_blk_size;
logic [`CACHE_TYPE_BITS-1:0] core_type;
logic cacheable;

always_ff @(posedge clk ) begin
    if(rst) begin
        lock_DM <= 1'b0;
    end else begin
        lock_DM <= (~IM_stall)? 1'b0:((IM_stall & ~DM_stall)? 1'b1: lock_DM);
    end
end

CPU CPU(
    .clk(clk),
    .rst(rst),

    //IM
    .instr_addr(instr_addr),  //output
    .IM_instr(IM_instr),    //input
    //DM
    .DM_read(DM_read),
    .DM_write(DM_write),
    .WEB(WEB),
    .DM_addr(DM_addr),
    .store_data(store_data),
    .load_data(load_data),
    .core_type(core_type),

    //stall
    .IM_stall(IM_stall),
    .DM_stall(DM_stall),

    .interrupt(interrupt),
    .timeout(timeout)
);

L1C_data L1C_data(
    .clk(clk),
    .rst(rst),
    // Core to CPU wrapper
    .core_addr(DM_addr),
    .core_req((DM_read | DM_write) & ~lock_DM),
    .core_write(DM_write),
    .core_in(store_data),
    .core_type(core_type),
    // Mem to CPU wrapper
    .D_out(D_out),
    .D_wait(D_wait), //master m_wait: READ state-> 1, write response -> 1, otherwise -> 0;
    // CPU wrapper to core
    .core_out(load_data),
    .core_wait(DM_stall),
    // CPU wrapper to Mem
    .D_req(D_req),
    .D_addr(D_addr),
    .D_write(D_write),
    .D_in(D_in),
    .D_type(D_type),
     
	  .cacheable(cacheable)
);

L1C_inst L1C_inst(
    .clk(clk),
    .rst(rst),
    // Core to CPU wrapper
    .core_addr(instr_addr),
    .core_req(1'b1),
    .core_write(1'b0),
    .core_in(`DATA_BITS'b0),
    .core_type(`CACHE_WORD),
    // Mem to CPU wrapper
    .I_out(I_out),
    .I_wait(I_wait), //master m_wait: READ state-> 1, write response -> 1, otherwise -> 0;
    // CPU wrapper to core
    .core_out(IM_instr),
    .core_wait(IM_stall),
    // CPU wrapper to Mem
    .I_req(I_req),
    .I_addr(I_addr),
    .I_write(I_write),
    .I_in(I_in),
    .I_type(I_type)
);

Master Master0(
    .clk(clk),    // Clock
    .rst(rst),  // Asynchronous reset active high
    // from CPU
    .read(I_req & ~I_write),
    .write(1'b0),
    .write_type(3'b000),//naughty
    .data_in(I_in),
    .addr_in(I_addr),
    //to CPU
    .data_out(I_out),
    .stall(I_wait), // to be fixed

    // AXI
    //WRITE ADDRESS
    .AWID(AWID_master0),
    .AWADDR(AWADDR_master0),
    .AWLEN(AWLEN_master0),
    .AWSIZE(AWSIZE_master0),
    .AWBURST(AWBURST_master0),
    .AWVALID(AWVALID_master0),
    .AWREADY(AWREADY_master0),
    //WRITE DATA
    .WDATA(WDATA_master0),
    .WSTRB(WSTRB_master0),
    .WLAST(WLAST_master0),
    .WVALID(WVALID_master0),
    .WREADY(WREADY_master0),
    //WRITE RESPONSE
    .BID(BID_master0),
    .BRESP(BRESP_master0),
    .BVALID(BVALID_master0),
    .BREADY(BREADY_master0),

    //READ ADDRESS
    .ARID(ARID_master0),
    .ARADDR(ARADDR_master0),
    .ARLEN(ARLEN_master0),
    .ARSIZE(ARSIZE_master0),
    .ARBURST(ARBURST_master0),
    .ARVALID(ARVALID_master0),
    .ARREADY(ARREADY_master0),
    //READ DATA
    .RID(RID_master0),
    .RDATA(RDATA_master0),
    .RRESP(RRESP_master0),
    .RLAST(RLAST_master0),
    .RVALID(RVALID_master0),
    .RREADY(RREADY_master0),
  
      .cacheable(1'b1)
);
Master Master1(
    .clk(clk),    // Clock
    .rst(rst),  // Asynchronous reset active high
    // from CPU
    .read(D_req & ~D_write),
    .write(D_req & D_write),
    .write_type(D_type),
    .data_in(D_in),
    .addr_in(D_addr),
    //to CPU
    .data_out(D_out),
    .stall(D_wait), // to be fixed

    // AXI
    //WRITE ADDRESS
    .AWID(AWID_master1),
    .AWADDR(AWADDR_master1),
    .AWLEN(AWLEN_master1),
    .AWSIZE(AWSIZE_master1),
    .AWBURST(AWBURST_master1),
    .AWVALID(AWVALID_master1),
    .AWREADY(AWREADY_master1),
    //WRITE DATA
    .WDATA(WDATA_master1),
    .WSTRB(WSTRB_master1),
    .WLAST(WLAST_master1),
    .WVALID(WVALID_master1),
    .WREADY(WREADY_master1),
    //WRITE RESPONSE
    .BID(BID_master1),
    .BRESP(BRESP_master1),
    .BVALID(BVALID_master1),
    .BREADY(BREADY_master1),

    //READ ADDRESS
    .ARID(ARID_master1),
    .ARADDR(ARADDR_master1),
    .ARLEN(ARLEN_master1),
    .ARSIZE(ARSIZE_master1),
    .ARBURST(ARBURST_master1),
    .ARVALID(ARVALID_master1),
    .ARREADY(ARREADY_master1),
    //READ DATA
    .RID(RID_master1),
    .RDATA(RDATA_master1),
    .RRESP(RRESP_master1),
    .RLAST(RLAST_master1),
    .RVALID(RVALID_master1),
    .RREADY(RREADY_master1),

	.cacheable(cacheable)
);



endmodule
