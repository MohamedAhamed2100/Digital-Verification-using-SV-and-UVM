package FIFO_transaction_pkg;

import Shared_pkg::*;

class FIFO_transaction; 
	
	// ===================================================
	// Transaction Distribution "Set to Default Values" 
	// Variable For parametrized Class "Class Signature"
	// ===================================================
	int RD_EN_ON_DIST;  
	int WR_EN_ON_DIST;
	
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
        constraint rst_c { rst_n dist {0:/15 , 1:/85};}
	
	// ========================================================
	// Only, Enable Write Enable Signal During "WR_EN_ON_DIST"
	// ========================================================
	constraint wr_en_c { wr_en dist {1 := WR_EN_ON_DIST, 0 := 100-WR_EN_ON_DIST};}
	
	// ========================================================
	// Only, Enable Read Enable Signal During "RD_EN_ON_DIST"
	// ========================================================
	constraint rd_en_c { rd_en dist {1 := RD_EN_ON_DIST, 0 := 100-RD_EN_ON_DIST};}
	
	// ==================
	// Class Constructor 
	// ==================
	function new (int rd_dist = 30 ,int wr_dist = 70); 
		RD_EN_ON_DIST = rd_dist;
		WR_EN_ON_DIST = wr_dist;
	endfunction
	
endclass 
endpackage 
