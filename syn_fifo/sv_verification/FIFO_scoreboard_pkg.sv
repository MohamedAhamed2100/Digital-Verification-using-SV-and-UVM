package FIFO_scoreboard_pkg;

  import FIFO_transaction_pkg::*;
  import Shared_pkg::*;

  class FIFO_scoreboard;
    // ========= Reference Model Signals ========= 
    bit [FIFO_WIDTH-1:0] data_out_ref;
    bit wr_ack_ref, overflow_ref;
    bit full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

    // ===== #No Of Location In FIFO =====
    localparam max_fifo_addr = $clog2(FIFO_DEPTH);   

    // ========= Internal FIFO model =========
    bit [FIFO_WIDTH-1:0] FIFO [$];  // FIFO == Queue "first in - first out"
    bit [max_fifo_addr-1:0] write_ptr;
    bit [max_fifo_addr-1:0] read_ptr;
    int count;
    bit [FIFO_WIDTH-1:0] last_data_in;
    
    // ======== Create object =========
    FIFO_transaction F_txn = new();

    // ========= Reference model to calculate expected outputs =========
    function void reference_model(FIFO_transaction F_txn);
		// ========= Capture input ========= 
		last_data_in = F_txn.data_in;

		// ========= Handle reset: clear pointers, count, memory, and outputs =========
		if (F_txn.rst_n == 0) begin
			write_ptr      = 'b0;
			read_ptr       = 'b0;
			count          = 0;
			data_out_ref   = 'b0;
			wr_ack_ref     = 0;
			overflow_ref   = 0;
			underflow_ref  = 0;
			full_ref       = 0;
			empty_ref      = 1;
			almostfull_ref = 0;
			almostempty_ref= 0;
			FIFO.delete();		
               end else begin 

			// ===== Default outputs for non-reset =====
			//overflow_ref   = 0;
			//underflow_ref  = 0;

		        // Case: Write Enable
		        if (F_txn.wr_en && count < FIFO_DEPTH) begin
				FIFO.push_back(last_data_in);
				write_ptr = write_ptr + 'b1;
				wr_ack_ref = 1'b1; 
		       end else begin
		                wr_ack_ref = 1'b0; 
		                if (F_txn.wr_en && count == FIFO_DEPTH) begin
					// overflow when full
					overflow_ref = 1'b1;
				end else begin
					overflow_ref = 1'b0;
				end
		        end  
		        
		        // Case: Read Enable
		        if (F_txn.rd_en && count != 0) begin
				  data_out_ref = FIFO.pop_front();
				  read_ptr = read_ptr + 'b1 ;
			end else begin
			        if (F_txn.rd_en && count == 0) begin
				      // underflow when empty
				      underflow_ref = 1'b1;
				end else begin
				      underflow_ref = 1'b0;
				end
			end 	
			
			// Case: write Enable and not Full
			if (!F_txn.rd_en && F_txn.wr_en && !full_ref) begin			     
		                count++;
		        // Case: Read Enable and not Empty
		        end else if (F_txn.rd_en && !F_txn.wr_en && !empty_ref) begin		            
			        count--;
			// Case: simultaneous read & write
			end else if (F_txn.wr_en && F_txn.rd_en && empty_ref) begin
			        // empty: only write
				count++;
			end else if (F_txn.wr_en && F_txn.rd_en && full_ref) begin
				// full: only read
				 count--;
		        end   
	         end       

        // ===== Update status flags =====
        empty_ref      = (count == 0);
        full_ref       = (count == FIFO_DEPTH);
        almostfull_ref = (count == FIFO_DEPTH-1);
        almostempty_ref= (count == 1);
    endfunction

    // ====== Function to check data by comparing actual outputs with reference model ======
    function void check_data(FIFO_transaction F_txn);
	    // ====== Compute expected ======
		reference_model(F_txn);

		// ====== Compare ======
		// === Use Force Equality ===		
		if (F_txn.data_out   === data_out_ref   &&
		    F_txn.wr_ack     === wr_ack_ref     &&
		    F_txn.overflow   === overflow_ref   &&
		    F_txn.underflow  === underflow_ref  &&
		    F_txn.full       === full_ref       &&
	            F_txn.empty      === empty_ref      &&
		    F_txn.almostfull === almostfull_ref &&
	            F_txn.almostempty=== almostempty_ref) begin
	            correct_count++;
		end else begin
	            error_count++;
	            $display("ERROR at time %0t:", $time);
	            if (F_txn.data_out   !== data_out_ref)    $display("  data_out   : Exp=%h, Got=%h", data_out_ref, F_txn.data_out);
	            if (F_txn.wr_ack     !== wr_ack_ref)      $display("  wr_ack     : Exp=%b, Got=%b", wr_ack_ref, F_txn.wr_ack);
	            if (F_txn.overflow   !== overflow_ref)    $display("  overflow   : Exp=%b, Got=%b", overflow_ref, F_txn.overflow);
	            if (F_txn.underflow  !== underflow_ref)   $display("  underflow  : Exp=%b, Got=%b", underflow_ref, F_txn.underflow);
	            if (F_txn.full       !== full_ref)        $display("  full       : Exp=%b, Got=%b", full_ref, F_txn.full);
	            if (F_txn.empty      !== empty_ref)       $display("  empty      : Exp=%b, Got=%b", empty_ref, F_txn.empty);
	            if (F_txn.almostfull !== almostfull_ref)  $display("  almostfull : Exp=%b, Got=%b", almostfull_ref, F_txn.almostfull);
	            if (F_txn.almostempty!== almostempty_ref) $display("  almostempty: Exp=%b, Got=%b", almostempty_ref, F_txn.almostempty);
		end
    endfunction

  endclass

endpackage
