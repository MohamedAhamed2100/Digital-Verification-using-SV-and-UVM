module FIFO_tb(FIFO_IF.TB fifo_intf);
 
  import FIFO_transaction_pkg::*;
  import Shared_pkg::*;
  
  // ===== Create transaction object =====
  FIFO_transaction fifo_txn;
  
  initial begin
    // ===== Create transaction object =====
    fifo_txn = new();
    
    // ===== Disable randomization & constrain =====
    fifo_txn.rand_mode(0);
    fifo_txn.constraint_mode(0);
    
    // ===== Initialize fifo inputs =====
    fifo_intf.data_in = 0;
    fifo_intf.wr_en = 0;
    fifo_intf.rd_en = 0;
    fifo_intf.rst_n = 0;
    
    // ===== Trigger sample event for monitor =====
    fifo_intf.trigger_sample();
    
    // ===== Apply reset for a few cycles =====
    repeat(2) @(posedge fifo_intf.clk);
	
    // ===== Apply Release reset =====
    fifo_intf.rst_n = 1;
    
    repeat(2) @(posedge fifo_intf.clk);
    
    // ===== Enable randomization & constrain =====
    fifo_txn.rand_mode(1);
    fifo_txn.constraint_mode(1);
    
    // ===== Start Randomaize Test Tramsactions  =====
    for (int i = 0; i < TEST_COUNT; i++) begin
		// ===== Randomize transaction =====
		if (!fifo_txn.randomize()) begin
			$error("Randomization failed at iteration %0d", i);
			break;
		end
		
		// ===== Wait for negedge clock =====
		@(negedge fifo_intf.clk);
		
		// ===== Drive inputs from transaction =====
		fifo_intf.data_in = fifo_txn.data_in;
		fifo_intf.wr_en   = fifo_txn.wr_en;
		fifo_intf.rd_en   = fifo_txn.rd_en;
		fifo_intf.rst_n   = fifo_txn.rst_n;

		// ===== Trigger sample event for monitor =====
		fifo_intf.trigger_sample();

    end
    
    // ===== Signal end of test =====
    repeat(5) @(posedge fifo_intf.clk);
    test_finished = 1;
    
    // ===== Wait a few more cycles for monitor to process results =====
    repeat(5) @(posedge fifo_intf.clk);
  end
  
endmodule
