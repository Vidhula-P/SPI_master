// Interface between SPI master and slave

interface spi_bus_if;
    logic spi_sck;
    logic spi_cs_n;
    logic spi_mosi;
    logic spi_miso;

    // clocking blocks for the TB
	clocking spi_cb @(posedge spi_sck); //sample on rising edge
        output spi_cs_n, spi_mosi;
        input spi_miso;
    endclocking
endinterface
