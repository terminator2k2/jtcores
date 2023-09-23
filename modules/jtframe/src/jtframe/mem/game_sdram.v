// jt{{.Core}}_game_sdram.v is automatically generated by JTFRAME
// Do not modify it
// Do not add it to git

`ifndef JTFRAME_COLORW
`define JTFRAME_COLORW 4
`endif

`ifndef JTFRAME_BUTTONS
`define JTFRAME_BUTTONS 2
`endif

module jt{{.Core}}_game_sdram(
    `include "jtframe_common_ports.inc"
    `include "jtframe_mem_ports.inc"
);

/* verilator lint_off WIDTH */
`ifdef JTFRAME_BA1_START
    localparam [25:0] BA1_START=`JTFRAME_BA1_START;
`endif
`ifdef JTFRAME_BA2_START
    localparam [25:0] BA2_START=`JTFRAME_BA2_START;
`endif
`ifdef JTFRAME_BA3_START
    localparam [25:0] BA3_START=`JTFRAME_BA3_START;
`endif
`ifdef JTFRAME_PROM_START
    localparam [25:0] PROM_START=`JTFRAME_PROM_START;
`endif
/* verilator lint_on WIDTH */

{{ range .Params }}
parameter {{.Name}} = {{ if .Value }}{{.Value}}{{else}}`{{.Name}}{{ end}};
{{- end}}

`ifndef JTFRAME_IOCTL_RD
wire ioctl_ram = 0;
`endif
// Additional ports
{{range .Ports}}wire {{if .MSB}}[{{.MSB}}:{{.LSB}}]{{end}} {{.Name}};
{{end}}
// BRAM buses
{{- range $cnt, $bus:=.BRAM }}
{{ if .Dual_port.Name }}
{{ if not .Dual_port.We }}wire    {{ if eq .Data_width 16 }}[ 1:0]{{else}}      {{end}}{{.Dual_port.Name}}_we; // Dual port for {{.Dual_port.Name}}
{{end}}{{end}}
{{- end}}
// SDRAM buses
{{ range .SDRAM.Banks}}
{{- range .Buses}}
wire {{ addr_range . }} {{.Name}}_addr;
wire {{ data_range . }} {{.Name}}_data;
wire        {{.Name}}_cs, {{.Name}}_ok;
{{- if .Rw }}
wire        {{.Name}}_we;
wire {{ data_range . }} {{.Name}}_din;
wire [ 1:0] {{.Name}}_dsn;
{{end}}{{end}}
{{- end}}
wire        prom_we, header;
wire [21:0] raw_addr, post_addr;
wire [25:0] pre_addr, dwnld_addr;
wire [ 7:0] post_data;
wire [15:0] raw_data;
wire        pass_io;
{{ if .Clocks }}// Clock enable signals{{ end }}
{{- range $k, $v := .Clocks }}
    {{- range $v }}
    {{- range .Outputs }}
wire {{ . }}; {{ end }}{{ end }}{{ end }}
wire gfx8_en, gfx16_en;

assign pass_io = header | ioctl_ram;

jt{{if .Game}}{{.Game}}{{else}}{{.Core}}{{end}}_game u_game(
    .rst        ( rst       ),
    .clk        ( clk       ),
`ifdef JTFRAME_CLK24
    .rst24      ( rst24     ),
    .clk24      ( clk24     ),
`endif
`ifdef JTFRAME_CLK48
    .rst48      ( rst48     ),
    .clk48      ( clk48     ),
`endif
{{- range $k,$v := .Clocks }} {{- range $v}}
    {{- range .Outputs }}
    .{{ . }}    ( {{ . }}    ), {{end}}{{end}}
{{ end }}
    .pxl2_cen       ( pxl2_cen      ),
    .pxl_cen        ( pxl_cen       ),
    .red            ( red           ),
    .green          ( green         ),
    .blue           ( blue          ),
    .LHBL           ( LHBL          ),
    .LVBL           ( LVBL          ),
    .HS             ( HS            ),
    .VS             ( VS            ),
    // cabinet I/O
    .start_button   ( start_button  ),
    .coin_input     ( coin_input    ),
    .joystick1      ( joystick1     ),
    .joystick2      ( joystick2     ),
    `ifdef JTFRAME_4PLAYERS
    .joystick3      ( joystick3     ),
    .joystick4      ( joystick4     ),
    `endif
`ifdef JTFRAME_ANALOG
    .joyana_l1    ( joyana_l1        ),
    .joyana_l2    ( joyana_l2        ),
    `ifdef JTFRAME_ANALOG_DUAL
        .joyana_r1    ( joyana_r1        ),
        .joyana_r2    ( joyana_r2        ),
    `endif
    `ifdef JTFRAME_4PLAYERS
        .joyana_l3( joyana_l3        ),
        .joyana_l4( joyana_l4        ),
        `ifdef JTFRAME_ANALOG_DUAL
            .joyana_r3( joyana_r3        ),
            .joyana_r4( joyana_r4        ),
        `endif
    `endif
