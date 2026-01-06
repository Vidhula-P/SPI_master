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

    initial begin
        $dumpfile("spi_slave_tb.vcd");
        $dumpvars(0, spi_slave_tb);
        rst_n = 1;
        start = 0;
        spi_miso = 0;
        #1; rst_n = 0;
        #3; rst_n = 1;
        @(posedge clk); #2; // avoid race
        start = 1;
        data_in = 8'hAA; // master should send "AA" to slave
        // slave wants to send "66" to master/outside world
        wait(!spi_cs_n);
        if (!spi_cs_n) begin
            @(posedge spi_sck);
            spi_miso = 0;
            @(posedge spi_sck);
            spi_miso = 1;
            @(posedge spi_sck);
            spi_miso = 1; 
            @(posedge spi_sck);
            spi_miso = 0; 
            @(posedge spi_sck);
            spi_miso = 0;
            @(posedge spi_sck);
            spi_miso = 1;
            @(posedge spi_sck);
            spi_miso = 1; 
            @(posedge spi_sck);
            spi_miso = 0; 
        end
        repeat (200) begin
            @(posedge clk);
            if (done)
                $finish;
        end
        $finish;
    end
endmodule