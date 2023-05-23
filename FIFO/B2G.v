module B2G #(
    parameter ADDR_WIDTH='d5 
) (
    input  wire [ADDR_WIDTH:0] i_Binary_Ptr,
    output reg  [ADDR_WIDTH:0] o_Gray_Ptr
);

always @(*) begin
    o_Gray_Ptr={i_Binary_Ptr[ADDR_WIDTH] ,i_Binary_Ptr[ADDR_WIDTH-1:0] ^ (i_Binary_Ptr[ADDR_WIDTH-1:0]>>1'b1)};
end
    
endmodule