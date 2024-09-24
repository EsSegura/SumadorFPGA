module module_7_segments
 (
    input clk_i,
    input rst_i,
    input [15:0] bin_i, // Valor binario de entrada
    output reg [3:0] anodo_o,
    output reg [6:0] catodo_o
);

    // Parámetro de refresco del display
    parameter DISPLAY_REFRESH = 27000;

    // Señales internas
    localparam WIDTH_DISPLAY_COUNTER = $clog2(DISPLAY_REFRESH);
    reg [WIDTH_DISPLAY_COUNTER - 1:0] cuenta_salida;
    reg [3:0] digito_o;
    reg [1:0] digito_sel; // Para seleccionar el dígito
    reg en_conmutador;

    // Salida BCD tras conversión
    reg [15:0] bcd_o;

    // Contador de refresco
    always @ (posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            cuenta_salida <= DISPLAY_REFRESH - 1;
            en_conmutador <= 0;
        end else begin
            cuenta_salida <= (cuenta_salida == 0) ? (DISPLAY_REFRESH - 1) : (cuenta_salida - 1'b1);
            en_conmutador <= (cuenta_salida == 0);
        end
    end

    // Contador para seleccionar el dígito (0 a 3)
    always @ (posedge clk_i) begin
        if (rst_i) begin
            if (en_conmutador)
                digito_sel <= digito_sel + 1'b1;
        end else begin
            digito_sel <= 2'b00;
        end
    end

    // Conversión binario a BCD usando el algoritmo de doble dabble
    always @(*) begin
        integer i;
        reg [27:0] temp;
        temp = {12'b0, bin_i};  // Inicialización con el valor binario

        for (i = 0; i < 16; i = i + 1) begin
            // Si los valores en los dígitos BCD son mayores a 4, agregar 3
            if (temp[15:12] >= 5) temp[15:12] = temp[15:12] + 3;
            if (temp[19:16] >= 5) temp[19:16] = temp[19:16] + 3;
            if (temp[23:20] >= 5) temp[23:20] = temp[23:20] + 3;
            if (temp[27:24] >= 5) temp[27:24] = temp[27:24] + 3;

            // Desplazamiento a la izquierda
            temp = temp << 1;
        end
        bcd_o = temp[27:12]; // Los 16 bits BCD resultantes
    end

    // Multiplexación de dígitos
    always @(*) begin
        case (digito_sel)
            2'b00: digito_o = bcd_o[3:0];   // Unidad
            2'b01: digito_o = bcd_o[7:4];   // Decena
            2'b10: digito_o = bcd_o[11:8];  // Centena
            2'b11: digito_o = bcd_o[15:12]; // Millar
            default: digito_o = 4'd0;
        endcase

        // Selección de ánodos
        anodo_o = 4'b1111;
        anodo_o[digito_sel] = 0;
    end

    // Conversión de BCD a los segmentos del display de 7 segmentos
    always @(*) begin
        case (digito_o)
            4'd0: catodo_o = 7'b1000000;
            4'd1: catodo_o = 7'b1111001;
            4'd2: catodo_o = 7'b0100100;
            4'd3: catodo_o = 7'b0110000;
            4'd4: catodo_o = 7'b0011001;
            4'd5: catodo_o = 7'b0010010;
            4'd6: catodo_o = 7'b0000010;
            4'd7: catodo_o = 7'b1111000;
            4'd8: catodo_o = 7'b0000000;
            4'd9: catodo_o = 7'b0010000;
            default: catodo_o = 7'b1111111; // Apagado
        endcase
    end

endmodule

