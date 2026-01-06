// FSM
typedef enum bit [1:0] {IDLE=2'b00, TRANSFER=2'b01, DONE=2'b10} state_t;

module spi_master #(
    parameter DATA_LENGTH = 8,
    parameter CLK_DIV = 4
    )(
    input logic clk,
    input logic rst_n,

    input  logic [DATA_LENGTH-1:0] data_in,  // data from outside world to send to slave
    output logic [DATA_LENGTH-1:0] data_out, // data from slave to outside world

    input  logic start,
    output logic busy,
    output logic done,

    output logic spi_sck,
    output logic spi_cs_n,
    output logic spi_mosi,
    input  logic spi_miso
);

    // SPI clock generation
    logic [$clog2(CLK_DIV)-1:0] toggle_counter;
    logic spi_sck_toggle;
    logic spi_sck_toggle_prev;
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
        end
    end

    // Detect edges
    logic spi_sck_rising, spi_sck_falling;
    assign spi_sck_rising =   spi_sck_toggle && !spi_sck_toggle_prev;
    assign spi_sck_falling = !spi_sck_toggle &&  spi_sck_toggle_prev;

    // State update
    state_t curr_state, next_state;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    // Next state logic
    logic [$clog2(DATA_LENGTH):0] bit_count; // one extra bit since data is sample on falling edge
    always_comb begin
        case(curr_state)
            IDLE: begin
                if (start)
                    next_state = TRANSFER;
                else
                    next_state = IDLE;
            end
            TRANSFER: begin
                if (bit_count == DATA_LENGTH && spi_sck_falling) // data sampled on falling edge
                    next_state = DONE;
                else
                    next_state = TRANSFER;
            end
            DONE: next_state = IDLE;
            default: next_state = curr_state;
        endcase   
    end

    // Output logic
    logic [DATA_LENGTH-1:0] shift_reg_tx; // holds data to be transmitted to slave
    logic [DATA_LENGTH-1:0] shift_reg_rx; // holds data from slave
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy         <= 0;
            done         <= 0;
            spi_sck      <= 0;
            spi_cs_n     <= 1; // chip select is disabled
            spi_mosi     <='0;
            bit_count    <='0;
            shift_reg_tx <='0;
            shift_reg_rx <='0;
        end else begin
            case(curr_state)
                IDLE: begin
                    busy      <= 0;
                    spi_sck   <= 0;
                    spi_cs_n  <= 1; // chip select is disabled
                    spi_mosi  <='0;
                    bit_count <='0;                   
                    if (start)
                        shift_reg_tx <= data_in; // take data in
                end
                TRANSFER: begin
                    busy <= 1; // master is busy
                    spi_sck <= spi_sck_toggle;
                    spi_cs_n <= 0; // chip select is pulled down
                    // send data to slave over mosi on rising edge
                    if (spi_sck_rising) begin
                        spi_mosi <= shift_reg_tx[DATA_LENGTH-1]; //MSB-first
                        shift_reg_tx <= {shift_reg_tx[DATA_LENGTH-2:0], 1'b0}; // shift left
                        bit_count <= bit_count + 1;
                    end
                    // sample data from slave on falling edge            
                    if (spi_sck_falling) begin
                        shift_reg_rx <= {shift_reg_rx[DATA_LENGTH-2:0], spi_miso}; // MSB-first
                    end
                end
                DONE: begin
                    busy      <= 0;
                    spi_cs_n  <= 1; // chip select is disabled
                    spi_mosi  <='0;
                    bit_count <='0;
                    done      <= 1;
                end
            endcase
        end 
    end

    // match shift register with peripheral
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            data_out <= '0;
        else begin
            if (done) // sample after DONE
                data_out <= shift_reg_rx;
        end
    end

endmodule