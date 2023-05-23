module FIFO #(
    parameter DATA_WIDTH='d8 , ADDR_WIDTH='d5,ADDR_WIDTH_PLUS_OVERFLOW='d6  ,DEPTH='d32, //ADDR_WIDTH=$clog2(DEPTH) 
    NUM_STAGES='d2 
) (
    input  wire                   i_RST      ,
    //Write Side Signals
    input  wire                   i_clk_write,
    input  wire [DATA_WIDTH-1:0]  i_wr_data  ,
    input  wire                   i_wr_en    ,
    output wire                   o_Full_Flag,
    //Read Side Signals
    input  wire                   i_clk_read ,
    input  wire                   i_rd_en    ,
    output wire [DATA_WIDTH-1:0]  o_rd_data  ,
    output wire                   o_Empty_Flag    

);
wire [ADDR_WIDTH:0]  wr_addr_top;
wire [ADDR_WIDTH:0]  Gray_wr_addr_top;
wire [ADDR_WIDTH:0]  Syn_Gray_wr_addr_top;

wire [ADDR_WIDTH:0]  rd_addr_top;
wire [ADDR_WIDTH:0]  Gray_rd_addr_top;
wire [ADDR_WIDTH:0]  Syn_Gray_rd_addr_top;

wire Write_Enable_top = i_wr_en & (~o_Full_Flag); 
wire Read_Enable_top= i_rd_en & (~o_Empty_Flag) ;

RAM #(
    .DATA_WIDTH (DATA_WIDTH ),
    .ADDR_WIDTH (ADDR_WIDTH ),
    .DEPTH      (DEPTH      )
)
u_RAM(
    .clk_write (i_clk_write ),
    .RST       (i_RST       ),
    .i_wr_addr (wr_addr_top[ADDR_WIDTH-1:0] ),
    .i_wr_data (i_wr_data ),
    .i_wr_en   (Write_Enable_top   ),
    .i_rd_addr (rd_addr_top[ADDR_WIDTH-1:0] ),
    .i_rd_en   (Read_Enable_top       ),
    .o_rd_data (o_rd_data )
);

Address_Gen_Logic #(
    .ADDR_WIDTH (ADDR_WIDTH )
)
u_Write_Address_Gen_Logic(
    .clk       (i_clk_write       ),
    .RST       (i_RST       ),
    .i_Enable  (Write_Enable_top  ),
    .o_Address (wr_addr_top )
);

B2G #(
    .ADDR_WIDTH (ADDR_WIDTH )
)
u_Write_B2G(
    .i_Binary_Ptr (wr_addr_top ),
    .o_Gray_Ptr   (Gray_wr_addr_top) //!
);


Address_Gen_Logic #(
    .ADDR_WIDTH (ADDR_WIDTH )
)
u_Read_Address_Gen_Logic(
    .clk       (i_clk_read       ),
    .RST       (i_RST       ),
    .i_Enable  (Read_Enable_top  ),
    .o_Address (rd_addr_top )
);

B2G #(
    .ADDR_WIDTH (ADDR_WIDTH )
)
u_Read_B2G(
    .i_Binary_Ptr (rd_addr_top ),
    .o_Gray_Ptr   (Gray_rd_addr_top   )
);

Multi_Flop_Synchronizer_Multi_bits #(
    .NUM_STAGES (NUM_STAGES ),
    .BUS_WIDTH  (ADDR_WIDTH_PLUS_OVERFLOW  )
)
u_Write_Multi_Flop_Synchronizer_Multi_bits(
    .ASYNC (Gray_wr_addr_top ),
    .CLK   (i_clk_read   ),
    .RST   (i_RST   ),
    .SYNC  (Syn_Gray_wr_addr_top  )
);

Multi_Flop_Synchronizer_Multi_bits #(
    .NUM_STAGES (NUM_STAGES ),
    .BUS_WIDTH  (ADDR_WIDTH_PLUS_OVERFLOW  )
)
u_Multi_Flop_Synchronizer_Multi_bits(
    .ASYNC (Gray_rd_addr_top ),
    .CLK   (i_clk_write   ),
    .RST   (i_RST   ),
    .SYNC  (Syn_Gray_rd_addr_top  )
);

Full_Flag_Gen #(
    .ADDR_WIDTH (ADDR_WIDTH )
)
u_Full_Flag_Gen(
    .i_wr_address (Gray_wr_addr_top ),
    .i_rd_address (Syn_Gray_rd_addr_top ),
    .o_Full_Flag  (o_Full_Flag  )
);

Empty_Flag_Gen #(
    .ADDR_WIDTH (ADDR_WIDTH )
)
u_Empty_Flag_Gen(
    .i_wr_address (Syn_Gray_wr_addr_top ),
    .i_rd_address (Gray_rd_addr_top ),
    .o_Empty_Flag (o_Empty_Flag )
);


    
endmodule