`endif
`ifdef JTFRAME_DIAL
    .dial_x         ( dial_x        ),
    .dial_y         ( dial_y        ),
`endif
    // DIP switches
    .status         ( status        ),
    .dipsw          ( dipsw         ),
    .service        ( service       ),
    .tilt           ( tilt          ),
    .dip_pause      ( dip_pause     ),
    .dip_flip       ( dip_flip      ),
    .dip_test       ( dip_test      ),
    .dip_fxlevel    ( dip_fxlevel   ),
    // Sound output
`ifdef JTFRAME_STEREO
    .snd_left       ( snd_left      ),
    .snd_right      ( snd_right     ),
`else
    .snd            ( snd           ),
`endif
    .sample         ( sample        ),
    .game_led       ( game_led      ),
    .enable_psg     ( enable_psg    ),
    .enable_fm      ( enable_fm     ),
    // Ports declared in mem.yaml
    {{- range .Ports}}
    .{{.Name}}   ( {{.Name}} ),
    {{- end}}
    // Memory interface - SDRAM
    {{- range .SDRAM.Banks}}
    {{- range .Buses}}{{if not .Addr}}
    .{{.Name}}_addr ( {{.Name}}_addr ),{{end}}{{ if not .Cs}}
    .{{.Name}}_cs   ( {{.Name}}_cs   ),{{end}}
    .{{.Name}}_ok   ( {{.Name}}_ok   ),
    .{{.Name}}_data ( {{.Name}}_data ),
    {{- if .Rw }}
    .{{.Name}}_we   ( {{.Name}}_we   ),
    {{if not .Dsn}}.{{.Name}}_dsn  ( {{.Name}}_dsn  ),{{end}}
    {{if not .Din}}.{{.Name}}_din  ( {{.Name}}_din  ),{{end}}
    {{- end}}
    {{end}}
    {{- end}}
    // Memory interface - BRAM
{{ range $cnt, $bus:=.BRAM -}}
    {{if not .Addr}}.{{.Name}}_addr ( {{.Name}}_addr ),{{end}}{{ if .Rw }}
    {{if not .Din}}.{{.Name}}_din  ( {{.Name}}_din  ),{{end}}{{end}}{{ if .Dual_port.Name }}
    {{ if not .Dual_port.We }}.{{.Dual_port.Name}}_we ( {{.Dual_port.Name}}_we ),  // Dual port for {{.Dual_port.Name}}{{end}}
    {{ else }}{{ if not $bus.ROM.Offset }}{{end}}
    {{- end}}
{{- end}}
    // PROM writting
    .ioctl_addr   ( ioctl_addr     ),
    .prog_addr    ( pass_io ? ioctl_addr[21:0] : raw_addr      ),
    .prog_data    ( pass_io ? ioctl_dout       : raw_data[7:0] ),
    .prog_we      ( pass_io ? ioctl_wr         : prog_we       ),
    .prog_ba      ( prog_ba        ), // prog_ba supplied in case it helps re-mapping addresses
`ifdef JTFRAME_PROM_START
    .prom_we      ( prom_we        ),
`endif
    {{- with .Download.Pre_addr }}
    // SDRAM address mapper during downloading
    .pre_addr     ( pre_addr       ),
    {{- end }}
    {{- with .Download.Post_addr }}
    // SDRAM address mapper during downloading
    .post_addr    ( post_addr      ),
    {{- end }}
    {{- with .Download.Post_data }}
    .post_data    ( post_data      ),
    {{- end }}
`ifdef JTFRAME_HEADER
    .header       ( header         ),
`endif
`ifdef JTFRAME_IOCTL_RD
    .ioctl_ram    ( ioctl_ram      ),
    .ioctl_din    ( {{.Ioctl.DinName}}      ),
    .ioctl_dout   ( ioctl_dout     ),
    .ioctl_wr     ( ioctl_wr       ),
`endif
    // Debug
    .debug_bus    ( debug_bus      ),
    .debug_view   ( debug_view     ),
