module top_tb();

reg tb_clk = 1'b1;

always
begin
    #5 tb_clk <= ~tb_clk;
end

wire tb_uart;

top tb_top (
    .clk(tb_clk),
    .ftdi_rx(tb_uart)
);

reg [7:0] tx_data;
reg tx_en = 1'b0;
wire tx_rdy;

uart_tx txi (
    .clk(tb_clk),
    .rst(1'b0),
    .dout(tb_uart),
    .data_in(tx_data),
    .en(tx_en),
    .rdy(tx_rdy)
);

initial
begin
    #1000;
    @(posedge tb_clk);
    tx_data <= 8'h00;
    tx_en <= 1'b1;
    @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
    wait(tx_rdy);
    @(posedge tb_clk);
    tx_data <= 8'hff;
    tx_en <= 1'b1;
    @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
    wait(tx_rdy);

    // Check rst ok
    #1000
    @(posedge tb_clk);
    tx_data <= 8'd5;
    tx_en <= 1'b1;
    @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
    wait(tx_rdy);

    @(posedge tb_clk);
    tx_data <= 8'hff;
    tx_en <= 1'b1;
    @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
    wait(tx_rdy);
    @(posedge tb_clk);
    tx_data <= 8'h55;
    tx_en <= 1'b1;
    @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
    wait(tx_rdy);
    @(posedge tb_clk);
    tx_data <= 8'h00;
    tx_en <= 1'b1;
    @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
    wait(tx_rdy);
    @(posedge tb_clk);
    tx_data <= 8'haa;
    tx_en <= 1'b1;
    @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
    wait(tx_rdy);
    @(posedge tb_clk);
    tx_data <= 8'h00;
    tx_en <= 1'b1;
    @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
    wait(tx_rdy);

    $stop;
    @(posedge tb_clk);
    tx_data <= 8'h00;
    tx_en <= 1'b1;
    @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
    wait(tx_rdy);
    @(posedge tb_clk);
    tx_data <= 8'h00;
    tx_en <= 1'b1;
    @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
    wait(tx_rdy);
    $stop;

    // Send data ok

    // #100000;
    // @(posedge tb_clk);
    // tx_data <= 8'h00;
    // tx_en <= 1'b1;
    // @(posedge tb_clk);
    // tx_en <= 1'b0;
    // wait(!tx_rdy);
    // @(posedge tb_clk);
    // wait(tx_rdy);
    // @(posedge tb_clk);
    // tx_data <= 8'h10;
    // tx_en <= 1'b1;
    // @(posedge tb_clk);
    // tx_en <= 1'b0;
    // wait(!tx_rdy);
    // @(posedge tb_clk);
    // wait(tx_rdy);
    // @(posedge tb_clk);
    // tx_data <= 8'haa;
    // tx_en <= 1'b1;
    // @(posedge tb_clk);
    // tx_en <= 1'b0;
    // wait(!tx_rdy);
    // @(posedge tb_clk);

    // Set pattern ok

    // #100000;
    // @(posedge tb_clk);
    // tx_data <= 8'h00;
    // tx_en <= 1'b1;
    // @(posedge tb_clk);
    // tx_en <= 1'b0;
    // wait(!tx_rdy);<
    // @(posedge tb_clk);
    // wait(tx_rdy);
    // @(posedge tb_clk);
    // tx_data <= 8'h11;
    // tx_en <= 1'b1;
    // @(posedge tb_clk);
    // tx_en <= 1'b0;
    // wait(!tx_rdy);
    // @(posedge tb_clk);
    // wait(tx_rdy);
    // @(posedge tb_clk);
    // tx_data <= 8'h55;
    // tx_en <= 1'b1;
    // @(posedge tb_clk);
    // tx_en <= 1'b0;
    // wait(!tx_rdy);
    // @(posedge tb_clk);

    // Set pattern ok
end

endmodule