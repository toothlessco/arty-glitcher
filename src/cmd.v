/*
 * Copyright (c) 2017, Toothless Consulting UG (haftungsbeschraenkt)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * + Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * + Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 * + Neither the name arty-glitcher nor the names of its contributors may be
 *   used to endorse or promote products derived from this software without
 *   specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE arty-glitcher PROJECT BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
 * Author: Dmitry Nedospasov <dmitry@toothless.co>
 *
 */

module cmd (
    input wire          clk,
    input wire          din,
    output reg          rst = 1'b0,
    output reg          board_rst = 1'b0,
    output reg [7:0]    pulse_width = 8'd0,
    output reg [7:0]    pulse_cnt = 8'd0,
    output reg [63:0]   delay = 64'd0,
    output reg [7:0]    pwm = 8'hff,
    output reg          glitch_en = 1'b0,
    output reg          passthrough = 1'b0,
    output wire         dout
);

parameter [3:0] STATE_IDLE          = 4'd0;
parameter [3:0] STATE_SPECIAL       = 4'd1;
parameter [3:0] STATE_DATA          = 4'd2;
parameter [3:0] STATE_DELAY0        = 4'd3;
parameter [3:0] STATE_DELAY1        = 4'd4;
parameter [3:0] STATE_DELAY2        = 4'd5;
parameter [3:0] STATE_DELAY3        = 4'd6;
parameter [3:0] STATE_DELAY4        = 4'd7;
parameter [3:0] STATE_DELAY5        = 4'd8;
parameter [3:0] STATE_DELAY6        = 4'd9;
parameter [3:0] STATE_DELAY7        = 4'd10;
parameter [3:0] STATE_PULSE_WIDTH   = 4'd11;
parameter [3:0] STATE_PULSE_CNT     = 4'd12;
parameter [3:0] STATE_PWM           = 4'd13;

reg [3:0] state = STATE_IDLE;

wire [7:0] rx_data;
wire rx_valid;

uart_rx rxi (
    .clk(clk),
    .rst(rst),
    .din(din),
    .data_out(rx_data),
    .valid(rx_valid)
);

wire tx_en;
wire [7:0] tx_data;
wire tx_rdy;

uart_tx txi (
    .clk(clk),
    .rst(rst),
    .dout(dout),
    .data_in(tx_data),
    .en(tx_en),
    .rdy(tx_rdy)
);

reg         fifo_en = 1'b0;
reg [7:0]   fifo_data;

fifo fifoi (
    .clk(clk),
    .rst(rst),
    .data_in(fifo_data),
    .wen(fifo_en),
    .ren(tx_rdy),
    .valid(tx_en),
    .data_out(tx_data)
);

reg [7:0]   byte_cnt = 8'd0;

always @(posedge clk)
begin
    rst <= 1'b0;

    if(rst)
    begin
        state <= STATE_IDLE;
        pulse_width <= 8'd0;
        pulse_cnt = 8'd0;
        delay = 64'd0;
        pwm = 8'hff;
        passthrough <= 1'b0;
    end
    else begin
        state <= state;
        glitch_en <= 1'b0;
        byte_cnt <= byte_cnt;
        fifo_data <= fifo_data;
        fifo_en <= 1'b0;
        board_rst <= 1'b0;
        passthrough <= passthrough;

        case(state)
            STATE_IDLE:
            begin
                if(rx_valid)
                begin
                    state <= STATE_DATA;
                    byte_cnt <= rx_data;
                    if(rx_data == 8'd0)
                    begin
                        state <= STATE_SPECIAL;
                    end
                end
            end
            STATE_SPECIAL:
            begin
                if(rx_valid)
                begin
                    state <= STATE_IDLE;
                    case(rx_data)
                        8'd0:
                        begin
                            glitch_en <= 1'b1;
                        end
                        8'h10:
                        begin
                            state <= STATE_PULSE_WIDTH;
                        end
                        8'h11:
                        begin
                            state <= STATE_PULSE_CNT;
                        end
                        8'h20:
                        begin
                            state <= STATE_DELAY0;
                        end
                        8'h21:
                        begin
                            state <= STATE_DELAY1;
                        end
                        8'h22:
                        begin
                            state <= STATE_DELAY2;
                        end
                        8'h23:
                        begin
                            state <= STATE_DELAY3;
                        end
                        8'h24:
                        begin
                            state <= STATE_DELAY4;
                        end
                        8'h25:
                        begin
                            state <= STATE_DELAY5;
                        end
                        8'h26:
                        begin
                            state <= STATE_DELAY6;
                        end
                        8'h27:
                        begin
                            state <= STATE_DELAY7;
                        end
                        8'h40:
                        begin
                            state <= STATE_PWM;
                        end
                        8'hfd:
                        begin
                            passthrough <= 1'b1;
                        end
                        8'hfe:
                        begin
                            board_rst <= 1'b1;
                        end
                        8'hff:
                        begin
                            rst <= 1'b1;
                        end
                    endcase
                end
            end
            STATE_DATA:
            begin
                if(rx_valid)
                begin
                    byte_cnt <= byte_cnt - 1'b1;
                    fifo_en <= 1'b1;
                    fifo_data <= rx_data;

                    if(byte_cnt == 8'd1)
                    begin
                        state <= STATE_IDLE;
                    end
                end
            end
            STATE_DELAY0:   
            begin
                if(rx_valid)
                begin
                    delay[7:0] <= rx_data;
                    state <= STATE_IDLE;
                end
            end
            STATE_DELAY1:   
            begin
                if(rx_valid)
                begin
                    delay[15:8] <= rx_data;
                    state <= STATE_IDLE;
                end
            end
            STATE_DELAY2:   
            begin
                if(rx_valid)
                begin
                    delay[23:16] <= rx_data;
                    state <= STATE_IDLE;
                end
            end
            STATE_DELAY3:   
            begin
                if(rx_valid)
                begin
                    delay[31:24] <= rx_data;
                    state <= STATE_IDLE;
                end
            end
            STATE_DELAY4:   
            begin
                if(rx_valid)
                begin
                    delay[39:32] <= rx_data;
                    state <= STATE_IDLE;
                end
            end
            STATE_DELAY5:   
            begin
                if(rx_valid)
                begin
                    delay[47:40] <= rx_data;
                    state <= STATE_IDLE;
                end
            end
            STATE_DELAY6:   
            begin
                if(rx_valid)
                begin
                    delay[55:48] <= rx_data;
                    state <= STATE_IDLE;
                end
            end
            STATE_DELAY7:   
            begin
                if(rx_valid)
                begin
                    delay[63:56] <= rx_data;
                    state <= STATE_IDLE;
                end
            end
            STATE_PULSE_WIDTH:
            begin
                if(rx_valid)
                begin
                    pulse_width <= rx_data;
                    state <= STATE_IDLE;
                end
            end
            STATE_PULSE_CNT:
            begin
                if(rx_valid)
                begin
                    pulse_cnt <= rx_data;
                    state <= STATE_IDLE;
                end
            end
            STATE_PWM:
            begin
                if(rx_valid)
                begin
                    pwm <= rx_data;
                    state <= STATE_IDLE;
                end
            end
        endcase
    end
end

endmodule
