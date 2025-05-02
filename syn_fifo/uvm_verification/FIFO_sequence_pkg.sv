package FIFO_sequence_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import FIFO_sequence_item_pkg::*;

class FIFO_Sequence extends uvm_sequence #(FIFO_seq_item);
	`uvm_object_utils(FIFO_Sequence)
	FIFO_seq_item item;
	
	function new(string name = "FIFO_Sequence");
		super.new(name);
	endfunction

    virtual task body();	
	item = FIFO_seq_item::type_id::create("item");
         // ===== force reset ====
        item.force_rst_item;
        repeat(5) begin 
        	start_item(item);
		if (!item.randomize())
        		`uvm_error("RAND_FAIL", "Failed to force reset randomize FIFO sequence item");
		finish_item(item);
	end
		
        // ===== simultaneous Read And Write =====
	item.ctrl_seq_item(30,70);
	repeat(1000) begin 
		start_item(item);
		if (!item.randomize())
        		`uvm_error("RAND_FAIL", "Failed to simultaneous Read And Write randomize FIFO sequence item");
		finish_item(item);
	end
	
	// ===== Read only =====
	item.ctrl_seq_item(0,100);
	repeat(100) begin 
		start_item(item);
		if (!item.randomize())
        		`uvm_error("RAND_FAIL", "Failed to Read only randomize FIFO sequence item");
		finish_item(item);
	end 
	
	// ===== Write only =====
	item.ctrl_seq_item(100,0);
	repeat(100) begin 
		start_item(item);
		if (!item.randomize())
        		`uvm_error("RAND_FAIL", "Failed to Write only randomize FIFO sequence item");
		finish_item(item);
	end
	
    endtask
	
endclass 

endpackage


