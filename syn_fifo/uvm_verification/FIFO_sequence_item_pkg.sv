package FIFO_sequence_item_pkg ;

import Shared_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class FIFO_seq_item extends uvm_sequence_item;
    `uvm_object_utils(FIFO_seq_item)

	// ===================================================
	// Transaction Distribution "Set to Default Values" 
	// ===================================================
	int RD_EN_ON_DIST; 
	int WR_EN_ON_DIST;
	
	bit force_rst = 1;

	// ==================
	// Class Constructor 
	// ==================
        function new(string name = "FIFO_seq_item");
		super.new(name);
	endfunction
	
	// ==== input signals ==== 
	rand bit rst_n;
	rand bit [FIFO_WIDTH-1:0] data_in;
	rand bit wr_en;
	rand bit rd_en;
	
	// ==== output signals ====
	bit [FIFO_WIDTH-1:0] data_out;
	bit wr_ack, overflow;
	bit full, empty, almostfull, almostempty, underflow;

        // =====================================================
	// Dassert Reset "Asyn - Active Low" most of the times 
	// =====================================================
        constraint rst_c { 
        	if (!force_rst) {
        	   rst_n dist {0:/10 , 1:/90};
        	}
        	if (force_rst) {
        	   rst_n dist {0:=100, 1:=0};
        	}
         }
         
         constraint data_in_c {          
                data_in dist {0:/15 , {FIFO_WIDTH{1'b1}}:/15 , [1:{FIFO_WIDTH{1'b1}}-1] :/ 70};
         }
	
	// ========================================================
	// Only, Enable Write Enable Signal During "WR_EN_ON_DIST"
	// ========================================================
	constraint wr_en_c { wr_en dist {1 := WR_EN_ON_DIST, 0 := 100-WR_EN_ON_DIST};}
	
	// ========================================================
	// Only, Enable Read Enable Signal During "RD_EN_ON_DIST"
	// ========================================================
	constraint rd_en_c { rd_en dist {1 := RD_EN_ON_DIST, 0 := 100-RD_EN_ON_DIST};}
	
	function void ctrl_seq_item (int rd_dist = 30 ,int wr_dist = 70);
		RD_EN_ON_DIST = rd_dist;
		WR_EN_ON_DIST = wr_dist;
		force_rst = 0;
	endfunction
	
        function void force_rst_item;
		force_rst = 1;
	endfunction
	
endclass
	
endpackage 
