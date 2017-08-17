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

module pattern (
    input wire          clk,
    input wire          rst,
    input wire          en,
    input wire [7:0]    pattern,
    input wire [7:0]    pattern_cnt,
    output reg          dout = 1'b1,
    output reg          rdy = 1'b1
);

parameter STATE_IDLE = 1'b0;
parameter STATE_RUN = 1'b1;

reg state = STATE_IDLE;

reg [7:0] cnt;
reg [7:0] data;

reg [2:0] bit_cnt;
reg [7:0] byte_cnt;

always @(posedge clk) begin
    if (rst)
    begin
        // reset
        state <= STATE_IDLE;
        rdy <= 1'b1;
    end
    else
    begin
        state <= state;
        cnt <= cnt;
        data <= data;
        bit_cnt <= bit_cnt;
        dout <= dout;
        rdy <= rdy;

        case(state)
            STATE_IDLE:
            begin
                dout <= 1'b1;
                if(en)
                begin
                    data <= pattern;
                    cnt <= pattern_cnt;
                    bit_cnt <= 3'd0;
                    byte_cnt <= 8'd0;
                    state <= STATE_RUN;
                    rdy <= 1'b0;
                end
            end
            STATE_RUN:
            begin
                bit_cnt <= bit_cnt + 1'b1;
                data <= {data[0], data[7:1]};
                dout <= data[0];

                if(bit_cnt == 3'd7)
                begin
                    byte_cnt <= byte_cnt + 1'b1;
                    bit_cnt <= 8'd0;
                    if(byte_cnt == cnt)
                    begin
                        state <= STATE_IDLE;
                        rdy <= 1'b1;
                    end
                end
            end
        endcase
    end
end

endmodule
