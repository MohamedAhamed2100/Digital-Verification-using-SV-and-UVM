
import Shared_pkg::*;

interface FIFO_IF (input logic clk);

	// ==== For testing synchronization ====
	event data_sampled;

        //========= signals Declartion =========
	logic [FIFO_WIDTH-1:0] data_in;
	logic rst_n, wr_en, rd_en;
	
	logic [FIFO_WIDTH-1:0] data_out;
	logic wr_ack, overflow;
	logic full, empty, almostfull, almostempty, underflow;

        //======== modpots =========
	modport DUT ( input  data_in, clk, rst_n, wr_en, rd_en
		    , output data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow);

	modport TB  ( input  data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow
		    , output data_in, clk, rst_n, wr_en, rd_en, import trigger_sample);
	
	modport MON ( input data_in, clk, rst_n, wr_en, rd_en, data_out, full, empty, almostfull, almostempty, 
	              overflow, underflow, wr_ack, import trigger_sample);
				  
	// ==== Task to trigger sampling event ====
        task trigger_sample();
		-> data_sampled;
        endtask		
	
endinterface
