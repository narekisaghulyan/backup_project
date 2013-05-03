//Cross Correlator module

module cc_1(
   input rst,
   input start,
   input  [15:0] m0,
   input  [15:0] m1,
   input clk,
   output reg [15:0]  index,
   output reg done	    
       
	    
);
   localparam Idle = 2'b00;
   localparam ReadInputs = 2'b01;
   localparam Busy = 2'b10;
   localparam Done = 2'b11;

   reg [1:0] state;

   localparam N     = 1024;
   localparam LMAX  = 32;
   localparam LMIN  = -LMAX; 
   localparam KMIN  = -N/2 - LMIN;
   localparam KMAX  = -KMIN;
   
  
   
   reg [15:0] 	     lag;
   reg [15:0] 	     k;
   reg [15:0]         i;
   reg [63:0]	     sum;
   reg [63:0] 	     maxsum;
   reg [15:0] 	     ra0;
   reg [15:0] 	     ra1;
   reg [15:0] 	     wa;
   wire [15:0] 	     rd0;
   wire [15:0] 	     rd1;
   reg [15:0] 	     wd0;
   reg [15:0] 	     wd1;
   reg 		     we;
   reg 		     valid;
   

   block_ram bram0(.clk(clk), .ra(ra0), .rd(rd0), .wa(wa), .wd(wd0), .we(we));
   block_ram bram1(.clk(clk), .ra(ra1), .rd(rd1), .wa(wa), .wd(wd1), .we(we));

   // Combinational logic
   always @(*) begin
      we =   state == ReadInputs;
      done = state == Done;
      wd0 = m0;
      wd1 = m1;
      
      ra0 = ((i>>1) + i[0]) + (k - KMIN);
      ra1 = (LMAX - (i>>1)) + (k - KMIN);
   end

   // Transitions
   always @(posedge clk) begin
      if(rst) state   <= Idle;
      else case (state)
	Idle: begin
	   index <= 0; 
	   ra0   <= 0;
	   ra1   <= 0;
	   wa    <= 0;
	   i     <= 0; 
	   lag   <= LMIN;
	   k     <= KMIN;
	   sum   <= 0;
	   maxsum <= 0;
	   
	  if (start) state <= ReadInputs;
	end
	ReadInputs: begin
	   wa <= wa+1;

	   if(wa + 1 == N)begin
	      state <= Busy;
	      k     <= KMIN;
	   end
	   else k <= k+1;
	   /*
	   if ($signed(k+1) < KMAX) k <= k+1;
	   else begin
	      state <= Busy;
	      k <= KMIN;
	   end
	    */
	end
	Busy:begin
	   if ($signed(k) < KMAX) begin   // calculate sum
	      sum <= sum + rd0*rd1;
	      k <= k+1;
	   end
	   else begin
	      if(sum > maxsum) begin      // new maxsum?
		 maxsum <= sum;
		 index  <= lag;
	      end


	      if($signed(lag) < LMAX) begin
		 sum <= 0;
		 k <= KMIN;
		 
		 lag <= lag+1;
		 i <= i+1;
	      end
	      else state <= Done;
	   end // else
	   
	end // case: Busy
	
	Done: begin
	   if(start)begin
	      index <= 0;
	      ra0   <= 0;
	      ra1   <= 0;
	      i     <= 0;
	      wa    <= 0;
	      lag   <= LMIN;
	      k     <= KMIN;
	      sum   <= 0;
	      maxsum <= 0;
	      state <= ReadInputs;
	   end // if (start)  
	end // case: Done
	
	default: state <= Idle;
      endcase
   end // always @ (posedge clk)

endmodule
   
   
   
	    
	    
