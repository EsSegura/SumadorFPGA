module debouncer(
    input clk,             // Reloj principal
    input rst,             // Reset
    input noisy_signal,    // Señal con rebote
    output reg clean_signal // Señal limpia sin rebote
);
    parameter DEBOUNCE_TIME = 27000; // Tiempo de filtro para eliminar rebotes
    reg [15:0] counter;              // Contador de tiempo

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            clean_signal <= 0;
        end
        else begin
            // Si la señal es constante, incrementar el contador
            if (noisy_signal == clean_signal) begin
                counter <= 0;  // Resetear el contador si la señal es constante
            end
            else begin
                counter <= counter + 1;
                if (counter >= DEBOUNCE_TIME) begin
                    clean_signal <= noisy_signal; // Actualizar la señal limpia
                    counter <= 0;
                end
            end
        end
    end
endmodule
