// FILE NAME: washing_machine.v
// TYPE: module
// AUTHOR: Yousef Sherif
// AUTHOR’S EMAIL: shirefy49@gmail.com
//---------------------------------------------------------------------
// PURPOSE: Digital Design Assignment
//---------------------------------------------------------------------
// KEYWORDS: Controller unit for a washing machine, asynchronous clear
//---------------------------------------------------------------------
// Copyright 2022, Yousef Sherif, All rights reserved.
//---------------------------------------------------------------------

////////////////////////////////////////////////////////
//////////////// Module Difinition ///////////////////// 
////////////////////////////////////////////////////////
module washing_machine (

 input      wire                 clk         ,
 input      wire                 rst_n       ,
 input      wire      [1:0]      clk_freq    ,
 input      wire                 coin_in     ,
 input      wire                 double_wash ,
 input      wire                 timer_pause ,
 output     reg                  wash_done
);

////////////////////////////////////////////////////////
/////////// States Encoded in Gray Encoding //////////// 
////////////////////////////////////////////////////////
 localparam         IDLE          = 3'b000 ,
                    FILLING_WATER = 3'b001 ,
                    WASHING       = 3'b011 ,
                    RINSING       = 3'b010 ,
                    SPINNING      = 3'b110 ;

////////////////////////////////////////////////////////
///////////////// Control Signals ////////////////////// 
//////////////////////////////////////////////////////// 
 reg  [2:0]  current_state ,
             next_state    ;

// States Control Signals
 reg filling_start    ;
 reg filling_end      ;
 reg washing_start    ;
 reg washing_end      ;
 reg rinsing_start    ;
 reg rinsing_end      ;
 reg spinning_start   ;
 reg spinning_end     ;
 reg double_wash_done ;

// For Timer
 reg [31:0] counter     ;
 reg timer_pause_start  ;

////////////////////////////////////////////////////////
///////////////// State Transition ///////////////////// 
////////////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
       current_state <= IDLE ;
       filling_start <= 1'b0  ;
       filling_end   <= 1'b0  ;
       washing_start <= 1'b0  ;
       washing_end   <= 1'b0  ;
       rinsing_start <= 1'b0  ;
       rinsing_end   <= 1'b0  ;
       spinning_start     <= 1'b0 ;
       spinning_end       <= 1'b0 ;
       timer_pause_start  <= 1'b0 ;
       double_wash_done   <= 1'b0 ;
       counter    <= 32'b0 ;
    end
  else begin
      current_state <= next_state ;
    end
end

////////////////////////////////////////////////////////
///////////////// Next State Logic ///////////////////// 
////////////////////////////////////////////////////////
always @(*) begin

 case (current_state)
   IDLE : begin
       if (spinning_end) begin
           next_state = IDLE ;
       end
       else begin
         if(timer_pause_start) begin
           if(timer_pause) begin
             next_state = IDLE ;
           end
         else begin
             next_state = SPINNING ;
           end
       end
     else begin
       if(coin_in) begin
           filling_start = 1'b1 ;
           next_state = FILLING_WATER ;
         end
       else begin
           next_state = IDLE ;
         end  
       end
       end
     end
   FILLING_WATER : begin
     if(filling_end) begin 
         washing_start = 1'b1 ;
         washing_end   = 1'b0 ;
         next_state = WASHING ;
       end
     else begin
       filling_start = 1'b1 ;
       next_state = FILLING_WATER ;
       end
     end
   WASHING : begin
     if(washing_end) begin
         rinsing_start = 1'b1 ;
         rinsing_end   = 1'b0 ;
         next_state = RINSING ;
       end
     else begin
       washing_start = 1'b1 ;
       next_state = WASHING ;
       end
     end
   RINSING : begin
     if(rinsing_end) begin
       if(double_wash && !double_wash_done) begin
           double_wash_done = 1'b1 ;
           next_state = FILLING_WATER ;
         end
       else begin
           spinning_start = 1'b1 ;
           next_state = SPINNING ;
         end        
       end
     else begin
         rinsing_start = 1'b1 ;
         next_state = RINSING ;
       end
   end
   SPINNING : begin
     if(timer_pause) begin
          timer_pause_start = 1'b1 ;
          next_state = IDLE ;
       end
     else begin
         if(spinning_end) begin
             next_state = IDLE ;
         end
       end
     end
   default : begin
       filling_start = 1'b0 ;
       filling_end   = 1'b0 ;
       washing_start = 1'b0 ;
       washing_end   = 1'b0 ;
       rinsing_start = 1'b0 ;
       rinsing_end   = 1'b0 ;
       spinning_start     = 1'b0 ;
       spinning_end       = 1'b0 ;
       timer_pause_start  = 1'b0 ;
       double_wash_done   = 1'b0 ;
       counter    = 32'b0 ;
       next_state = IDLE ;
     end  
   endcase   
