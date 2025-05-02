import Shared_pkg::*;
import FIFO_test_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module top();
   bit clk;
  
   initial begin 
     forever 
        #1 clk = ~clk;
   end 
   
   FIFO_IF fifo_intf (clk);

   FIFO #(
	.FIFO_WIDTH(FIFO_WIDTH),
	.FIFO_DEPTH(FIFO_DEPTH)
   ) dut (
	.fifo_intf(fifo_intf)
   );
   
   initial begin 
      uvm_config_db#(virtual FIFO_IF)::set(null, "uvm_test_top", "FIFO_VIF", fifo_intf);
      run_test("FIFO_test");
   end 
   
   
// =========================================
// Assertions using conditional compilation
// =========================================
`ifdef SIM

    // ===== Reset behavior assertion =====
    property reset_behavior;
		@(posedge fifo_intf.clk) (!fifo_intf.rst_n) |=>  (dut.count == 0 && dut.rd_ptr == 0 && dut.wr_ptr == 0
		             && !fifo_intf.wr_ack && !fifo_intf.overflow  && !fifo_intf.underflow && fifo_intf.data_out <= {FIFO_WIDTH{1'b0}});
    endproperty
    
    // ===== Whenever the FIFO is full, wr_ack is always = 0 =====
    property n_wr_ack_with_FIFO_Full;
                @(posedge clk) disable iff (!fifo_intf.rst_n) (fifo_intf.full |=> !fifo_intf.wr_ack)
    endproperty
    
    // ===== Write acknowledge assertion =====
    property write_ack_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (fifo_intf.wr_en && !fifo_intf.full) |=> fifo_intf.wr_ack;
    endproperty
    
    // ===== Overflow detection assertion =====
    property overflow_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (fifo_intf.wr_en && fifo_intf.full && !fifo_intf.rd_en) |=> fifo_intf.overflow;
    endproperty
    
    // ===== Underflow detection assertion =====
    property underflow_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (fifo_intf.rd_en && fifo_intf.empty) |=> fifo_intf.underflow;
    endproperty
    
    // ===== Empty flag assertion =====
    property empty_flag_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (dut.count == 0) |-> fifo_intf.empty;
    endproperty
    
    // ===== Full flag assertion =====
    property full_flag_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (dut.count == FIFO_DEPTH) |-> fifo_intf.full;
    endproperty
    
    // ===== Almost full condition assertion =====
    property almost_full_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (dut.count == FIFO_DEPTH-1) |-> fifo_intf.almostfull;
    endproperty
    
    // ===== Almost empty condition assertion =====
    property almost_empty_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (dut.count == 1) |-> fifo_intf.almostempty;
    endproperty
    
    // ===== Pointer wraparound assertion for write_ptr =====
    property write_ptr_wraparound;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (fifo_intf.wr_en && !fifo_intf.full && dut.wr_ptr == FIFO_DEPTH-1) |=> (dut.wr_ptr == 0);
    endproperty
    
    // ===== Pointer wraparound assertion for read_ptr =====
    property read_ptr_wraparound;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (fifo_intf.rd_en && !fifo_intf.empty && dut.rd_ptr == FIFO_DEPTH-1) |=> (dut.rd_ptr == 0);
    endproperty
    
    // ===== Pointer threshold assertion for write_ptr =====
    property write_ptr_threshold;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (dut.wr_ptr < FIFO_DEPTH);
    endproperty
    
    // ===== Pointer threshold assertion for read_ptr =====
    property read_ptr_threshold;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (dut.rd_ptr < FIFO_DEPTH);
    endproperty
    
    // ===== Counter threshold assertion =====
    property counter_threshold;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (dut.count <= FIFO_DEPTH);
    endproperty
    
    // ===== Assert all the properties =====
    assert property (reset_behavior)       else $error("Reset behavior assertion failed!");
    assert property (write_ack_check)      else $error("Write acknowledge assertion failed!");
    assert property (overflow_check)       else $error("Overflow detection assertion failed!");
    assert property (underflow_check)      else $error("Underflow detection assertion failed!");
    assert property (empty_flag_check)     else $error("Empty flag assertion failed!");
    assert property (full_flag_check) 	   else $error("Full flag assertion failed!");
    assert property (almost_full_check)    else $error("Almost full condition assertion failed!");
    assert property (almost_empty_check)   else $error("Almost empty condition assertion failed!");
    assert property (write_ptr_wraparound) else $error("Write pointer wraparound assertion failed!");
    assert property (read_ptr_wraparound)  else $error("Read pointer wraparound assertion failed!");
    assert property (write_ptr_threshold)  else $error("Write pointer threshold assertion failed!");
    assert property (read_ptr_threshold)   else $error("Read pointer threshold assertion failed!");
    assert property (counter_threshold)    else $error("Counter threshold assertion failed!");
    assert property (n_wr_ack_with_FIFO_Full) else $error("Dasserted Write Ack With FIFO Full assertion failed!");
	
    cover property (reset_behavior);
    cover property (write_ack_check);
    cover property (overflow_check);
    cover property (underflow_check);
    cover property (empty_flag_check);
    cover property (full_flag_check);
    cover property (almost_full_check);
    cover property (almost_empty_check);
    cover property (write_ptr_wraparound);
    cover property (read_ptr_wraparound);
    cover property (write_ptr_threshold);
    cover property (read_ptr_threshold);
    cover property (counter_threshold);
    cover property (n_wr_ack_with_FIFO_Full);
    
`endif
   
endmodule 
