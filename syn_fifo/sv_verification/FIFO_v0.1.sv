module FIFO(FIFO_IF.DUT fifo_intf);
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;

localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge fifo_intf.clk or negedge fifo_intf.rst_n) begin
	if (!fifo_intf.rst_n) begin
		wr_ptr <= 0;
	end
	else if (fifo_intf.wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= fifo_intf.data_in;
		fifo_intf.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		fifo_intf.wr_ack <= 0; 
		if (fifo_intf.full & fifo_intf.wr_en)
			fifo_intf.overflow <= 1;
		else
			fifo_intf.overflow <= 0;
	end
end

always @(posedge fifo_intf.clk or negedge fifo_intf.rst_n) begin
	if (!fifo_intf.rst_n) begin
		rd_ptr <= 0;
	end
	else if (fifo_intf.rd_en && count != 0) begin
		fifo_intf.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
end

always @(posedge fifo_intf.clk or negedge fifo_intf.rst_n) begin
	if (!fifo_intf.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({fifo_intf.wr_en, fifo_intf.rd_en} == 2'b10) && !fifo_intf.full) 
			count <= count + 1;
		else if ( ({fifo_intf.wr_en, fifo_intf.rd_en} == 2'b01) && !fifo_intf.empty)
			count <= count - 1;
	end
end

assign fifo_intf.full = (count == FIFO_DEPTH)? 1 : 0;
assign fifo_intf.empty = (count == 0)? 1 : 0;
assign fifo_intf.underflow = (fifo_intf.empty && fifo_intf.rd_en)? 1 : 0; 
assign fifo_intf.almostfull = (count == FIFO_DEPTH-2)? 1 : 0; 
assign fifo_intf.almostempty = (count == 1)? 1 : 0;


// =========================================
// Assertions using conditional compilation
// =========================================
`ifdef SIM
    // ===== Reset behavior assertion =====
    property reset_behavior;
		@(posedge fifo_intf.clk) (!fifo_intf.rst_n) |=>  (count == 0 && rd_ptr == 0 && wr_ptr == 0
		             && !fifo_intf.wr_ack && !fifo_intf.overflow  && !fifo_intf.underflow && fifo_intf.data_out <= {FIFO_WIDTH{1'b0}});
    endproperty
    
    // ===== Write acknowledge assertion =====
    property write_ack_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (fifo_intf.wr_en && !fifo_intf.full) |=> fifo_intf.wr_ack;
    endproperty
    
    // ===== Overflow detection assertion =====
    property overflow_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (fifo_intf.wr_en && fifo_intf.full && !fifo_intf.rd_en) |=> fifo_intf.overflow;
    endproperty
    
    // ===== Underflow detection assertion =====
    property underflow_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (fifo_intf.rd_en && fifo_intf.empty) |=> fifo_intf.underflow;
    endproperty
    
    // ===== Empty flag assertion =====
    property empty_flag_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (count == 0) |-> fifo_intf.empty;
    endproperty
    
    // ===== Full flag assertion =====
    property full_flag_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (count == FIFO_DEPTH) |-> fifo_intf.full;
    endproperty
    
    // ===== Almost full condition assertion =====
    property almost_full_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (count == FIFO_DEPTH-1) |-> fifo_intf.almostfull;
    endproperty
    
    // ===== Almost empty condition assertion =====
    property almost_empty_check;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (count == 1) |-> fifo_intf.almostempty;
    endproperty
    
    // ===== Pointer wraparound assertion for write_ptr =====
    property write_ptr_wraparound;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (fifo_intf.wr_en && !fifo_intf.full && wr_ptr == FIFO_DEPTH-1) |=> (wr_ptr == 0);
    endproperty
    
    // ===== Pointer wraparound assertion for read_ptr =====
    property read_ptr_wraparound;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (fifo_intf.rd_en && !fifo_intf.empty && rd_ptr == FIFO_DEPTH-1) |=> (rd_ptr == 0);
    endproperty
    
    // ===== Pointer threshold assertion for write_ptr =====
    property write_ptr_threshold;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (wr_ptr < FIFO_DEPTH);
    endproperty
    
    // ===== Pointer threshold assertion for read_ptr =====
    property read_ptr_threshold;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (rd_ptr < FIFO_DEPTH);
    endproperty
    
    // ===== Counter threshold assertion =====
    property counter_threshold;
		@(posedge fifo_intf.clk)  disable iff (!fifo_intf.rst_n) (count <= FIFO_DEPTH);
    endproperty
    
    // ===== Assert all the properties =====
    assert property (reset_behavior)       else $error("Reset behavior assertion failed!");
    assert property (write_ack_check)      else $error("Write acknowledge assertion failed!");
    assert property (overflow_check)       else $error("Overflow detection assertion failed!");
    assert property (underflow_check)      else $error("Underflow detection assertion failed!");
    assert property (empty_flag_check)     else $error("Empty flag assertion failed!");
    assert property (full_flag_check) 	   else $error("Full flag assertion failed!");
    assert property (almost_full_check)    else $error("Almost full condition assertion failed!");
    assert property (almost_empty_check)   else $error("Almost empty condition assertion failed!");
    assert property (write_ptr_wraparound) else $error("Write pointer wraparound assertion failed!");
    assert property (read_ptr_wraparound)  else $error("Read pointer wraparound assertion failed!");
    assert property (write_ptr_threshold)  else $error("Write pointer threshold assertion failed!");
    assert property (read_ptr_threshold)   else $error("Read pointer threshold assertion failed!");
    assert property (counter_threshold)    else $error("Counter threshold assertion failed!");
	
	cover property (reset_behavior);
	cover property (write_ack_check);
	cover property (overflow_check);
	cover property (underflow_check);
	cover property (empty_flag_check);
	cover property (full_flag_check);
	cover property (almost_full_check);
	cover property (almost_empty_check);
	cover property (write_ptr_wraparound);
	cover property (read_ptr_wraparound);
	cover property (write_ptr_threshold);
	cover property (read_ptr_threshold);
	cover property (counter_threshold);
	
`endif

endmodule
