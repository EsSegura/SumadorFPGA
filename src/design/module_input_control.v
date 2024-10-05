module input_control (
    input clk,
    input rst,
    input [3:0] dipswitch,
    input suma_btn,
    output reg [11:0] acumulador // Acumulador de 12 bits
);
    reg suma_btn_prev; // Estado previo del botón de suma

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            acumulador <= 12'b0; // Reinicia el acumulador
            suma_btn_prev <= 1'b0; // Reinicia el estado previo del botón
        end
        else begin
            // Detecta el flanco ascendente del botón de suma
            if (suma_btn && !suma_btn_prev) begin
                // Sumar el valor de dipswitches al acumulador
                // Asegura que el valor acumulado no exceda el límite de 12 bits
                acumulador <= acumulador + {8'b0, dipswitch}; // Agregar el valor de los dipswitches
            end
            
            suma_btn_prev <= suma_btn; // Actualiza el estado previo del botón
        end
    end
endmodule












