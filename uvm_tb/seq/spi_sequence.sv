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
		next_id = 0;
		repeat(5) begin  // Send 5 txnactions
			txn = spi_transaction::type_id::create("txn");
			start_item(txn);
			assert(txn.randomize());
			txn.txn_id = next_id;
			finish_item(txn);
			next_id++;
		end
		
	endtask
endclass
