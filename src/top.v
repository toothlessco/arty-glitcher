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

module top
(
    input wire          clk,
    input wire          ftdi_rx,
    output wire         ftdi_tx,
    input wire          board1_rx,
    output wire         board1_tx,
    output wire         board1_rst,
    output wire         led,
    output wire [13:0]  debug_header,
    output wire         vout
);

// Combinatorial logic
// assign board1_tx = ftdi_rx;
assign ftdi_tx = board1_rx;
assign debug_header = {
    5'd0,
    glitch_en,  // IO8
    vout,       // IO7
    clk,        // IO6
    board1_rst, // IO5
    board1_rx,  // IO4
    board1_tx,  // IO3
    clk,        // IO2
    ftdi_rx,    // IO1
    ftdi_tx     // IO0
};

assign led = vout;

wire        rst;
wire        glitch_en;
wire [7:0]  pulse_width, pulse_cnt;
wire [7:0]  pwm;
wire [63:0] delay;
wire board_rst;
wire passthrough;
wire dout;

assign board1_tx = passthrough ? ftdi_rx : dout;

cmd cmdi (
    .clk(clk),
    .din(ftdi_rx),
    .dout(dout),
    .board_rst(board_rst),
    .rst(rst),
    .pulse_width(pulse_width),
    .pulse_cnt(pulse_cnt),
    .delay(delay),
    .pwm(pwm),
    .glitch_en(glitch_en),
    .passthrough(passthrough)
);

wire pwm_out;

pattern pwmi (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .pattern(pwm),
    .pattern_cnt(8'd0),
    .dout(pwm_out)
);

wire delay_rdy;

delay delayi (
    .clk(clk),
    .rst(rst),
    .en(board_rst || glitch_en),
    .delay(delay),
    .rdy(delay_rdy)
);

wire trigger_valid;

trigger triggeri (
    .clk(clk),
    .rst(rst),
    .en(board_rst || glitch_en),
    .trigger(delay_rdy),
    .valid(trigger_valid)
);

wire pulse_o;
wire pulse_rdy;

pulse pulsei (
    .clk(clk),
    .rst(rst),
    .en(trigger_valid),
    .width_in(pulse_width),
    .cnt_in(pulse_cnt),
    .pulse_o(pulse_o),
    .pulse_rdy(pulse_rdy)
);

resetter rsti (
    .clk(clk),
    .rst(board_rst || rst),
    .rst_out(board1_rst)
);

assign vout = pulse_rdy ? pwm_out : pulse_o;

endmodule
