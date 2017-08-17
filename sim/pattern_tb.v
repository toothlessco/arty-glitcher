module pattern_tb();

reg tb_clk = 1'b1;
reg tb_en = 1'b0;
reg tb_rst = 1'b0;
reg [7:0] tb_data = 8'h55;

wire rdy;

pattern tb_pattern (
    .clk(tb_clk),
    .rst(tb_rst),
    .en(tb_en),
    .pattern(tb_data),
    .pattern_cnt(8'd0),
    .rdy(rdy)
);

always
begin
    #5 tb_clk <= ~tb_clk;
end

initial
begin
    #200 tb_rst <= 1'b1;
    #10 tb_rst <= 1'b0;
    #100 tb_en <= 1'b1;
    #10 tb_en <= 1'b0;
    @(posedge tb_clk);
    wait(rdy);
    @(posedge tb_clk);
    tb_en <= 1'b1;
    tb_data <= 8'haa;
    @(posedge tb_clk);
    tb_en <= 1'b0;
end

endmodule