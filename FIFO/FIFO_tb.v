`timescale 1ns/1ns
module FIFO_tb #(
    parameter DATA_WIDTH='d8 , ADDR_WIDTH='d5,ADDR_WIDTH_PLUS_OVERFLOW='d6  ,DEPTH='d32, //ADDR_WIDTH=$clog2(DEPTH) 
    NUM_STAGES='d2
) ();

 // Internal Signals For testing
 integer i;
parameter NUM_OF_TEST ='d5 ;
parameter SIZE_FOR_NUM_OF_TEST =$clog2(NUM_OF_TEST);
reg [SIZE_FOR_NUM_OF_TEST-1:0] Empty_Flag_Error,Full_Flag_Error,Data_Error_tb;
reg [SIZE_FOR_NUM_OF_TEST-1:0] Test_Case_tb;

    reg                     i_RST_tb      ;
    //Write Side Signals
    reg                     i_clk_write_tb;
    reg   [DATA_WIDTH-1:0]  i_wr_data_tb  ;
    reg                     i_wr_en_tb    ;
    wire                    o_Full_Flag_tb;
    //Read Side Signals
    reg                     i_clk_read_tb ;
    reg                     i_rd_en_tb    ;
    wire  [DATA_WIDTH-1:0]  o_rd_data_tb  ;
    wire                    o_Empty_Flag_tb   ;
    
    localparam WRITE_CLOCK_PERIOD ='d500 ; // -> 2MHz Write clock
    localparam READ_CLOCK_PERIOD ='d1000 ; // -> 1MHz Write clock

    always #(WRITE_CLOCK_PERIOD/2) i_clk_write_tb=~i_clk_write_tb;
    always #(READ_CLOCK_PERIOD/2)  i_clk_read_tb=~i_clk_read_tb;

    initial begin
        Empty_Flag_Error='d0;
        Full_Flag_Error='d0;
        Data_Error_tb='d0;
        Test_Case_tb='d0;
        $monitor("Number of Errors (Full Flag Error=%d ,Empty Flag Error=%d ,Data Error=%d) In Test case=%d \n",Full_Flag_Error,Empty_Flag_Error,Data_Error_tb,Test_Case_tb);
    end

    initial begin
        Signals_Initialization();
        reset();
        Test_1();//Write 2 byts then reading them
        Test_2(); //Trying to read from an empty FIFO
        Test_3(); //Write Circuly Until its Full 
        Test_4(); //Read Until it's Empty Again
        $stop;

    end

task Test_1(); //Write 2 byts then reading them
 begin
    $display("Test Case # 1 :Write 2 byts then reading them");
    Test_Case_tb='d1;
    Cheack_Full_Flag('b1);
    Cheack_Empty_Flag('b0);
    /*
    if((o_Full_Flag_tb!='b0) || (o_Empty_Flag_tb==1'b0)) begin
        Flag_Error_tb='b1;
        Test_Case_tb='d1;
    end */
    i_wr_en_tb='b1;
    i_wr_data_tb='d1;
    #WRITE_CLOCK_PERIOD;

    i_wr_data_tb='d2;
    #WRITE_CLOCK_PERIOD;
    i_wr_en_tb='b0;
    repeat(2)#WRITE_CLOCK_PERIOD;

    Cheack_Full_Flag('b1);
    Cheack_Empty_Flag('b1);

    
    i_rd_en_tb='b1;
    #(READ_CLOCK_PERIOD/2);
    if(o_rd_data_tb!='d1) begin
        Data_Error_tb=Data_Error_tb+'b1;
        Test_Case_tb='d1;
    end
    #(READ_CLOCK_PERIOD/2);
    
    
    #(READ_CLOCK_PERIOD/2);
    if(o_rd_data_tb!='d2) begin
        Data_Error_tb=Data_Error_tb+'b1;
        Test_Case_tb='d1;
    end
    #(READ_CLOCK_PERIOD/2);
    i_rd_en_tb='b0;
    #READ_CLOCK_PERIOD;
    Cheack_Full_Flag('b1);
    Cheack_Empty_Flag('b0);

 end
endtask

task Test_2(); //Trying to read from an empty FIFO
 begin
    $display("Test Case # 2 :Trying to read from an empty FIFO");
    Test_Case_tb='d2;
    Cheack_Empty_Flag('b0);
    i_rd_en_tb='b1;
    #READ_CLOCK_PERIOD;
    if(o_rd_data_tb!='d0) begin
        Data_Error_tb=Data_Error_tb+'b1;
    end
    #READ_CLOCK_PERIOD;
    if(o_rd_data_tb!='d0) begin
        Data_Error_tb=Data_Error_tb+'b1;
    end
    i_rd_en_tb='b0;


 end
endtask

task Test_3(); //Write Circuly Until its Full 
 begin
    $display("Test Case # 3 :Write Until it's Full ");
    Test_Case_tb='d3;
    Cheack_Full_Flag('b1);
    Cheack_Empty_Flag('b0);
   
    i_wr_en_tb='b1;
    for (i ='d1 ;i<=DEPTH ; i=i+'d1) begin
     i_wr_data_tb=i;
     #WRITE_CLOCK_PERIOD;
    end
    i_wr_en_tb='b0;
    repeat(2)#WRITE_CLOCK_PERIOD;

    Cheack_Full_Flag('b0);
    Cheack_Empty_Flag('b1);
 end
endtask
task Test_4(); //Read Until it's Empty Again
 begin
    $display("Test Case # 3 :Read Until it's Empty Again");
    Test_Case_tb='d4;
    Cheack_Full_Flag('b0);
    Cheack_Empty_Flag('b1);

    
    i_rd_en_tb='b1;
    for (i ='d1 ;i<=DEPTH ; i=i+'d1) begin
    #(READ_CLOCK_PERIOD/2);
    if(o_rd_data_tb!=i) begin
        Data_Error_tb=Data_Error_tb+'b1;
    end
    #(READ_CLOCK_PERIOD/2);
    end
    i_rd_en_tb='b0;
    #READ_CLOCK_PERIOD;
    Cheack_Full_Flag('b1);
    Cheack_Empty_Flag('b0);

 end
endtask


task Cheack_Full_Flag(input Flag_Condition);
 begin
    if (o_Full_Flag_tb==Flag_Condition) begin
        Full_Flag_Error=Full_Flag_Error+'d1;
        
    end
 end
endtask

task Cheack_Empty_Flag(input Flag_Condition );
 begin
    if (o_Empty_Flag_tb==Flag_Condition) begin
        Empty_Flag_Error=Empty_Flag_Error+'d1;
        
    end
 end
endtask




task Signals_Initialization();
begin
    i_clk_write_tb='b0;
    i_clk_read_tb='b0;
    i_wr_data_tb='b0;
    i_wr_en_tb='b0;
    i_rd_en_tb='b0;
end
endtask


task reset();
begin
    i_RST_tb='b1;
    #READ_CLOCK_PERIOD;
    i_RST_tb='b0;
    #READ_CLOCK_PERIOD;
    i_RST_tb='b1;
end
endtask

FIFO #(
    .DATA_WIDTH               (DATA_WIDTH               ),
    .ADDR_WIDTH               (ADDR_WIDTH               ),
    .ADDR_WIDTH_PLUS_OVERFLOW (ADDR_WIDTH_PLUS_OVERFLOW ),
    .DEPTH                    (DEPTH                    ),
    .NUM_STAGES               (NUM_STAGES               )
)
u_FIFO_top(
    .i_RST        (i_RST_tb        ),
    .i_clk_write  (i_clk_write_tb  ),
    .i_wr_data    (i_wr_data_tb    ),
    .i_wr_en      (i_wr_en_tb      ),
    .o_Full_Flag  (o_Full_Flag_tb  ),
    .i_clk_read   (i_clk_read_tb   ),
    .i_rd_en      (i_rd_en_tb      ),
    .o_rd_data    (o_rd_data_tb    ),
    .o_Empty_Flag (o_Empty_Flag_tb )
);



endmodule