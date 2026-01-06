TOP = spi_slave_tb
OUT = spi_slave_tb.vvp

SRCS = \
  ../rtl/spi_master.sv \
  ../tb/spi_slave_tb.sv

$(OUT): $(SRCS)
	iverilog -g2012 -o $(OUT) $(SRCS)

run: $(OUT)
	vvp $(OUT)

clean:
	rm -f $(OUT)