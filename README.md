# SPI master
Verification of Serial Peripheral Interface (SPI) master

| Layer                 | Responsibility                                 |
| --------------------- | ---------------------------------------------- |
| Top TB (`spi_uvm_tb`) | clk, reset, host behavior (`start`, `data_in`) |
| DUT (`spi_master`)    | SPI master protocol                            |
| UVM slave driver      | Drive `miso` reactively                        |
| UVM monitor           | Observe SPI bus                                |
| UVM sequences         | Define slave response behavior                 |



| Top-level TB            |
|                         |
|  - clk generation       |
|  - reset generation     |
|  - host behavior        |
|    * drive data_in      |
|    * pulse start        |
|    * wait for done      |
|                         |

             |
             v

| SPI Master (DUT)        |
|                         |
|  - generates cs_n       |
|  - generates sck        |
|  - drives mosi          |
|  - samples miso         |
|                         |

             |
             v

| UVM SPI Slave Agent     |
|                         |
|  - driver (reactive)    |
|    * drives miso        |
|    * samples mosi       |
|  - monitor              |
|                         |


Legend: \\
project_root/
├── rtl/
│   └── spi_master.sv
├── tb/
│   └── spi_slave_tb.sv        # legacy (keep for reference)
├── uvm/
│   ├── spi_if.sv
│   ├── spi_pkg.sv
│   ├── env/
│   │   ├── spi_env.sv
│   │   └── spi_agent.sv
│   ├── agent/
│   │   ├── spi_driver.sv
│   │   ├── spi_monitor.sv
│   │   ├── spi_sequencer.sv
│   │   └── spi_transaction.sv
│   ├── seq/
│   │   └── spi_basic_seq.sv
│   ├── test/
│   │   └── spi_basic_test.sv
│   └── top/
│       └── spi_uvm_tb.sv



