import Shared_pkg::*;

module FIFO_top;
  
	// ====== Generate Clock ======
	bit clk;
	initial begin
		clk = 0;
		forever #5 clk = ~clk;  // 200 MHZ
	end
  
    // ====== interface instance ======
    FIFO_IF fifo_intf (clk);
  
	// ====== Instantiate DUT ======
	FIFO #(
		.FIFO_WIDTH(FIFO_WIDTH),
		.FIFO_DEPTH(FIFO_DEPTH)
	) dut (
		.fifo_intf(fifo_intf)
	);
  
    // ====== Instantiate testbench ======
    FIFO_tb tb (
		.fifo_intf(fifo_intf)
	);
  
    // ====== Instantiate monitor ======
    FIFO_monitor mon 
	(
		.fifo_intf(fifo_intf)
    );
  
endmodule
