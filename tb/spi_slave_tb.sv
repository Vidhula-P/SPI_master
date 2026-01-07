class spi_transaction #(int DATA_LENGTH = 8);
    bit [DATA_LENGTH-1:0] tx_data; // data from outside world to send to slave
    bit [DATA_LENGTH-1:0] rx_data; // data from slave to outside world

    function new(bit [7:0] tx_data = 8'h00, bit [7:0] rx_data = 8'h00);
        this.tx_data = tx_data;
        this.rx_data = rx_data;
    endfunction
endclass

module spi_slave_tb;
    parameter DATA_LENGTH = 8;
    parameter CLK_DIV = 4;
    logic clk;
    logic rst_n;
    logic [DATA_LENGTH-1:0] data_in;  // data from outside world to send to slave
    logic [DATA_LENGTH-1:0] data_out; // data from slave to outside world
    logic start;
    logic busy;
    logic done;
    logic spi_sck;
    logic spi_cs_n;
    logic spi_mosi;
    logic spi_miso;

    bit [7:0] data_out_tb;
    spi_transaction #(8) spi_obj;

    spi_master #(.DATA_LENGTH(DATA_LENGTH), .CLK_DIV(CLK_DIV)) s1( .clk(clk), 
    .rst_n(rst_n),
    .data_in(data_in),
    .data_out(data_out),
    .start(start),
    .busy(busy),
    .done(done),
    .spi_sck(spi_sck),
    .spi_cs_n(spi_cs_n),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso) );

    initial clk = 0;
    always #5 clk = ~clk;
    int i;

    initial begin
        $dumpfile("spi_slave_tb.vcd");
        $dumpvars(0, spi_slave_tb);
        spi_obj = new();
        spi_obj.tx_data = 8'hAA;
        spi_obj.rx_data = 8'h66;
        rst_n = 1;
        start = 0;
        spi_miso = 0;
        #1; rst_n = 0;
        #3; rst_n = 1;
        @(posedge clk); #2; // avoid race
        start = 1;
        data_in = spi_obj.tx_data; // master should send "AA" to slave
        $display("Sending to slave: %b", data_in);
        // slave wants to send "66" to master/outside world
        data_out_tb = spi_obj.rx_data;
        wait(!spi_cs_n); start = 0;
        if (!spi_cs_n) begin
            for(i=7; i>=0; i--) begin
                @(posedge spi_sck);
                spi_miso = data_out_tb[i];
                $display("Sending out data_out_tb[%d] = %b", i, spi_miso);
            end
        end
        repeat (200) begin
            @(posedge clk);
            if (done) begin
                @(posedge clk)
                $finish;
            end
        end
        $finish;
    end
endmodule
