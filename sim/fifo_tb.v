module fifo_tb();

reg tb_clk = 1'b1;
reg tb_rst = 1'b0;
reg tb_wen = 1'b0;
reg tb_ren = 1'b0;

reg tb_data = 8'haa;

fifo tb_fifo (
    .clk(tb_clk),
    .rst(tb_rst),
    .data_in(tb_data),
    .wen(tb_wen),
    .ren(tb_ren)
);
/*
uart_tx tb_tx (
    .clk(tb_clk),
    .rst(tb_rst),
    .data_in(tb_data),
    .en,
    .rdy = 1'b1
);*/


always
begin
    #5 tb_clk <= ~tb_clk;
end

initial
begin
    #100 ;
    @(posedge tb_clk);
    tb_rst <= 1'b1;
    @(posedge tb_clk);
    tb_rst <= 1'b0;
    #100 ;
    @(posedge tb_clk);
    tb_wen <= 1'b1;
    @(posedge tb_clk);
    tb_wen <= 1'b0;
    #100 ;
    @(posedge tb_clk);
    tb_ren <= 1'b1;
    @(posedge tb_clk);
    tb_ren <= 1'b0;
end

endmodule