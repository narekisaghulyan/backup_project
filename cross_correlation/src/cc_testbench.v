//Module: cc_testbench.v

`timescale 1ns/1ps

module cc_testbench();

    parameter Halfcycle = 5; //half period is 5ns
    
    localparam Cycle = 2*Halfcycle;
    
    reg Clock;
    
    // Clock Signal generation:
    initial Clock = 0; 
    always #(Halfcycle) Clock = ~Clock;

   // Register and wires to test the cross correlation
   reg  [15:0] A [0:19200];
   reg  [15:0] B [0:19200];
   reg  [15:0] C [0:19200];
   reg  [15:0] D [0:19200];
   reg  [17:0] addr;

   wire [15:0] CCout1;
   wire [15:0] CCout2;
   wire [15:0] CCout3;

   reg [15:0]  tau1;
   reg [15:0]  tau2;
   reg [15:0]  tau3;


   reg [15:0]   x1_1;
   reg [15:0]   x1_2;
   reg [15:0]   x2_1;
   reg [15:0]   x2_2;
   reg [15:0]   x3_1;
   reg [15:0]   x3_2;

   reg [15:0]   y1_1;
   reg [15:0]   y1_2;
   reg [15:0]   y2_1;
   reg [15:0]   y2_2;
   
   
   reg [15:0]   xs;
   reg [15:0]   ys;
   
   
   //wire [9:0]  DUTout;// [2:0];
   //reg  [9:0]  REFout;
   reg         rst, start;
   wire        done;
  
    

   //Task for checking the output
   /*
   task checkOutput;
      if (($signed(REFout) - $signed(DUTout) >= -1) && ($signed(REFout) - $signed(DUTout) <= 1)) begin
           $display("PASS    DUTout: %d, REFout: %d", $signed(DUTout), $signed(REFout));
        end
        else begin
           $display("FAIL    DUTout: %d, REFout: %d", $signed(DUTout), $signed(REFout));
	   //$finish();
        end
    endtask
    */
   
   //This is where the modules being tested are instantiated.
     cc_1 cc_test1(.rst(rst), .start(start), .m0(A[addr]), .m1(B[addr]), .clk(Clock), .index(CCout1), .done(done));
     cc_1 cc_test2(.rst(rst), .start(start), .m0(A[addr]), .m1(C[addr]), .clk(Clock), .index(CCout2), .done(done));
     cc_1 cc_test3(.rst(rst), .start(start), .m0(A[addr]), .m1(D[addr]), .clk(Clock), .index(CCout3), .done(done));
   integer i;
   initial begin
      $display("\n\nSTARTING ALL TESTS");
      $readmemh("/home/cc/cs150/sp13/class/cs150-ad/backup_project/cross_correlation/src/sineCraft/sines1.hex", A);
      $readmemh("/home/cc/cs150/sp13/class/cs150-ad/backup_project/cross_correlation/src/sineCraft/sines2.hex", B);
      $readmemh("/home/cc/cs150/sp13/class/cs150-ad/backup_project/cross_correlation/src/sineCraft/sines3.hex", C);
      $readmemh("/home/cc/cs150/sp13/class/cs150-ad/backup_project/cross_correlation/src/sineCraft/sines4.hex", D);
      
      //REFout = -19;
      addr = 0;
      rst = 1;
      #10;
      rst = ~rst;
      start = 1;
      
      #10;
      start = 0;

      $display("\n\nENTERING FOR LOOP"); 

      // ReadInputs
      for(i = 0; i < 1024; i=i+1) begin
	 //$display("addr=%6.0d  A=%5.0d  B=%5.0d", addr, A[addr], B[addr]);
	 
	 addr = addr +1;
	 #10;
      end

      // Busy
      while(~done) begin
	 #10;
      end

      tau1 =$signed(CCout1);
      $display("tau1 %d", $signed(tau1));
      tau2 = $signed(CCout2);
      $display("tau2 %d", $signed(tau2));
      tau3 = $signed(CCout3);
      $display("tau3 %d", $signed(tau3));

      x1_1 = $signed(CCout1)*8;
      x1_2 = $signed(x1_1)*0;

       $display("x1_2 %d", $signed(x1_2));
      
      x2_1 = $signed(CCout2)*8;
      x2_2 = $signed(x2_1)*0.16;

      $display("x2_2 %d", $signed(x2_2));

      x3_1 = $signed(CCout3)*8;
      x3_2 = $signed(x3_1)*0.16;

       $display("x3_2 %d", $signed(x3_2));

      xs = -$signed(/* $signed(x1_2) + $signed(x2_2)*/ + $signed(x3_2));

      y1_1 = $signed(CCout1)*8;
      y1_2 = $signed(y1_1)*0.16;

      $display("y1_2 %d", $signed(y1_2));
      
      y2_1 = $signed(CCout2)*8;
      y2_2 = $signed(y2_1)*0.16;

      $display("y2_2 %d", $signed(y2_2));
     // y3_1 = $signed(CCout3)*0;
     // y3_2 = $signed(y3_1)*8;

      ys = -$signed($signed(y1_2) /*+ $signed(y2_2)*/);

      
      
      $display("the xs is %d, the ys is %d", $signed(xs), $signed(ys));
      
      // Done (WriteOutputs)
      /*
      for(i = 0; i < 1; i=i+1) begin
	// checkOutput();
	 #10;
      end
      */
      $finish();   
   end
endmodule
     
   
