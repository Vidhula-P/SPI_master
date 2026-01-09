// Interface between SPI master and slave

interface spi_bus_if;
    logic spi_sck;
    logic spi_cs_n;
    logic spi_mosi;
    logic spi_miso;
endinterface
