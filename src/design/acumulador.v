module accumulator (
    input clk,              // Reloj
    input rst,              // Reset
    input [4:0] dipswitch,  // Entrada de 5 bits del dipswitch
    input suma_btn,         // Botón de suma
    output reg [15:0] total // Total acumulado (16 bits)
);
    
    reg suma_btn_prev; // Registro para el estado anterior del botón

    // Proceso de acumulación
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            total <= 0;             // Inicializar total a 0
            suma_btn_prev <= 0;     // Inicializar el estado anterior del botón
        end
        else begin
            // Detectar flanco ascendente del botón de suma
            if (suma_btn && !suma_btn_prev) begin
                total <= total + dipswitch; // Sumar el valor del dipswitch
            end
            suma_btn_prev <= suma_btn; // Actualizar el estado anterior del botón
        end
    end

endmodule