end

////////////////////////////////////////////////////////
////////////////////// Timer /////////////////////////// 
////////////////////////////////////////////////////////
always @(posedge clk) begin
 case (clk_freq)
   2'b00 : begin // clk = 1 Mhz
       if(filling_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd120000000) begin // 2 minutes = 120,000,000 * 1 us
               filling_start <= 1'b0;
               filling_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(washing_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd300000000) begin // 5 minutes = 300,000,000 * 1 us
               washing_start <= 1'b0;
               washing_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(rinsing_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd120000000) begin // 2 minutes = 120,000,000 * 1 us
               rinsing_start <= 1'b0;
               rinsing_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(spinning_start & ~timer_pause & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd60000000) begin // 1 minutes = 60,000,000 * 1 us
               spinning_start <= 1'b0;
               spinning_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(spinning_start & timer_pause & ~wash_done) begin
           counter <= counter + 1'b0;
         end
     end
    
   2'b01 : begin // clk = 2 Mhz
       if(filling_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd240000000) begin // 2 minutes = 240,000,000 * 1/2 us
               filling_start <= 1'b0;
               filling_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(washing_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd600000000) begin // 5 minutes = 600,000,000 * 1/2 us
               washing_start <= 1'b0;
               washing_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(rinsing_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd240000000) begin // 2 minutes = 240,000,000 * 1/2 us
               rinsing_start <= 1'b0;
               rinsing_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(spinning_start & ~timer_pause & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd120000000) begin // 1 minutes = 120,000,000 * 1/2 us
               spinning_start <= 1'b0;
               spinning_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(spinning_start & timer_pause & ~wash_done) begin
           counter <= counter + 1'b0;
         end
     end

   2'b10 : begin // clk = 4 Mhz
       if(filling_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd480000000) begin // 2 minutes = 480,000,000 * 1/4 us
               filling_start <= 1'b0;
               filling_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(washing_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd1200000000) begin // 5 minutes = 1200,000,000 * 1/4 us
               washing_start <= 1'b0;
               washing_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(rinsing_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd480000000) begin // 2 minutes = 480,000,000 * 1/4 us
               rinsing_start <= 1'b0;
               rinsing_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(spinning_start & !timer_pause & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd240000000) begin // 1 minutes = 240,000,000 * 1/4 us
               spinning_start <= 1'b0;
               spinning_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(spinning_start & timer_pause & ~wash_done) begin
           counter <= counter + 1'b0;
         end
     end

   2'b11 : begin // clk = 8 Mhz
       if(filling_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd960000000) begin // 2 minutes = 960,000,000 * 1/8 us
               filling_start <= 1'b0;
               filling_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(washing_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd2400000000) begin // 5 minutes = 2400,000,000 * 1/8 us
               washing_start <= 1'b0;
               washing_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(rinsing_start & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd960000000) begin // 2 minutes = 960,000,000 * 1/8 us
               rinsing_start <= 1'b0;
               rinsing_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(spinning_start & ~timer_pause & ~wash_done) begin
           counter <= counter + 1'b1;
           if(counter == 32'd480000000) begin // 1 minutes = 480,000,000 * 1/8 us
               spinning_start <= 1'b0;
               spinning_end <= 1'b1;
               counter <= 32'd0;
             end
         end

       else if(spinning_start & timer_pause & ~wash_done) begin
           counter <= counter + 1'b0;
         end
     end
  default : begin
      filling_end  <= 1'b0;
      washing_end  <= 1'b0;
      rinsing_end  <= 1'b0;
      spinning_end <= 1'b0;
    end
endcase
end

////////////////////////////////////////////////////////
/////////////////// Output Logic /////////////////////// 
////////////////////////////////////////////////////////
always @(*) begin
  wash_done  = 1'b0 ;

if(spinning_end & ~timer_pause) begin
    wash_done = 1'b1 ;
  end
else begin
    wash_done = 1'b0 ;
  end
end

endmodule

