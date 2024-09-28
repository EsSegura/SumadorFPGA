module teclado_matricial (
    input logic clk,           // Señal de reloj (27 MHz)
    input logic rst,           // Señal de reinicio
    input logic [3:0] row_in,  // Entradas de las filas
    output logic [3:0] col_out, // Salidas de las columnas
    output logic [3:0] key_out  // Código de la tecla presionada
);

    // Señales internas
    logic slow_clk;
    logic [3:0] col_shift_reg;
    logic key_pressed;
    logic [3:0] key_code;
    logic [3:0] row_capture;

    // Instanciar el divisor de frecuencia
    freq_divider div_inst (
        .clk(clk),
        .rst(rst),
        .slow_clk(slow_clk)
    );

    // Instanciar el registro de desplazamiento de las columnas
    col_shift_register col_shift_inst (
        .slow_clk(slow_clk),
        .rst(rst),
        .col_shift_reg(col_shift_reg),
        .column_index(column_index)
    );

    // Instanciar la máquina de estados (FSM)
    fsm_controller fsm_inst (
        .slow_clk(slow_clk),
        .rst(rst),
        .row_in(row_in),
        .col_shift_reg(col_shift_reg),
        .row_capture(row_capture),
        .key_pressed(key_pressed)
    );

    // Instanciar la generación de códigos de teclas
    keycode_generator keycode_inst (
        .col_shift_reg(col_shift_reg),
        .row_capture(row_capture),
        .key_pressed(key_pressed),
        .key_code(key_code)
    );

    assign col_out = col_shift_reg;
    assign key_out = key_code;

endmodule
