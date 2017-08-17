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

module trigger (
    input wire clk,
    input wire rst,
    input wire en,
    input wire trigger,
    output reg valid = 1'b0
);

parameter STATE_IDLE = 1'b0;
parameter STATE_RUN = 1'b1;

reg state = STATE_IDLE;

always @(posedge clk)
begin
    if (rst) begin
        // reset
        state <= STATE_IDLE;
    end
    else
    begin
        state <= state;
        valid <= 1'b0;
        case(state)
            STATE_IDLE:
            begin
                if(en)
                begin
                    state <= STATE_RUN;
                end
            end
            STATE_RUN:
            begin
                if(trigger)
                begin
                    state <= STATE_IDLE;
                    valid <= 1'b1;
                end
            end
        endcase
    end
end

endmodule
