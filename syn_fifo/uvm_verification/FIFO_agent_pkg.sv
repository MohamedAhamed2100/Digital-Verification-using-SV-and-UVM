package FIFO_agent_pkg;

import uvm_pkg::*;
import FIFO_sequencer_pkg::*;
import FIFO_driver_pkg::*;
import FIFO_monitor_pkg::*;
import FIFO_config_obj_pkg::*;
import FIFO_sequence_item_pkg::*;
`include "uvm_macros.svh"

class FIFO_agent extends uvm_agent;
	
        `uvm_component_utils(FIFO_agent)
	FIFO_sequencer sqr;
	FIFO_driver drv;
	FIFO_monitor mon;
	FIFO_config_obj FIFO_cfg;
        uvm_analysis_port #(FIFO_seq_item) agt_ap;
	
	function new(string name = "FIFO_agent",uvm_component parent = null);
		super.new(name,parent);
	endfunction 
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(FIFO_config_obj)::get(this,"","CFG",FIFO_cfg))
			`uvm_fatal("build_phase","unable to get configuration object");
		sqr=FIFO_sequencer::type_id::create("sqr",this);
		drv=FIFO_driver::type_id::create("drv",this);
		mon=FIFO_monitor::type_id::create("mon",this);
		agt_ap = new("agt_ap", this);
	endfunction
	
	function void connect_phase(uvm_phase phase);
	        super.connect_phase(phase);
		drv.FIFO_driver_vif=FIFO_cfg.FIFO_config_vif;
		mon.FIFO_vif=FIFO_cfg.FIFO_config_vif;
		drv.seq_item_port.connect(sqr.seq_item_export);
    		mon.mon_ap.connect(agt_ap);
	endfunction

endclass

endpackage
