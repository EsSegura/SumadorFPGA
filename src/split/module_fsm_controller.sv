// Módulo de la máquina de estados (FSM) que controla el escaneo del teclado y el debounce
module fsm_controller (
    input logic slow_clk,        // Entrada del reloj lento
    input logic rst,             // Señal de reinicio
    input logic [3:0] row_in,    // Entradas de las filas del teclado
    input logic [3:0] col_shift_reg, // Registro de desplazamiento de columnas
    output logic [3:0] row_capture,  // Captura de las filas activas
    output logic key_pressed     // Señal de tecla presionada
);

    // Definición de los estados de la FSM
    typedef enum logic [1:0] {
        IDLE,       // Estado de reposo
        SCAN,       // Estado de escaneo de teclas
        DEBOUNCE    // Estado de debounce
    } state_t;

    state_t current_state, next_state; // Variables para los estados actuales y siguientes

    // Bloque secuencial que maneja la transición entre estados
    always_ff @(posedge slow_clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;      // Reiniciar a estado IDLE
            key_pressed <= 0;           // Reiniciar la señal de tecla presionada
        end else begin
            current_state <= next_state; // Avanzar al siguiente estado
        end
    end

    // Bloque combinacional que define la lógica de transición de estados
    always_comb begin
        next_state = current_state;     // Por defecto, mantenerse en el estado actual
        row_capture = 4'b0000;          // Valor por defecto para row_capture
        key_pressed = 0;                 // Valor por defecto para key_pressed

        case (current_state)
            IDLE: begin
                if (row_in != 4'b0000) begin
                    next_state = SCAN;  // Si una fila está activa, pasar a SCAN
                end
            end
            SCAN: begin
                row_capture = row_in;   // Capturar la fila activa
                if (row_in != 4'b0000) begin
                    next_state = DEBOUNCE; // Si hay una tecla, pasar a DEBOUNCE
                end else begin
                    next_state = IDLE;  // Si no hay tecla, volver a IDLE
                end
            end
            DEBOUNCE: begin
                key_pressed = 1;        // Confirmar que una tecla fue presionada
                next_state = IDLE;      // Volver al estado IDLE
            end
        endcase
    end
endmodule
