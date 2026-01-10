// create parent class that will be inherited by all sequences
class spi_sequence extends uvm_sequence #(spi_transaction);
	`uvm_object_utils(spi_sequence)
	`uvm_declare_p_sequencer(spi_sequencer)

	function new (string name = "spi_sequence");
		super.new(name);
	endfunction

	virtual task body();
		spi_transaction trans = spi_transaction::type_id::create("txn");
		repeat(10) begin  // Send 10 transactions
			trans = spi_transaction::type_id::create("trans");
			start_item(trans);
			assert(trans.randomize());
			finish_item(trans);
		end
	endtask
endclass
