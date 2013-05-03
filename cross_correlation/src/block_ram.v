module block_ram (
    input              clk,
    input       [15:0]  ra,
    output reg  [15:0] rd,
		  
    input       [15:0]  wa,
    input       [15:0] wd,
    input              we);
    
    reg [15:0] ram [1023:0];

    always @(*) begin
        rd = ram[ra];
    end
   
    always @(posedge clk) begin
        if (we) ram[wa] <= wd;
    end

endmodule
