package FIFO_test_pkg;

import FIFO_env_pkg::*;
import FIFO_config_obj_pkg::*;
import FIFO_sequence_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

	class FIFO_test extends uvm_test;
	   `uvm_component_utils(FIFO_test)

	    FIFO_env env;
	    FIFO_config_obj FIFO_config_obj_test;
	    FIFO_Sequence seq;
	    
	    function new (string name = "FIFO_test", uvm_component parent = null);
			super.new(name,parent);
	    endfunction 
	    
	    function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			env = FIFO_env::type_id::create("env",this);
			FIFO_config_obj_test = FIFO_config_obj::type_id::create("FIFO_config_obj_test",this);
			seq = FIFO_Sequence::type_id::create("seq");
		
			if (!uvm_config_db#(virtual FIFO_IF)::get(this, "", "FIFO_VIF", FIFO_config_obj_test.FIFO_config_vif))
        	            `uvm_fatal("NOVIF", "Virtual interface FIFO_test_vif was not found in the configuration database");
        
			uvm_config_db#(FIFO_config_obj)::set(this,"*","CFG",FIFO_config_obj_test);
	    endfunction
	    
	    task run_phase(uvm_phase phase);
	    	super.run_phase(phase);
	    	phase.raise_objection(this);
	        `uvm_info("run_phase","Inside the FIFO test.",UVM_MEDIUM);
		seq.start(env.agt.sqr);
		phase.drop_objection(this);
	    endtask : run_phase 
		 
	endclass : FIFO_test
	
endpackage	
