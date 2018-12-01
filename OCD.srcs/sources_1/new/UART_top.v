`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Chance and the boosted animals
// Engineer: Justin Lee 
// 
// Create Date: 07/05/2015 12:39:26 AM
// Design Name: Voltage sender 
// Module Name: UART_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:  XLXI_7 - xadc_wiz
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module UART_top(
    //UART ARGUMENTS
    input btn0,
    input btn1,
    input clk,
    output TxD,
    output TxD_debug,
    output transmit_debug,
    output button_debug, 
    output clk_debug,
    //UART END 
    input [7:0]sw,
    //XDC ARGUMENTS
    input vauxp6,
    input vauxn6,
    input vauxp7,
    input vauxn7,
    input vauxp15,
    input vauxn15,
    input vauxp14,
    input vauxn14
    //output reg [15:0] LED,
    //output [3:0] an,
    //output dp,
    //output [6:0] seg 
    //XDC END
); 
    reg transmit_send;
    wire transmit;
    assign TxD_debug = TxD;
    assign transmit_debug = transmit;
    assign button_debug = btn1;
    assign clk_debug = clk;

    transmit_debouncing D2 (.clk(clk), .btn1(btn1), .transmit(transmit));
    transmitter T1 (.clk(clk), .reset(btn0),.transmit(transmit),.TxD(TxD),.data(voltage_data));   
    //transmitter T1 (.clk(clk), .reset(btn0),.transmit(transmit_send),.TxD(TxD),.data(voltage_data));   

    //XADC
    wire enable;  
    wire ready;
    wire [15:0] data;   
    reg [6:0] Address_in;     
    reg [32:0] decimal;   
//    reg [3:0] dig0;
//    reg [3:0] dig1;
//    reg [3:0] dig2;
//    reg [3:0] dig3;
//    reg [3:0] dig4;
//    reg [3:0] dig5;
//    reg [3:0] dig6;
    reg [7:0] dig0;
    reg [7:0] dig1; 
    reg [7:0] dig2;
    reg [7:0] dig3;
    reg [7:0] dig4;
    reg [7:0] dig5;
    reg [7:0] dig6;
    //reg [7:0] voltage_data;
    reg [47:0] voltage_data;

   //xadc instantiation connect the eoc_out .den_in to get continuous conversion
    xadc_wiz_0  XLXI_7 (.daddr_in(Address_in), //addresses can be found in the artix 7 XADC user guide DRP register space
                      .dclk_in(clk), 
                      .den_in(enable), 
                      .di_in(), 
                      .dwe_in(), 
                      .busy_out(),                    
                      .vauxp6(vauxp6),
                      .vauxn6(vauxn6),
                      .vauxp7(vauxp7),
                      .vauxn7(vauxn7),
                      .vauxp14(vauxp14),
                      .vauxn14(vauxn14),
                      .vauxp15(vauxp15),
                      .vauxn15(vauxn15),
                      .vn_in(), 
                      .vp_in(), 
                      .alarm_out(), 
                      .do_out(data), 
                      //.reset_in(),
                      .eoc_out(enable),
                      .channel_out(),
                      .drdy_out(ready));
        /*b             
          //led visual dmm              
                      always @( posedge(CLK100MHZ))
                      begin            
                        if(ready == 1'b1)
                        begin
                          case (data[15:12])
                            1:  LED <= 16'b11;
                            2:  LED <= 16'b111;
                            3:  LED <= 16'b1111;
                            4:  LED <= 16'b11111;
                            5:  LED <= 16'b111111;
                            6:  LED <= 16'b1111111; 
                            7:  LED <= 16'b11111111;
                            8:  LED <= 16'b111111111;
                            9:  LED <= 16'b1111111111;
                            10: LED <= 16'b11111111111;
                            11: LED <= 16'b111111111111;
                            12: LED <= 16'b1111111111111;
                            13: LED <= 16'b11111111111111;
                            14: LED <= 16'b111111111111111;
                            15: LED <= 16'b1111111111111111;                        
                           default: LED <= 16'b1; 
                           endcase
                        end 
                
                          
                      end */
    reg [64:0] count;
    reg [64:0] transmit_counter; //Counter for transmit, adds a manula wait.
 
    //binary to decimal conversion
    always @ (posedge(clk))
    begin
        if(count == 1000)begin
            transmit_send = 1;
            decimal = data >> 4;
            //looks nicer if our max value is 1V instead of .999755
            if(decimal >= 4093)
            begin
            dig0 = 0;
            dig1 = 0;
            dig2 = 0;
            dig3 = 0;
            dig4 = 0;
            dig5 = 0;
            dig6 = 1;
            count = 0;
            end
        else 
        begin
            decimal = decimal * 250000; 
            decimal = decimal >> 10;
            dig0 = decimal % 10 + 48;
            decimal = decimal / 10;        
            dig1 = decimal % 10 + 48;
            decimal = decimal / 10;   
            dig2 = decimal % 10 + 48;
            decimal = decimal / 10; 
            dig3 = decimal % 10 + 48;
            decimal = decimal / 10;
            dig4 = decimal % 10 + 48;
            decimal = decimal / 10;   
            dig5 = decimal % 10 + 48;
            decimal = decimal / 10; 
            dig6 = decimal % 10 + 48; //TO OUTPUT
            decimal = decimal / 10;
            //voltage_data = {dig3, dig2, dig1, dig0, 8'h2E, 8'h0A};
              voltage_data = {dig6, 8'h2E, dig5, dig4, dig3, 8'h0D}; 
 
            //voltage_data = dig6;
            //voltage_data = 46; // ,
            //voltage_data = dig5;
            //voltage_data = dig4;
            //voltage_data = dig3;
            count = 0;
        end
    end
    count = count + 1;
    end
  
   always @(posedge(clk))
   begin
        case(sw)
        0: Address_in <= 8'h16;
        1: Address_in <= 8'h17;
        2: Address_in <= 8'h1e;
        3: Address_in <= 8'h1f;
        // 4: LED <= 16'b1;
        endcase
   end

   /*DigitToSeg segment1(.in1(dig3),
                      .in2(dig4),
                      .in3(dig5),
                      .in4(dig6),
                      .in5(),
                      .in6(),
                      .in7(),
                      .in8(),
                      .mclk(CLK100MHZ),
                      .an(an),
                      .dp(dp),
                      .seg(seg));*/
endmodule
