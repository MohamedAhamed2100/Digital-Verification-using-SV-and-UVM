package Shared_pkg;
	// ===== Global parameter for Signal Declaration =====
	parameter FIFO_WIDTH = 16;
	parameter FIFO_DEPTH = 8;
	
	// ===== Signals For Test Control ======
	// ===== #No of Randomization ======
	parameter TEST_COUNT = 1000;
	// ===== Counter For Failed and Successed Test Transactions ======
	int unsigned error_count = 0;
	int unsigned correct_count = 0;
	// ===== When eq 1 Trim Test =====
	bit test_finished = 0;
endpackage