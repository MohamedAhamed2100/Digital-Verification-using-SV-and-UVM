package FIFO_coverage_pkg;

import FIFO_transaction_pkg::*;
import Shared_pkg::*;

class FIFO_coverage;

	// ===== create object =======
	FIFO_transaction F_cvg_txn;

        // ===== Cover Group =====
	covergroup fifo_cg;
		
		// ====== Cover I/O Ports ======
		rst_n_cp: 	coverpoint F_cvg_txn.rst_n;
		data_in_cp:     coverpoint F_cvg_txn.data_in;
		r_en_cp: 	coverpoint F_cvg_txn.rd_en; 
		w_en_cp: 	coverpoint F_cvg_txn.wr_en;
		data_out_cp:    coverpoint F_cvg_txn.data_out;
		wr_ack_cp:      coverpoint F_cvg_txn.wr_ack;
		overflow_cp:    coverpoint F_cvg_txn.overflow;
		full_cp: 	coverpoint F_cvg_txn.full; 
		empty_cp:       coverpoint F_cvg_txn.empty; 
		almostfull_cp:  coverpoint F_cvg_txn.almostfull; 
		almostempty_cp: coverpoint F_cvg_txn.almostempty;
		underflow_cp:   coverpoint F_cvg_txn.underflow;

		
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
		
		almostfull_cross:  cross r_en_cp ,w_en_cp ,almostfull_cp;
		
		almostempty_cross: cross r_en_cp ,w_en_cp ,almostempty_cp;
		
		
		overflow_cross:    cross r_en_cp ,w_en_cp ,overflow_cp{ 
			ignore_bins w_en_nactv_wr_ack        = binsof(w_en_cp) intersect {1'b0} && binsof(overflow_cp) intersect {1'b1}; 
		}
		
		underflow_cross:   cross r_en_cp ,w_en_cp ,underflow_cp{ 
			ignore_bins r_en_nactv_wr_ack        = binsof(r_en_cp) intersect {1'b0} && binsof(underflow_cp) intersect {1'b1}; 
		}
		
    endgroup
	
	// ====== Constructor ======
    function new();
        fifo_cg = new();
        F_cvg_txn = new();
    endfunction
	
	// ====== Sample Data Method ======
    function void sample_data(FIFO_transaction F_txn);
	F_cvg_txn = F_txn;
	// === Trigger Sampling ===
	fifo_cg.sample();
    endfunction

endclass
endpackage
