module module_top(
    input clk_pi,
    input rst_pi,
    input [3:0] dipswitch,
    input suma_btn,
    output [3:0] anodo_po,
    output [6:0] catodo_po
);
    wire [3:0] dipswitch_clean;
    wire suma_btn_clean;
    wire [12:0] acumulador; // Acumulador para el resultado de los dipswitches
    wire [15:0] codigo_bcd;

    // Debouncing para el dipswitch
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : debouncer_dipswitch
            debouncer u_debouncer(
                .clk(clk_pi),
                .rst(rst_pi),
                .noisy_signal(dipswitch[i]),
                .clean_signal(dipswitch_clean[i])
            );
        end
    endgenerate

    // Debouncing para el botón de suma
    debouncer debounce_suma(
        .clk(clk_pi),
        .rst(rst_pi),
        .noisy_signal(suma_btn),
        .clean_signal(suma_btn_clean)
    );

    // Módulo de control de entradas
    input_control control_inst(
        .clk(clk_pi),
        .rst(rst_pi),
        .dipswitch(dipswitch_clean),  // Entrada limpia
        .suma_btn(suma_btn_clean),
        .acumulador(acumulador)
    );

    // Conversión de binario a BCD
    bin_decimal converter (
        .binario(acumulador), // Usar el acumulador directamente
        .bcd(codigo_bcd)
    );

    // Módulo de display de 7 segmentos
    module_7_segments display (
        .clk_i(clk_pi),
        .rst_i(rst_pi),
        .bcd_i(codigo_bcd),
        .anodo_o(anodo_po),
        .catodo_o(catodo_po)
    );

endmodule



