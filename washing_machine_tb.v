// FILE NAME: washing_machine_tb.v
// TYPE: module
// AUTHOR: Yousef Sherif
// AUTHOR’S EMAIL: shirefy49@gmail.com
//-------------------------------------------------------------------------------
// PURPOSE: Digital Design Assignment Testbench
//-------------------------------------------------------------------------------
// KEYWORDS: Controller unit for a washing machine, asynchronous clear. Testbench
//-------------------------------------------------------------------------------
// Copyright 2022, Yousef Sherif, All rights reserved.
//-------------------------------------------------------------------------------
`timescale 1us/1ns 
module washing_machine_tb() ;

////////////////////////////////////////////////////////
/////////////////// DUT Signals //////////////////////// 
////////////////////////////////////////////////////////
 reg                 clk_tb         ;
 reg                 rst_n_tb       ;
 reg      [1:0]      clk_freq_tb    ;
 reg                 coin_in_tb     ;
 reg                 double_wash_tb ;
 reg                 timer_pause_tb ;
 wire                wash_done_tb   ;

////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////
initial begin

 // Save Waveform
   $dumpfile("washing_machine.vcd") ;       
   $dumpvars; 

 // initialization
   initialize() ;

 // Reset
   reset() ;

 // double_wash
   double_wash() ;
   clk_freq_tb    = 2'b11 ;      // frequency is 8 MHz
   coin_in_tb     = 1'b1  ;      // coin is deposited

#975
 // Timer_Pause
   Timer_Pause() ;

#3000
$finish ;
end 

////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

/////////////// Signals Initialization /////////////////
task initialize;
 begin 
  clk_tb         = 1'b0  ;
  clk_freq_tb    = 2'b00 ;      // frequency is 1 MHz
  coin_in_tb     = 1'b0  ;      // initially coin is not deposited
  double_wash_tb = 1'b0  ;      // initially double_wash button is not pressed
  timer_pause_tb = 1'b0  ;      // initially timer_pause button is not pressed
 end
endtask

///////////////////////// RESET ////////////////////////
task reset;
 begin
 rst_n_tb =  'b1;
 #1
 rst_n_tb  = 'b0;
 #1
 rst_n_tb  = 'b1;
 end
endtask  

//////////////////// double_wash ///////////////////////
task double_wash;
 begin
 #1
  double_wash_tb = 1'b1  ;      // double_wash button is pressed
 end
endtask  

//////////////////// Timer_Pause ///////////////////////
task Timer_Pause;
 begin
 #1
    timer_pause_tb = 1'b1  ;      // timer_pause button is pressed
 #4
    timer_pause_tb = 1'b0  ;      // timer_pause button is released
 end
endtask

////////////////////////////////////////////////////////
////////////////// Clock Generator  ////////////////////
////////////////////////////////////////////////////////

//always #0.5    clk_tb = ~clk_tb ;   // period = 1 us       (1 MHz)  
//always #0.25   clk_tb = ~clk_tb ;   // period = 0.5 us     (2 MHz)  
//always #0.125  clk_tb = ~clk_tb ;   // period = 0.25 us    (4 MHz)  
  always #0.0625 clk_tb = ~clk_tb ;   // period = 0.125 us   (8 MHz)  

////////////////////////////////////////////////////////
/////////////////// DUT Instantation ///////////////////
////////////////////////////////////////////////////////

washing_machine DUT (
.clk(clk_tb ),
.rst_n(rst_n_tb), 
.clk_freq(clk_freq_tb),
.coin_in(coin_in_tb),
.double_wash(double_wash_tb),
.timer_pause(timer_pause_tb),
.wash_done(wash_done_tb));

endmodule 

