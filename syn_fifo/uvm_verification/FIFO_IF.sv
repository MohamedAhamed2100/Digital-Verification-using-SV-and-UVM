
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
				  
	// ==== Task to trigger sampling event ====
        task trigger_sample();
		-> data_sampled;
        endtask		
	
endinterface
