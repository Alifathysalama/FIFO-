module RAM #(
    parameter DATA_WIDTH='d8 , ADDR_WIDTH='d5  ,DEPTH='d32 //ADDR_WIDTH=$clog2(DEPTH)
) (
    input  wire                  clk_write,
    //input  wire                  clk_read ,
    input  wire                  RST      ,

    input  wire [ADDR_WIDTH-1:0] i_wr_addr,
    input  wire [DATA_WIDTH-1:0] i_wr_data,
    input  wire                  i_wr_en  ,
 
    input  wire [ADDR_WIDTH-1:0] i_rd_addr,
    input  wire                  i_rd_en  ,
    output reg [DATA_WIDTH-1:0] o_rd_data


);

reg [DATA_WIDTH-1:0] FIFO_Fabric [0:DEPTH-1];
integer RST_Index;

always @(posedge clk_write or negedge RST ) begin
    if (!RST) begin
        for (RST_Index =0 ;RST_Index < DEPTH ;RST_Index=RST_Index+1'b1 ) begin
            FIFO_Fabric[RST_Index]<='b0;
        end
    end else if(i_wr_en) begin
        FIFO_Fabric[i_wr_addr]<=i_wr_data;
    end
    
end
always @(*) begin
    if (i_rd_en) begin
        o_rd_data=FIFO_Fabric[i_rd_addr];
    end else begin
        o_rd_data='b0;
    end
end
 

endmodule