`ifdef JTFRAME_STATUS
    .st_addr      ( st_addr        ),
    .st_dout      ( st_dout        ),
`endif
`ifdef JTFRAME_LF_BUFFER
    .game_vrender( game_vrender  ),
    .game_hdump  ( game_hdump    ),
    .ln_addr     ( ln_addr       ),
    .ln_data     ( ln_data       ),
    .ln_done     ( ln_done       ),
    .ln_hs       ( ln_hs         ),
    .ln_pxl      ( ln_pxl        ),
    .ln_v        ( ln_v          ),
    .ln_we       ( ln_we         ),
`endif
    .gfx_en      ( gfx_en        )
);

assign dwnld_busy = downloading | prom_we; // prom_we is really just for sims
assign dwnld_addr = {{if .Download.Pre_addr }}pre_addr{{else}}ioctl_addr{{end}};
assign prog_addr = {{if .Download.Post_addr }}post_addr{{else}}raw_addr{{end}};
assign prog_data = {{if .Download.Post_data }}{2{post_data}}{{else}}raw_data{{end}};
assign gfx8_en   = {{ .Gfx8 }}
assign gfx16_en  = {{ .Gfx16 }}

jtframe_dwnld #(
`ifdef JTFRAME_HEADER
    .HEADER    ( `JTFRAME_HEADER   ),
`endif
`ifdef JTFRAME_BA1_START
    .BA1_START ( BA1_START ),
`endif
`ifdef JTFRAME_BA2_START
    .BA2_START ( BA2_START ),
`endif
`ifdef JTFRAME_BA3_START
    .BA3_START ( BA3_START ),
`endif
`ifdef JTFRAME_PROM_START
    .PROM_START( PROM_START ),
