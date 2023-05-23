module Full_Flag_Gen #(
    parameter ADDR_WIDTH='d5 
) (
    input  wire [ADDR_WIDTH:0] i_wr_address,
    input  wire [ADDR_WIDTH:0] i_rd_address,

    output reg                 o_Full_Flag
);

wire OverFlow=(i_wr_address[ADDR_WIDTH]^i_rd_address[ADDR_WIDTH]);
wire Same_Location=(i_wr_address[ADDR_WIDTH-1:0] == i_rd_address[ADDR_WIDTH-1:0]);

always @(*) begin
    //Defual Values
    o_Full_Flag='b0;
    if ((OverFlow) && (Same_Location)) begin
        o_Full_Flag='b1;
    end else begin
        o_Full_Flag='b0;

    end
end
    
endmodule