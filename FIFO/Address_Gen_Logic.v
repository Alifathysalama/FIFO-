module Address_Gen_Logic #(
    parameter  ADDR_WIDTH='d5 
) (
    input  wire                   clk,
    input  wire                   RST,
    input  wire                   i_Enable,
    output reg  [ADDR_WIDTH:0]    o_Address
);

always @(posedge clk or negedge RST) begin
    if (!RST) begin
        o_Address<='b0;
    end else if(i_Enable) begin
        o_Address<=o_Address+1'b1;
    end
end
    
endmodule