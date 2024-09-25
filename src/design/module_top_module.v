module top_module (
    input logic clk_i,               // Reloj de entrada (27 MHz)
    input logic rst_i,               // Reset de entrada
    input logic [3:0] row_in,        // Entradas de las filas del teclado
    output logic [3:0] col_out,      // Salidas de las columnas del teclado
    output logic [3:0] anodo_o,       // Salida de anodos para los displays
    output logic [6:0] catodo_o,      // Salida de cátodos para los displays
    output logic [12:0] sum_result,   // Resultado de la suma (13 bits)
    input logic [11:0] num1_hex,      // Primer número en hexadecimal (12 bits)
    input logic [11:0] num2_hex,      // Segundo número en hexadecimal (12 bits)
    input logic new_input,            // Señal que indica nuevos datos listos para sumar
    input logic finish_input           // Señal que indica que se finaliza la suma
);

    // Conexiones internas
    wire [15:0] bcd;                   // Salida BCD del módulo de conversión
    wire [3:0] key_out;                // Código de la tecla presionada

    // Instanciar el módulo de conversión de binario a BCD
    module_bin_to_bcd #(
        .WIDTH(4)                      // Ancho de entrada binaria
    ) u_bin_to_bcd (
        .clk_i(clk_i),                 // Conexión del reloj
        .rst_i(rst_i),                 // Conexión de reset
        .bin_i(num1_hex),              // Conexión de entrada binaria (primer número)
        .bcd_o(bcd)                    // Conexión de salida BCD
    );

    // Instanciar el módulo de displays de 7 segmentos
    module_7_segments #(
        .DISPLAY_REFRESH(27000)        // Frecuencia de refresco
    ) u_7_segments (
        .clk_i(clk_i),                  // Conexión del reloj
        .rst_i(rst_i),                  // Conexión de reset
        .bcd_i(bcd),                    // Conexión de entrada BCD
        .anodo_o(anodo_o),              // Conexión de salida de anodos
        .catodo_o(catodo_o)             // Conexión de salida de cátodos
    );

    // Instanciar la FSM aritmética
    arithmetic_fsm u_arithmetic_fsm (
        .clk(clk_i),                    // Conexión del reloj
        .rst(rst_i),                    // Conexión de reset
        .num1_hex(num1_hex),            // Primer número de entrada
        .num2_hex(num2_hex),            // Segundo número de entrada
        .new_input(new_input),          // Señal de nuevos datos
        .finish_input(finish_input),    // Señal de fin de suma
        .sum_result(sum_result)         // Salida del resultado de la suma
    );

    // Instanciar el teclado matricial
    teclado_matricial u_teclado_matricial (
        .clk(clk_i),                    // Conexión del reloj
        .rst(rst_i),                    // Conexión de reset
        .row_in(row_in),                // Conexión de entrada de filas
        .col_out(col_out),              // Conexión de salida de columnas
        .key_out(key_out)               // Código de la tecla presionada
    );

endmodule