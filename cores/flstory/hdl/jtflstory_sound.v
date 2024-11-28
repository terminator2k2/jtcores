/*  This file is part of JTCORES.
    JTCORES program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTCORES program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTCORES.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 25-11-2024 */

module jtflstory_sound(
    input            rst,
    input            clk,
    input            cen4,
    input            cen2,

    // communication with the other CPUs
    input      [7:0] bus_dout,
    input            bus_wr,
    input            bus_rd,
    input            bus_cs,
    input            bus_a0,
    output reg [7:0] bus_din,

    output    [15:0] rom_addr,
    input     [ 7:0] rom_data,
    input            rom_ok,
    output reg       rom_cs,

    // sound output
    output    [ 9:0] psg,
    input     [ 7:0] debug_bus
);
`ifndef NOSOUND
wire [15:0] A;
wire [ 7:0] ram_dout, cpu_dout, ay_dout;
wire        irq_ack, int_n;
reg  [ 7:0] ibuf, obuf, blatch;       // input/output buffers
reg  [ 3:0] msm_trebble, msm_bass, msm_vol, msm_bal;
wire [ 3:0] psg_trebble, psg_bass, psg_vol, psg_bal;
reg  [13:0] int_cnt;
reg         rom_cs, ram_cs, bdir, bc1, gtwr, cfg0, cfg1,
            cmd_rd, cmd_st, cmd_lr, cmd_wr, nmi_n,
            nmi_sen, nmi_sdi, cmd_lw, amute,
            ibf, obf, rst_n, crst_n;    // ibf = input buffer full

assign rom_addr = A[15:0];
assign irq_ack  = !iorq_n && !m1_n;
assign int_n    = ~int_cnt[13];

always @(posedge clk) begin
    if( cen2 ) int_cnt <= int_cnt+14'd1;
    if( irq_ack ) int_cnt[13] = 0;
end

always @(posedge clk) begin
    if( rst ) begin
        { msm_trebble, msm_bass, msm_vol, msm_bal } <= 0;
    end else begin
        if(cfg0) {msm_vol,   msm_bal  } <= cpu_dout;
        if(cfg1) {msm_trebble,msm_bass} <= cpu_dout;
    end
end

always @(posedge clk) begin
    crst_n <= ~(rst | ~rst_n);
    if( rst ) rst_n <= 1;
    if( rst || !rst_n ) begin
        bus_din <= 0;
        ibf     <= 0;
        obf     <= 0;
        nmi_n   <= 1;
        nmi_en  <= 0;
        amute   <= 0;
    end else begin
        // access from the main bus to the sound subsystem
        bus_dout <= bus_a0 ? {6'd0,obf,ibf} : obuf;
        if( !bus_a0 && bus_cs && bus_wr ) {nmi_n,ibf,ibuf} <= {~nmi_en,1'b1,bus_dout};
        if(  bus_a0 && bus_cs && bus_wr ) rst_n <= ~bus_dout[0];
        if( !bus_a0 && bus_cs && bus_rd ) obf <= 0;
        // sound subsystem
        if( nmi_sen ) { nmi_en, amute } <= {1'b1,cpu_dout[7]};
        if( nmi_sdi ) nmi_en <= 0;
        if( cmd_wr  ) {obf,obuf} <= {1'b1,cpu_dout};
        if( cmd_rd  ) ibuf <= 0;
        if( cmd_lw  ) blatch <= cpu_dout;
    end
end

always @* begin
    rom_cs  = 0;
    ram_cs  = 0;
    bdir    = 0;
    bc1     = 0;
    gtwr    = 0;
    dac0    = 0;
    dac1    = 0;
    cmd_rd  = 0;
    cmd_st  = 0;
    cmd_lr  = 0;
    cmd_wr  = 0;
    nmi_sen = 0;
    nmi_sdi = 0;
    cmd_lw  = 0;
    if( !mreq ) case(A[15:13])
        0,1,2,3,4,5: rom_cs = 1;
        6: case(A[12:11])
            0: ram_cs = 1;
            1: if(!wr_n) case(A[10:9]) // sound chips
                0: begin
                    bdir = 1;
                    bc1  = !A[0];
                end
                1: gtwr = 1;
                2: cfg0 = 1;
                3: cfg1 = 1;
            endcase
            3: begin
                if(!rd_n) case(A[10:9]) // communication
                    0: cmd_rd = 1;
                    1: cmd_st = 1;
                    3: cmd_lr = 1;
                    default:;
                endcase
                if(!wr_n) case(A[10:9]) // communication
                    0: cmd_wr  = 1;
                    1: nmi_sen = 1;     // enable NMI
                    2: nmi_sdi = 1;     // disable NMI
                    3: cmd_lw  = 1;
                endcase
            endcase
            default:;
        endcase
        default:;
    endcase
end

always @* begin
    din = rom_cs ? rom_data       :
          ram_cs ? ram_dout       :
          cmd_rd ? ibuf           :
          cmd_st ? {6'd0,obf,ibf} :
          cmd_lr ? blatch         :
          bc1    ? ay_dout        :
end

jtframe_sysz80 #(.RAM_AW(11)) u_cpu(
    .rst_n      ( crst_n      ),
    .clk        ( clk         ),
    .cen        ( cen4        ),
    .cpu_cen    (             ),
    .int_n      ( int_n       ),
    .nmi_n      ( nmi_n       ),
    .busrq_n    ( 1'b1        ),
    .m1_n       (             ),
    .mreq_n     ( mreq_n      ),
    .iorq_n     ( iorq_n      ),
    .rd_n       ( rd_n        ),
    .wr_n       ( wr_n        ),
    .rfsh_n     (             ),
    .halt_n     (             ),
    .busak_n    (             ),
    .A          ( A           ),
    .cpu_din    ( din         ),
    .cpu_dout   ( cpu_dout    ),
    .ram_dout   ( ram_dout    ),
    // ROM access
    .ram_cs     ( ram_cs      ),
    .rom_cs     ( rom_cs      ),
    .rom_ok     ( rom_ok      )
);

jt49_bus u_ay0(
    .rst_n  ( crst_n    ),
    .clk    ( clk       ),
    .clk_en ( cen2      ),
    .bdir   ( bdir      ),
    .bc1    ( bc1       ),
    .din    ( cpu_dout  ),
    .sel    ( 1'b1      ),
    .dout   ( ay_dout   ),
    .sound  ( psg       ),
    .sample (           ),
    // unused
    .IOA_in ( 8'h0      ),
    .IOA_out(           ),
    .IOA_oe (           ),
    .IOB_in ( 8'h0      ),
    .IOB_out(           ),
    .IOB_oe (           ),
    .A(), .B(), .C() // unused outputs
);
`else
initial bus_din  = 0;
initial rom_cs   = 0;
assign  rom_addr = 0;
assign  psg      = 0;
`endif
endmodule