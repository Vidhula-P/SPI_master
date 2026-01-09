// FSM
typedef enum bit [1:0] {IDLE=2'b00, TRANSFER=2'b01, DONE=2'b10} state_t;

module spi_master #(
    parameter DATA_LENGTH = 8,
    parameter CLK_DIV = 4
    )(

	// CONTROL SIGNALS
    input logic clk,
    input logic rst_n,

    input  logic [DATA_LENGTH-1:0] data_in,  // data from CPU
    output logic [DATA_LENGTH-1:0] data_out, // data to CPU

    input  logic start,
    output logic busy,
    output logic done,

	// BUS SIGNALS (encapsulated in an interface)
	spi_bus_if spiIF
);
	// SPI clock signals
    logic [$clog2(CLK_DIV)-1:0] toggle_counter;
    logic spi_sck_toggle;
    logic spi_sck_toggle_prev;
    logic spi_sck_rising, spi_sck_falling;
	// State variables
    state_t curr_state, next_state;
    logic [$clog2(DATA_LENGTH):0] bit_count; // one extra bit since data is sample on falling edge
	// Shift registers
    logic [DATA_LENGTH-1:0] shift_reg_tx; // holds data to be transmitted to slave
    logic [DATA_LENGTH-1:0] shift_reg_rx; // holds data from slave

    // SPI clock generation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spi_sck_toggle <= 0;
            spi_sck_toggle_prev <= 0;
            toggle_counter <= 0;
        end else if (curr_state == TRANSFER) begin
            spi_sck_toggle_prev <= spi_sck_toggle; // store prev value to check if rising or falling 
            if (toggle_counter == CLK_DIV-1) begin
                spi_sck_toggle <= ~spi_sck_toggle;
                toggle_counter <= 0;               
            end else
                toggle_counter <= toggle_counter + 1;
        end else begin // in other states
            spi_sck_toggle <= 0;
            spi_sck_toggle_prev <= 0;
            toggle_counter <= 0;
        end
    end

    // Detect edges
    assign spi_sck_rising =   spi_sck_toggle && !spi_sck_toggle_prev;
    assign spi_sck_falling = !spi_sck_toggle &&  spi_sck_toggle_prev;

    // State update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    // Next state logic
    always_comb begin
        case(curr_state)
            IDLE: begin
                if (start)
                    next_state = TRANSFER;
                else
                    next_state = IDLE;
            end
            TRANSFER: begin
                if (bit_count == DATA_LENGTH && spi_sck_rising)
                    next_state = DONE;
                else
                    next_state = TRANSFER;
            end
            DONE: next_state = IDLE;
            default: next_state = curr_state;
        endcase   
    end

    // Output logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy         	   <= 0;
            done         	   <= 0;
            spiIF.spi_sck      <= 0;
            spiIF.spi_cs_n     <= 1; // chip select is disabled
            spiIF.spi_mosi     <='0;
            bit_count    	   <='0;
            shift_reg_tx	   <='0;
            shift_reg_rx	   <='0;
            data_out		   <= '0;
        end else begin
            case(curr_state)
                IDLE: begin
                    busy      		<= 0;
                    done      		<= 0;                     
                    spiIF.spi_sck   <= 0;
                    spiIF.spi_cs_n  <= 1; // chip select is disabled
                    spiIF.spi_mosi  <='0;
                    bit_count 		<='0;
                    data_out  		<='0;         
                    if (start) begin
                        shift_reg_tx <= data_in; // take data in
                        spiIF.spi_mosi <= data_in[DATA_LENGTH-1]; 
                        // SPI protocol specifies that the first data bit must be present on MOSI 
                        // before the first rising edge of SCK
                    end
                end
                TRANSFER: begin
                    busy <= 1; // master is busy
                    spiIF.spi_sck <= spi_sck_toggle;
                    spiIF.spi_cs_n <= 0; // chip select is pulled down
                    // shift data to slave over mosi on falling edge
                    if (spi_sck_falling) begin
                        spiIF.spi_mosi <= shift_reg_tx[DATA_LENGTH-1]; //MSB-first
                        shift_reg_tx <= {shift_reg_tx[DATA_LENGTH-2:0], 1'b0}; // shift left
                        bit_count <= bit_count + 1;
                    end
                    // sample data from slave on rising edge            
                    if (spi_sck_rising) begin
                        shift_reg_rx <= {shift_reg_rx[DATA_LENGTH-2:0], spiIF.spi_miso}; // MSB-first
                    end
                end
                DONE: begin
                    busy      		<= 0;
                    spiIF.spi_cs_n  <= 1; // chip select is disabled
                    spiIF.spi_mosi  <='0;
                    bit_count 		<='0;
                    done      		<= 1;
                    data_out 		<= shift_reg_rx;
					$strobe("data_in: %h, data_out: %h", data_in, data_out);
                end
            endcase
        end 
    end

endmodule
