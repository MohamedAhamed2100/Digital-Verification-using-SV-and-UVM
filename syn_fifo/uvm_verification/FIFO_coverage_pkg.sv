package FIFO_coverage_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import FIFO_sequence_item_pkg::*;

class FIFO_coverage extends uvm_component;
	`uvm_component_utils(FIFO_coverage)
	uvm_analysis_export #(FIFO_seq_item) cov_export;
	uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;
	FIFO_seq_item seq_item_cov;

	// ===== Cover Group =====
	covergroup fifo_cg;
		
		// ====== Cover I/O Ports ======
		rst_n_cp: 	coverpoint seq_item_cov.rst_n;
		data_in_cp:     coverpoint seq_item_cov.data_in;
		r_en_cp: 	coverpoint seq_item_cov.rd_en; 
		w_en_cp: 	coverpoint seq_item_cov.wr_en;
		data_out_cp:    coverpoint seq_item_cov.data_out;
		wr_ack_cp:      coverpoint seq_item_cov.wr_ack;
		overflow_cp:    coverpoint seq_item_cov.overflow;
		full_cp: 	coverpoint seq_item_cov.full; 
		empty_cp:       coverpoint seq_item_cov.empty; 
		almostfull_cp:  coverpoint seq_item_cov.almostfull; 
		almostempty_cp: coverpoint seq_item_cov.almostempty;
		underflow_cp:   coverpoint seq_item_cov.underflow;

		
		// ====== "7" Cross Coverage ======
		wr_ack_cross:     cross r_en_cp ,w_en_cp ,wr_ack_cp{ 
			ignore_bins w_en_nactv_wr_ack        = binsof(w_en_cp) intersect {1'b0} && binsof(wr_ack_cp) intersect {1'b1};
		}
		full_cross:        cross r_en_cp ,w_en_cp ,full_cp{ 
			// full not asserted when both read and write enabled
			ignore_bins w_en_r_en_allactv_full   = binsof(w_en_cp) intersect {1'b1} && binsof(r_en_cp) intersect {1'b1} && binsof(full_cp) intersect {1'b1};
			// full not asserted when read enabled
			ignore_bins r_en_actv_wr_full        = binsof(w_en_cp) intersect {1'b0} && binsof(r_en_cp) intersect {1'b1} && binsof(full_cp) intersect {1'b1}; 
		}
		
		empty_cross:       cross r_en_cp ,w_en_cp ,empty_cp{ 
			ignore_bins read_nactv_empty         = binsof(r_en_cp) intersect {1'b0} && binsof(empty_cp) intersect {1'b1};
		}
		
		almostfull_cross:  cross r_en_cp ,w_en_cp ,almostfull_cp{ 
		        // who almostfull with read 
			ignore_bins w_en_nactv_almostfull    = binsof(r_en_cp) intersect {1'b0} && binsof(almostfull_cp) intersect {1'b1}; 
		}
		
		almostempty_cross: cross r_en_cp ,w_en_cp ,almostempty_cp{ 
			// who almostempty with write
			ignore_bins w_en_nactv_almostempty   = binsof(w_en_cp) intersect {1'b0} && binsof(almostempty_cp) intersect {1'b1}; 
		}
		
		overflow_cross:    cross r_en_cp ,w_en_cp ,overflow_cp{ 
			ignore_bins w_en_nactv_wr_ack        = binsof(w_en_cp) intersect {1'b0} && binsof(overflow_cp) intersect {1'b1}; 
		}
		
		underflow_cross:   cross r_en_cp ,w_en_cp ,underflow_cp{ 
			ignore_bins r_en_nactv_wr_ack        = binsof(r_en_cp) intersect {1'b0} && binsof(underflow_cp) intersect {1'b1}; 
		}
		
        endgroup

	
	function new(string name="FIFO_coverage" , uvm_component parent = null);
		super.new(name,parent);
		fifo_cg = new();
	endfunction	

	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		cov_export = new("cov_export",this);
		cov_fifo = new("cov_fifo",this);
	endfunction: build_phase
	
	function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		cov_export.connect(cov_fifo.analysis_export);
	endfunction: connect_phase
	
	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		forever begin			
			cov_fifo.get(seq_item_cov);
			fifo_cg.sample();
		end 
	endtask: run_phase
	
endclass	
endpackage	
