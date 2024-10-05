// Módulo que genera el código de la tecla presionada basado en las filas y columnas activas
module keycode_generator (
    input logic [3:0] col_shift_reg,  // Registro de desplazamiento de columnas
    input logic [3:0] row_capture,    // Captura de las filas activas
    input logic key_pressed,          // Señal de tecla presionada
    output logic [3:0] key_code       // Código de la tecla presionada
);

    // Bloque que mapea las combinaciones de columnas y filas en códigos de tecla
    always_ff @(posedge key_pressed) begin
        case ({col_shift_reg, row_capture})

            8'b1000_1000: key_code <= 4'd0;  // Tecla '1'

            8'b1000_1000: key_code <= 4'd1;  // Tecla '1'
            8'b1000_0100: key_code <= 4'd2;  // Tecla '2'
            8'b1000_0010: key_code <= 4'd3;  // Tecla '3'

            8'b0100_1000: key_code <= 4'd4;  // Tecla '4'
            8'b0100_0100: key_code <= 4'd5;  // Tecla '5'
            8'b0100_0010: key_code <= 4'd6;  // Tecla '6'

            8'b0010_1000: key_code <= 4'd7;  // Tecla '7'
            8'b0010_0100: key_code <= 4'd8;  // Tecla '8'
            8'b0010_0010: key_code <= 4'd9;  // Tecla '9'

            8'b1000_0001: key_code <= 4'hA;  // Tecla '+'
            8'b0001_0001: key_code <= 4'hD;  // Tecla '='


            default: key_code <= 4'hF;       // Valor por defecto
        endcase
    end
endmodule
