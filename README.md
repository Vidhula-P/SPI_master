# SPI master
Verification of Serial Peripheral Interface (SPI) master

+-----------------------+------------------------------------------------+
| Layer                 | Responsibility                                 |
| --------------------- + ---------------------------------------------- |
| Top TB (`spi_uvm_tb`) | clk, reset, host behavior (start, data_in)     |
| DUT (`spi_master`)    | SPI master protocol                            |
| UVM slave driver      | Drive miso actively, passive for mosi          |
| UVM monitor           | Observe SPI bus                                |
| UVM sequences         | Define slave response behavior                 |
+-----------------------+------------------------------------------------+
