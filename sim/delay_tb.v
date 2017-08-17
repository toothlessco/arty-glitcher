module delay_tb();

reg tb_clk = 1'b1;
reg tb_en = 1'b0;

delay tb_delay (
    .clk(tb_clk),
    .rst(1'b0),
    .en(tb_en),
    .delay(8'd99)
);

always
begin
    #5 tb_clk <= ~tb_clk;
end

initial
begin
    #100 tb_en <= 1'b1;
    #10 tb_en <= 1'b0;
end

endmodule