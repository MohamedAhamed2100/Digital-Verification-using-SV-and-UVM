module FIFO(FIFO_IF.DUT fifo_intf);
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;

localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];  // 1-D Array

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge fifo_intf.clk or negedge fifo_intf.rst_n) begin
	if (!fifo_intf.rst_n) begin
		wr_ptr <= 0;
		fifo_intf.wr_ack <= 0;
		fifo_intf.overflow <= 0;
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
		fifo_intf.underflow <= 0;
		fifo_intf.data_out <= {FIFO_WIDTH{1'b0}};
	end
	else if (fifo_intf.rd_en && count != 0) begin
		fifo_intf.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
	else begin 
		if (fifo_intf.empty & fifo_intf.rd_en)
			fifo_intf.underflow <= 1;
		else
			fifo_intf.underflow <= 0;
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
		else if ( ({fifo_intf.wr_en, fifo_intf.rd_en} == 2'b11) && fifo_intf.full) 
			count <= count - 1;
		else if ( ({fifo_intf.wr_en, fifo_intf.rd_en} == 2'b11) && fifo_intf.empty)
			count <= count + 1;	
	end
end

assign fifo_intf.full = (count == FIFO_DEPTH)? 1 : 0;
assign fifo_intf.empty = (count == 0 || !fifo_intf.rst_n)? 1 : 0;
assign fifo_intf.almostfull = (count == FIFO_DEPTH-1)? 1 : 0; 
assign fifo_intf.almostempty = (count == 1)? 1 : 0;

endmodule
