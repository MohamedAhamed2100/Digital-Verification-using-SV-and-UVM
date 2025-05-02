package FIFO_scoreboard_pkg;

import Shared_pkg::*;
import FIFO_sequence_item_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class FIFO_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(FIFO_scoreboard)

  uvm_analysis_export#(FIFO_seq_item) sb_export;
  uvm_tlm_analysis_fifo # (FIFO_seq_item) sb_fifo;
  FIFO_seq_item seq_item_sb;
  
  // Constructor
  function new(string name = "FIFO_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase: create export and FIFO
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb_export = new("sb_export", this);
    sb_fifo   = new("sb_fifo",   this);
  endfunction

  // Connect phase: bind export into FIFO
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sb_export.connect(sb_fifo.analysis_export);
  endfunction

  // Run phase: fetch, compute golden, compare, count
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      sb_fifo.get(seq_item_sb);
      check_data(seq_item_sb);
    end
  endtask

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

    // ========= Reference model to calculate expected outputs =========
    function void reference_model(FIFO_seq_item seq_item_chk);
    
		// ========= Capture input ========= 
		last_data_in = seq_item_chk.data_in;

		// ========= Handle reset: clear pointers, count, memory, and outputs =========
		if (seq_item_chk.rst_n == 0) begin
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
		        if (seq_item_chk.wr_en && count < FIFO_DEPTH) begin
				FIFO.push_back(last_data_in);
				write_ptr = write_ptr + 'b1;
				wr_ack_ref = 1'b1; 
		       end else begin
		                wr_ack_ref = 1'b0; 
		                if (seq_item_chk.wr_en && count == FIFO_DEPTH) begin
					// overflow when full
					overflow_ref = 1'b1;
				end else begin
					overflow_ref = 1'b0;
				end
		        end  
		        
		        // Case: Read Enable
		        if (seq_item_chk.rd_en && count != 0) begin
				  data_out_ref = FIFO.pop_front();
				  read_ptr = read_ptr + 'b1 ;
			end else begin
			        if (seq_item_chk.rd_en && count == 0) begin
				      // underflow when empty
				      underflow_ref = 1'b1;
				end else begin
				      underflow_ref = 1'b0;
				end
			end 	
			
			// Case: write Enable and not Full
			if (!seq_item_chk.rd_en && seq_item_chk.wr_en && !full_ref) begin			     
		                count++;
		        // Case: Read Enable and not Empty
		        end else if (seq_item_chk.rd_en && !seq_item_chk.wr_en && !empty_ref) begin		            
			        count--;
			// Case: simultaneous read & write
			end else if (seq_item_chk.wr_en && seq_item_chk.rd_en && empty_ref) begin
			        // empty: only write
				count++;
			end else if (seq_item_chk.wr_en && seq_item_chk.rd_en && full_ref) begin
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
    function void check_data(FIFO_seq_item seq_item_chk);
	       
	       // ====== Compute expected ======
		reference_model(seq_item_chk);

		// ====== Compare ======
		// === Use Force Equality ===		
		if (seq_item_chk.data_out   === data_out_ref   &&
		    seq_item_chk.wr_ack     === wr_ack_ref     &&
		    seq_item_chk.overflow   === overflow_ref   &&
		    seq_item_chk.underflow  === underflow_ref  &&
		    seq_item_chk.full       === full_ref       &&
	            seq_item_chk.empty      === empty_ref      &&
		    seq_item_chk.almostfull === almostfull_ref &&
	            seq_item_chk.almostempty=== almostempty_ref) begin
	            correct_count++;
		end else begin
	            error_count++;
	            `uvm_error("ERROR",$sformatf("ERROR at time %0t:", $time));
	            if (seq_item_chk.data_out   !== data_out_ref)    `uvm_error("ERROR",$sformatf("  data_out   : Exp=%h, Got=%h", data_out_ref, seq_item_chk.data_out));          
	            if (seq_item_chk.wr_ack     !== wr_ack_ref)      `uvm_error("ERROR",$sformatf("  wr_ack     : Exp=%b, Got=%b", wr_ack_ref, seq_item_chk.wr_ack));
	            if (seq_item_chk.overflow   !== overflow_ref)    `uvm_error("ERROR",$sformatf("  overflow   : Exp=%b, Got=%b", overflow_ref, seq_item_chk.overflow));
	            if (seq_item_chk.underflow  !== underflow_ref)   `uvm_error("ERROR",$sformatf("  underflow  : Exp=%b, Got=%b", underflow_ref, seq_item_chk.underflow));
	            if (seq_item_chk.full       !== full_ref)        `uvm_error("ERROR",$sformatf("  full       : Exp=%b, Got=%b", full_ref, seq_item_chk.full));
	            if (seq_item_chk.empty      !== empty_ref)       `uvm_error("ERROR",$sformatf("  empty      : Exp=%b, Got=%b", empty_ref, seq_item_chk.empty));
	            if (seq_item_chk.almostfull !== almostfull_ref)  `uvm_error("ERROR",$sformatf("  almostfull : Exp=%b, Got=%b", almostfull_ref, seq_item_chk.almostfull));
	            if (seq_item_chk.almostempty!== almostempty_ref) `uvm_error("ERROR",$sformatf("  almostempty: Exp=%b, Got=%b", almostempty_ref, seq_item_chk.almostempty));
		end
    endfunction

  // Report phase: summary
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    // Display test summary
    `uvm_info("REPORT",$sformatf("Test Summary:"),UVM_MEDIUM);
    `uvm_info("REPORT",$sformatf("Total correct transactions: %0d", correct_count),UVM_MEDIUM);
    `uvm_info("REPORT",$sformatf("Total mismatches: %0d", error_count),UVM_MEDIUM);
  endfunction

endclass

endpackage

