# SPI master
Verification of Serial Peripheral Interface (SPI) master

| Layer                 | Responsibility                                 |
| --------------------- | ---------------------------------------------- |
| Top TB (`spi_uvm_tb`) | clk, reset, host behavior (`start`, `data_in`) |
| DUT (`spi_master`)    | SPI master protocol                            |
| UVM slave driver      | Drive `miso` reactively                        |
| UVM monitor           | Observe SPI bus                                |
| UVM sequences         | Define slave response behavior                 |


+-------------------------+
| Top-level TB            |
|                         |
|  - clk generation       |
|  - reset generation     |
|  - host behavior        |
|    * drive data_in      |
|    * pulse start        |
|    * wait for done      |
|                         |
+------------+------------+
             |
             v
+-------------------------+
| SPI Master (DUT)        |
|                         |
|  - generates cs_n       |
|  - generates sck        |
|  - drives mosi          |
|  - samples miso         |
|                         |
+------------+------------+
             |
             v
+-------------------------+
| UVM SPI Slave Agent     |
|                         |
|  - driver (reactive)    |
|    * drives miso        |
|    * samples mosi       |
|  - monitor              |
|                         |
+-------------------------+