`endif
    .SWAB      ( {{if .Download.Noswab }}0{{else}}1{{end}}),
    .GFX8B0    ( {{ .Gfx8b0 }}),
    .GFX16B0   ( {{ .Gfx16b0 }})
) u_dwnld(
    .clk          ( clk            ),
    .downloading  ( downloading & ~ioctl_ram    ),
    .ioctl_addr   ( dwnld_addr     ),
    .ioctl_dout   ( ioctl_dout     ),
    .ioctl_wr     ( ioctl_wr       ),
    .gfx8_en      ( gfx8_en        ),
    .gfx16_en     ( gfx16_en       ),
    .prog_addr    ( raw_addr       ),
    .prog_data    ( raw_data       ),
    .prog_mask    ( prog_mask      ), // active low
    .prog_we      ( prog_we        ),
    .prog_rd      ( prog_rd        ),
    .prog_ba      ( prog_ba        ),
    .prom_we      ( prom_we        ),
    .header       ( header         ),
    .sdram_ack    ( prog_ack       )
);

{{ range $bank, $each:=.SDRAM.Banks }}
{{- if gt (len .Buses) 0 }}
/* verilator tracing_on */
jtframe_{{.MemType}}_{{len .Buses}}slot{{with lt 1 (len .Buses)}}s{{end}} #(
{{- $first := true}}
{{- range $index, $each:=.Buses}}
    {{- if $first}}{{$first = false}}{{else}}, {{end}}
    // {{.Name}}
    {{- if not .Rw }}
    {{- with .Offset }}
    .SLOT{{$index}}_OFFSET({{.}}[21:0]),{{end}}{{end}}
    .SLOT{{$index}}_AW({{ slot_addr_width . }}),
    .SLOT{{$index}}_DW({{ printf "%2d" .Data_width}})
{{- end}}
`ifdef JTFRAME_BA2_LEN
{{- range $index, $each:=.Buses}}
    {{- if not .Rw}}
    ,.SLOT{{$index}}_DOUBLE(1){{ end }}
{{- end}}
`endif
{{- $is_rom := eq .MemType "rom" }}
) u_bank{{$bank}}(
    .rst         ( rst        ),
    .clk         ( clk        ),
    {{ range $index2, $each:=.Buses }}{{if .Addr}}
    .slot{{$index2}}_addr  ( {{.Addr}} ),{{else}}
    {{- if eq .Data_width 32 }}
    .slot{{$index2}}_addr  ( { {{.Name}}_addr, 1'b0 } ),
    {{- else }}
    .slot{{$index2}}_addr  ( {{.Name}}_addr  ),
    {{- end }}{{end}}
    {{- if .Rw }}
    .slot{{$index2}}_wen   ( {{.Name}}_we    ),
    .slot{{$index2}}_din   ( {{if .Din}}{{.Din}}{{else}}{{.Name}}_din{{end}}   ),
    .slot{{$index2}}_wrmask( {{if .Dsn}}{{.Dsn}}{{else}}{{.Name}}_dsn{{end}}   ),
    .slot{{$index2}}_offset( {{if .Offset }}{{.Offset}}[21:0]{{else}}22'd0{{end}} ),
    {{- else }}
    {{- if not $is_rom }}
    .slot{{$index2}}_clr   ( 1'b0       ), // only 1'b0 supported in mem.yaml
    {{- end }}{{- end}}
    .slot{{$index2}}_dout  ( {{.Name}}_data  ),
    .slot{{$index2}}_cs    ( {{ if .Cs }}{{.Cs}}{{else}}{{.Name}}_cs{{end}}    ),
    .slot{{$index2}}_ok    ( {{.Name}}_ok    ),
    {{end}}
    // SDRAM controller interface
    .sdram_ack   ( ba_ack[{{$bank}}]  ),
    .sdram_rd    ( ba_rd[{{$bank}}]   ),
    .sdram_addr  ( ba{{$bank}}_addr   ),
{{- if not $is_rom }}
    .sdram_wr    ( ba_wr[{{$bank}}]   ),
    .sdram_wrmask( ba{{$bank}}_dsn    ),
    .data_write  ( ba{{$bank}}_din    ),{{end}}
    .data_dst    ( ba_dst[{{$bank}}]  ),
    .data_rdy    ( ba_rdy[{{$bank}}]  ),
    .data_read   ( data_read  )
);

{{- if $is_rom }}
assign ba_wr[{{$bank}}] = 0;
assign ba{{$bank}}_din  = 0;
assign ba{{$bank}}_dsn  = 3;
{{- end}}{{- end }}{{end}}

{{ range $index, $each:=.Unused }}
{{- with . -}}
assign ba{{$index}}_addr = 0;
assign ba_rd[{{$index}}] = 0;
assign ba_wr[{{$index}}] = 0;
assign ba{{$index}}_dsn  = 3;
assign ba{{$index}}_din  = 0;
{{ end -}}
{{ end -}}

{{ range $cnt, $bus:=.BRAM -}}
{{- if $bus.Dual_port.Name }}
// Dual port BRAM for {{$bus.Name}} and {{$bus.Dual_port.Name}}
jtframe_dual_ram{{ if eq $bus.Data_width 16 }}16{{end}} #(
    .AW({{$bus.Addr_width}}{{if eq $bus.Data_width 16}}-1{{end}}){{ if $bus.Sim_file }},
    {{ if eq $bus.Data_width 16 }}.SIMFILE_LO("{{$bus.Name}}_lo.bin"),
    .SIMFILE_HI("{{$bus.Name}}_hi.bin"){{else}}.SIMFILE("{{$bus.Name}}.bin"){{end}}{{end}}
) u_bram_{{$bus.Name}}(
    // Port 0 - {{$bus.Name}}
    .clk0   ( clk ),
    .addr0  ( {{$bus.Addr}} ),{{ if $bus.Rw }}
    .data0  ( {{$bus.Name}}_din  ),
    .we0    ( {{ if $bus.We }} {{$bus.We}}{{else}}{{$bus.Name}}_we{{end}} ), {{ else }}
    .data0  ( {{$bus.Data_width}}'h0 ),
    .we0    ( {{ if eq $bus.Data_width 16 }}2'd0{{else}}1'd0{{end}} ),{{end}}
    .q0     ( {{$bus.Name}}_dout ),
    // Port 1 - {{$bus.Dual_port.Name}}
    .clk1   ( clk ),
    .data1  ( {{if $bus.Dual_port.Din}}{{$bus.Dual_port.Din}}{{else}}{{$bus.Dual_port.Name}}_dout{{end}} ),
    .addr1  ( {{if $bus.Dual_port.Addr}}{{$bus.Dual_port.Addr}}{{else}}{{$bus.Dual_port.Name}}_addr{{ addr_range $bus }}{{end}}),{{ if $bus.Dual_port.Rw }}
    .we1    ( {{if $bus.Dual_port.We}}{{$bus.Dual_port.We}}{{else}}{{$bus.Dual_port.Name}}_we{{end}}  ), {{ else }}
    .we1    ( 2'd0 ),{{end}}
    .q1     ( {{if $bus.Dual_port.Dout}}{{$bus.Dual_port.Dout}}{{else}}{{$bus.Name}}2{{$bus.Dual_port.Name}}_data{{end}} )
);{{else}}{{if $bus.ROM.Offset }}
/* verilator tracing_on */

jtframe_bram_rom #(
    .AW({{$bus.Addr_width}}{{if is_nbits $bus 16 }}-1{{end}}),.DW({{$bus.Data_width}}),
    .OFFSET({{$bus.ROM.Offset}}),{{ if eq $bus.Data_width 16 }}
    .SIMFILE_LO("{{$bus.Name}}_lo.bin"),
    .SIMFILE_HI("{{$bus.Name}}_hi.bin"){{else}}.SIMFILE("{{$bus.Name}}.bin"){{end}}
) u_brom_{{$bus.Name}}(
    .clk    ( clk       ),
    // Read port
    .addr   ( {{if $bus.Addr}}{{$bus.Addr}}{{else}}{{$bus.Name}}_addr{{end}} ),
    .data   ( {{ data_name $bus }} ),
    // Write port
    .prog_addr( {prog_ba,prog_addr} ),
    .prog_mask( prog_mask ),
    .prog_data( prog_data[7:0] ),
    .prog_we  ( prog_we   )
);
/* verilator tracing_off */

{{else}}
// BRAM for {{$bus.Name}}
jtframe_ram{{ if eq $bus.Data_width 16 }}16{{end}} #(
    .AW({{$bus.Addr_width}}{{if eq $bus.Data_width 16}}-1{{end}}){{ if $bus.Sim_file }},
    {{ if eq $bus.Data_width 16 }}.SIMFILE_LO("{{$bus.Name}}_lo.bin"),
    .SIMFILE_HI("{{$bus.Name}}_hi.bin"){{else}}.SIMFILE("{{$bus.Name}}.bin"){{end}}{{end}}
) u_bram_{{$bus.Name}}(
    .clk    ( clk  ),{{ if eq $bus.Data_width 8 }}
    .cen    ( 1'b1 ),{{end}}
    .addr   ( {{$bus.Addr}} ),
    .data   ( {{if $bus.Din }}{{$bus.Din }}{{else}}{{$bus.Name}}_din {{end}} ),
    .we     ( {{if $bus.We  }}{{$bus.We  }}{{else}}{{$bus.Name}}_we  {{end}} ),
    .q      ( {{$bus.Name}}_dout )
);{{ end }}
{{ end }}{{end}}

{{- if .Ioctl.Dump }}
/* verilator tracing_on */
wire [7:0] ioctl_aux;
{{- range $k, $v := .Ioctl.Buses }}
{{ if $v.Aout }}wire [{{$v.AW}}-1:{{$v.AWl}}] {{$v.Aout}};{{end -}}{{end}}
jtframe_ioctl_dump #(
    {{- $first := true}}
    {{- range $k, $v := .Ioctl.Buses }}
    {{- if $first}}{{$first = false}}{{else}},{{end}}
    .DW{{$k}}( {{$v.DW}} ),
    .AW{{$k}}( {{$v.AW}} ){{end}}
) u_dump (
    .clk        ( clk       ),
    {{- range $k, $v := .Ioctl.Buses }}
    .din{{$k}} ( {{$v.Dout}} ),
    .addrin_{{$k}} ( {{$v.Ain}} ),
    .addrout_{{$k}} ( {{$v.Aout}} ),
    {{end }}
    .ioctl_addr ( ioctl_addr[23:0] ),
    .ioctl_ram  ( ioctl_ram ),
    .ioctl_aux  ( ioctl_aux ),
    .ioctl_din  ( ioctl_din )
);
{{ end }}

{{ if .Clocks }}
// Clock enable generation
{{- range $k, $v := .Clocks }} {{- range $cnt, $val := $v}}
// {{ .Comment }} Hz from {{ .ClkName }}
jtframe_frac_cen #(.W({{.W}}),.WC({{.WC}})) u_cen{{$cnt}}_{{.ClkName}}(
    .clk    ( {{.ClkName}} ),
    .n      ( {{.WC}}'d{{.Mul    }} ),
    .m      ( {{.WC}}'d{{.Div    }} ),
    .cen    ( { {{ .OutStr }} } ),
    .cenb   (              )
);
{{ end }}{{ end }}{{ end }}

endmodule
