//Module: cc_localizer_testbench
//connect the cross_correlation and the localizer_2 modules 

`timescale 1ns/1ps

module cc_localizer_testbench();

    parameter Halfcycle = 5; //half period is 5ns
    
    localparam Cycle = 2*Halfcycle;
    
    reg Clock;
    
    // Clock Signal generation:
    initial Clock = 0; 
    always #(Halfcycle) Clock = ~Clock;

   localparam LENGTH = 8192;
   localparam s      = 33554432;
   localparam fs     = 49152000;
   
   
   // Register and wires to test the cross correlation
   reg  [15:0] A [0:LENGTH-1];
   reg  [15:0] B [0:LENGTH-1];
   reg  [15:0] C [0:LENGTH-1];
   reg  [15:0] D [0:LENGTH-1];
   reg  [17:0] addr;
   wire [15:0]  CCout1;
   wire [15:0]  CCout2;
   wire [15:0]  CCout3;
   wire [127:0] 	DUTout [0:1];
   reg [127:0] 	REFout [0:1];
   reg         rst, start;
   wire        done; 
   wire        testing;

   reg [63:0]  tau1_1;
   reg [63:0]  tau1_2;
   reg [63:0]  tau2_1;
   reg [63:0]  tau2_2;
   reg [63:0]  tau3_1;
   reg [63:0]  tau3_2;
   
   reg [63:0]  tau1;
   reg [63:0]  tau2;
   reg [63:0]  tau3;

   

   
    task checkOutput;
       if (($signed(REFout[0]) - $signed(DUTout[0]) >= -(REFout[0]*0.1)) && 
	   ($signed(REFout[0]) - $signed(DUTout[0]) <= (REFout[0]*0.1))  && 
	   ($signed(REFout[1]) - $signed(DUTout[1]) >= -(REFout[1]*0.1)) && 
	   ($signed(REFout[1]) - $signed(DUTout[1]) <= (REFout[1]*0.1))) begin
	   $display("####################################    ERROR WITHIN 10 PERCENT     ######################################");
           $display("PASS    DUTout[0]: %d, REFout[0]: %d", $signed(DUTout[0]), $signed(REFout[0]));
	   $display("PASS    DUTout[1]: %d, REFout[1]: %d", $signed(DUTout[1]), $signed(REFout[1]));
        end
        else begin
           $display("FAIL    DUTout: %d, REFout: %d", $signed(DUTout[0]), $signed(REFout[0]));
	   $display("FAIL    DUTout: %d, REFout: %d", $signed(DUTout[1]), $signed(REFout[1]));
	   //$finish();
        end
    endtask // checkOutput
  
   
   //This is where the modules being tested are instantiated.
     cc_1 cc_test1(.rst(rst), .start(start), .m0(A[addr]), .m1(B[addr]), .clk(Clock), .index(CCout1), .done(done));
     cc_1 cc_test2(.rst(rst), .start(start), .m0(A[addr]), .m1(C[addr]), .clk(Clock), .index(CCout2), .done(done));
     cc_1 cc_test3(.rst(rst), .start(start), .m0(A[addr]), .m1(D[addr]), .clk(Clock), .index(CCout3), .done(done));

     localizer_2 localizer_test1(.tau1($signed(tau1)), .tau2($signed(tau2)), .tau3($signed(tau3)), .posx(DUTout[0]), .posy(DUTout[1]));
  
   integer i;
   initial begin
      $display("\n\nSTARTING ALL TESTS");
      $readmemh("/home/cc/cs150/sp13/class/cs150-ad/cc_localizer_192k/src/sineCraft/sines1.hex", A);
      $readmemh("/home/cc/cs150/sp13/class/cs150-ad/cc_localizer_192k/src/sineCraft/sines2.hex", B);
      $readmemh("/home/cc/cs150/sp13/class/cs150-ad/cc_localizer_192k/src/sineCraft/sines3.hex", C);
      $readmemh("/home/cc/cs150/sp13/class/cs150-ad/cc_localizer_192k/src/sineCraft/sines4.hex", D);

      
     // REFout = 19;
      addr = 0;
      rst = 1;
      #10;
      rst = ~rst;
      start = 1;
      
      #10;
      start = 0;

      $display("\n\nENTERING FOR LOOP"); 

      // ReadInputs
      for(i = 0; i < LENGTH; i=i+1) begin
	 //$display("addr=%6.0d  A=%5.0d  B=%5.0d", addr, A[addr], B[addr]);
	 
	 addr = addr +1;
	 #10;
      end
       $display("\n\nFINISH FOR LOOP");
      // Busy
      while(~done) begin
	 #10;
      end

      $display("tau1 = %4.2d  tau2 = %4.2d  tau3 = %4.2d", $signed(CCout1),$signed(CCout2), $signed(CCout3));

      // Done (WriteOutputs)
      tau1_1 = $signed(CCout1)*s;
      $display("tau1_1 = %d", $signed(tau1_1));
      
      tau1_2 = $signed($signed(tau1_1)/fs);
      tau1 = tau1_2;
      
//$signed($signed(CCout1)*s)/fs;
      tau2_1 = $signed(CCout2)*s;
      $display("tau2_1 = %d", $signed(tau2_1));
      tau2_2 = $signed($signed(tau2_1)/fs);
      tau2 =   tau2_2;
      
//$signed($signed(CCout2)*s)/fs;
      tau3_1 = $signed(CCout3)*s;
      $display("tau3_1 = %d", $signed(tau3_1));
      tau3_2 = $signed($signed(tau3_1)/fs);
      tau3 =   tau3_2;
      
//$signed($signed(CCout3)*s)/fs;

      $display("tau1 = %d  tau2 = %d  tau3 = %d", $signed(tau1), $signed(tau2), $signed(tau3));
      /*
      for(i = 0; i < 12800; i=i+1) begin
	 checkOutput();
	 #10;
      end
      */
       #100;
    
      
      REFout[0] = $floor(11*s);   //11
      REFout[1] = $floor(12*s);   //12
       
      #10;
      checkOutput();
      

      $finish();   
   end
endmodule
     
   
