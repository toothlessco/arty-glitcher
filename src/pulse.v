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

module pulse(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [7:0] width_in,
    input wire [7:0] cnt_in,
    output reg pulse_o = 1'b1,
    output reg pulse_rdy = 1'b1
);

parameter STATE_IDLE = 1'b0;
parameter STATE_RUN = 1'b1;

reg state = STATE_IDLE;

reg [7:0] width_data;
reg [7:0] width;
reg [7:0] cnt_data;
reg [7:0] cnt;

always @(posedge clk) begin
    if (rst)
    begin
        pulse_o <= 1'b1;
        state <= STATE_IDLE;
        pulse_rdy <= 1'b1;
    end
    else
    begin
        pulse_o <= pulse_o;
        state <= state;
        pulse_rdy <= pulse_rdy;
        width_data <= width_data;
        cnt <= cnt;
        cnt_data <= cnt_data;
        width <= width + 1'b1;

        case(state)
            STATE_IDLE:
            begin
                if(en)
                begin
                    state <= STATE_RUN;
                    width_data <= width_in;
                    width <= 8'd0;
                    cnt_data <= cnt_in;
                    cnt <= 8'd0;
                    pulse_o <= 1'b0;
                    pulse_rdy <= 1'b0;
                end
            end
            STATE_RUN:
            begin
                if(width == width_data)
                begin
                    width <= 8'd0;
                    cnt <= cnt + 1'b1;
                    if(cnt == cnt_data)
                    begin
                        state <= STATE_IDLE;
                        pulse_o <= 1'b1;
                        pulse_rdy <= 1'b1;
                    end
                end
            end
        endcase
    end
end

endmodule
