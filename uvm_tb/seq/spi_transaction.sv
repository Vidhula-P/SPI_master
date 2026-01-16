class spi_transaction extends uvm_sequence_item;
	int unsigned txn_id; // to keep track of the transaction
  	// Declare transaction properties, randomized
	rand bit [DATA_LENGTH-1:0] tx_data; // data from slave (on MISO)
	rand bit [DATA_LENGTH-1:0] rx_data; // data to slave (on MISO)

 	 // UVM field automation macros for printing, copying, comparing, etc.
	`uvm_object_utils_begin(spi_transaction)
    	`uvm_field_int(tx_data, UVM_ALL_ON)
    	`uvm_field_int(rx_data, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "spi_transaction");
		super.new(name);
	endfunction

	// don't choose zero since it is the "default" value
	constraint tx_no_zero {tx_data != '0;}
	constraint rx_no_zero {rx_data != '0;}
endclass
