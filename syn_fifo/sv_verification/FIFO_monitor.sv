import Shared_pkg::*;

module FIFO_monitor (FIFO_IF.MON fifo_intf);

  // ===== Import required packages =====
  import FIFO_transaction_pkg::*;
  import FIFO_coverage_pkg::*;
  import FIFO_scoreboard_pkg::*;
  import Shared_pkg::*;
  
  // ===== Create class objects ======
  FIFO_transaction fifo_txn;
  FIFO_scoreboard  fifo_scb;
  FIFO_coverage    fifo_cov;
  
  initial begin
    // ==== Create objects ====
    fifo_txn = new();
    fifo_scb = new();
    fifo_cov = new();
    
    // ==== Start monitoring ==== 
    forever begin
      // ==== Wait for negedge clock to sample data ====
      @(negedge fifo_intf.clk);
      
      // ==== Wait for sampling event from testbench ====
      fifo_intf.trigger_sample();
      
      // ==== Sample the interface and update transaction object ====
      // ==== Input =====
      fifo_txn.data_in = fifo_intf.data_in;
      fifo_txn.wr_en = fifo_intf.wr_en;
      fifo_txn.rd_en = fifo_intf.rd_en;
      fifo_txn.rst_n = fifo_intf.rst_n;
      // ==== Output =====
      fifo_txn.data_out = fifo_intf.data_out;
      fifo_txn.full = fifo_intf.full;
      fifo_txn.empty = fifo_intf.empty;
      fifo_txn.almostfull = fifo_intf.almostfull;
      fifo_txn.almostempty = fifo_intf.almostempty;
      fifo_txn.overflow = fifo_intf.overflow;
      fifo_txn.underflow = fifo_intf.underflow;
      fifo_txn.wr_ack = fifo_intf.wr_ack;
      
      // ==== Fork-join to run coverage and scoreboard in parallel ====
      fork
		// ==== Process 1: Sample coverage ====
		fifo_cov.sample_data(fifo_txn);
                begin 
			// ==== Process 2: Check data with scoreboard ====
			@(posedge fifo_intf.clk);
			// ======= Wait Output To Be Stable =======
			#3;
			fifo_scb.check_data(fifo_txn);
		end 	
      join
      
      // Check if test is finished
      if (test_finished) begin
        // Display test summary
        $display("Test Summary:");
        $display("  Total Correct: %0d", correct_count);
        $display("  Total Errors: %0d", error_count);
        $display("  Coverage: %0.2f%%", fifo_cov.fifo_cg.get_coverage());
        $stop;
      end
    end
  end
endmodule
