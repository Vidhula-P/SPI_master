class spi_transaction extends uvm_sequence_item;
	static int counter;
	int unsigned txn_id; // to keep track of the transaction
  	// Declare transaction properties, randomized
	rand bit [DATA_LENGTH-1:0] miso_data; // data from slave (on MISO)
	rand bit [DATA_LENGTH-1:0] mosi_data; // data to slave (on MOSI)

 	 // UVM field automation macros for printing, copying, comparing, etc.
	`uvm_object_utils_begin(spi_transaction)
		`uvm_field_int(txn_id, UVM_ALL_ON)
    	`uvm_field_int(miso_data, UVM_ALL_ON)
    	`uvm_field_int(mosi_data, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "spi_transaction");
		super.new(name);
		txn_id = counter;
		counter++;
	endfunction

	// don't choose zero since it is the "default" value
	constraint tx_no_zero {miso_data != '0;}
	constraint rx_no_zero {mosi_data != '0;}
endclass
