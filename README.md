# SPI master
Verification of Serial Peripheral Interface (SPI) master

+-----------------------+------------------------------------------------+<br>
| Layer                 | Responsibility                                 |<br>
| --------------------- + ---------------------------------------------- |<br>
| Top TB (`spi_uvm_tb`) | clk, reset, host behavior (start, data_in)     |<br>
| DUT (`spi_master`)    | SPI master protocol                            |<br>
| UVM slave driver      | Drive miso actively, passive for mosi          |<br>
| UVM monitor           | Observe SPI bus                                |<br>
| UVM sequences         | Define slave response behavior                 |<br>
+-----------------------+------------------------------------------------+<br>
