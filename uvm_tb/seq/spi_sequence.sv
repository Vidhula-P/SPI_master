// create parent class that will be inherited by all sequences
class spi_sequence extends uvm_sequence #(spi_transaction);
	`uvm_object_utils(spi_sequence)
	`uvm_declare_p_sequencer(spi_sequencer)

	function new (string name = "spi_sequence");
		super.new(name);
	endfunction

	virtual task body();
		int next_id;
		spi_transaction txn = spi_transaction::type_id::create("txn");
		`uvm_info("SEQ", "Executing spi_sequence", UVM_MEDIUM)
		repeat(5) begin  // Send 5 transactions
			txn = spi_transaction::type_id::create("txn");
			start_item(txn);
			assert(txn.randomize());
			finish_item(txn);
			next_id++;
		end	
	endtask
endclass

class example_seq extends spi_sequence;
	`uvm_object_utils(example_seq)

	function new (string name = "example_seq");
		super.new(name);
	endfunction

	virtual task body();
		int next_id;
		spi_transaction txn = spi_transaction::type_id::create("txn");
		`uvm_info("SEQ", "Executing example_seq", UVM_MEDIUM)
		repeat (2) begin
			txn = spi_transaction::type_id::create("txn");
			start_item(txn);
			txn.tx_data = 8'he5; 
			txn.rx_data = 8'haa;
			finish_item(txn);
			txn = spi_transaction::type_id::create("txn");
			start_item(txn);
			txn.tx_data = 16'h623f;
			txn.rx_data = 16'hcd67;
			finish_item(txn);
			txn = spi_transaction::type_id::create("txn");
			start_item(txn);
			txn.tx_data = 32'h88668866;
			txn.rx_data = 32'h33cc33cc;
			finish_item(txn);
		end
	endtask
endclass

class repeat_seq extends spi_sequence;
	`uvm_object_utils(repeat_seq)

	function new (string name = "repeat_seq");
		super.new(name);
	endfunction

	example_seq ex_seq; // handle for original sequence being nested

	virtual task body();
		`uvm_info("SEQ", "Executing repeat_seq", UVM_MEDIUM)
		repeat(5) begin
			`uvm_do(ex_seq)
		end
	endtask
endclass

class random_seq extends spi_sequence;
	`uvm_object_utils(random_seq)

	function new (string name = "random_seq");
		super.new(name);
	endfunction

	virtual task body();
		int next_id;
		spi_transaction txn = spi_transaction::type_id::create("txn");
		`uvm_info("SEQ", "Executing random_seq", UVM_MEDIUM)
		repeat(100) begin  // Send 100 transactions
			txn = spi_transaction::type_id::create("txn");
			start_item(txn);
			assert(txn.randomize());
			finish_item(txn);
			next_id++;
		end	
	endtask
endclass

class all_ones extends spi_sequence;
	`uvm_object_utils(all_ones)

	function new (string name = "all_ones");
		super.new(name);
	endfunction

	spi_transaction spi_txn;

	virtual task body();
		`uvm_info("SEQ", "Executing all_ones", UVM_MEDIUM)
		repeat(5) begin
			`uvm_do_with(spi_txn, {tx_data == {DATA_LENGTH{1'b1}}; rx_data == {DATA_LENGTH{1'b1}};})
		end
	endtask
endclass

class all_zeroes extends spi_sequence; //should fail assertion
	`uvm_object_utils(all_zeroes)

	function new (string name = "all_zeroes");
		super.new(name);
	endfunction

	spi_transaction spi_txn;

	virtual task body();
		int next_id;
		spi_transaction txn = spi_transaction::type_id::create("txn");
		`uvm_info("SEQ", "Executing all_zeroes", UVM_MEDIUM)
		repeat (3) begin
			txn = spi_transaction::type_id::create("txn");
			txn.tx_no_zero.constraint_mode(0);
			txn.rx_no_zero.constraint_mode(0);
			start_item(txn);
			txn.tx_data = '0; 
			txn.rx_data = '0;
			finish_item(txn);
			next_id++;
		end
	endtask
endclass

class sparse_seq extends spi_sequence;
	// to be filled
endclass

class dense_seq extends spi_sequence;
	// to be filled
endclass

class alternate_seq extends spi_sequence;
	`uvm_object_utils(alternate_seq)

	function new (string name = "alternate_seq");
		super.new(name);
	endfunction

	spi_transaction spi_txn;

	virtual task body();
		`uvm_info("SEQ", "Executing alternate_seq", UVM_MEDIUM)
		repeat(5) begin
			`uvm_do_with(spi_txn, {tx_data == {(DATA_LENGTH>>1){2'b10}}; rx_data == {(DATA_LENGTH>>1){2'b01}};})
		end
	endtask
endclass

class full_seqs extends spi_sequence;
	`uvm_object_utils(full_seqs)

	function new (string name = "full_seqs");
		super.new(name);
	endfunction

	example_seq   ex_seq;
	repeat_seq 	  rep_seq;
	random_seq 	  rand_seq;
	all_ones	  all_1_seq;
	all_zeroes	  all_0_seq;
	alternate_seq alt_seq;

	virtual task body();
		`uvm_info("SEQ", "Executing full_seqs", UVM_MEDIUM)
		`uvm_do(ex_seq)
		`uvm_do(rep_seq)
		`uvm_do(rand_seq)
		`uvm_do(all_1_seq)
		`uvm_do(all_0_seq)
		`uvm_do(alt_seq)
	endtask
endclass
