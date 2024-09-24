module teclado_matricial (
    input logic clk,           // Señal de reloj
    input logic rst,           // Señal de reinicio
    input logic [3:0] row_in,  // Entradas de las filas (idle = 4'b0000, tecla presionada = 1)
    output logic [3:0] col_out, // Salidas de las columnas
    output logic [3:0] key_out  // Código de la tecla presionada (salida principal)
);

    // Registro de desplazamiento para las columnas
    logic [3:0] col_shift_reg;  // Registro de desplazamiento para las columnas
    logic [1:0] column_index;   // Índice de la columna activa (0 a 3)
    logic [3:0] row_capture;    // Captura de las filas
    logic key_pressed;          // Estado de tecla presionada
    logic [3:0] key_code;       // Código de la tecla presionada

    // FSM States
    typedef enum logic [1:0] {
        IDLE,    // Estado en reposo
        SCAN,    // Escaneando el teclado
        DEBOUNCE // Debouncing
    } state_t;
    state_t current_state, next_state;

    // Inicialización del registro de desplazamiento y FSM
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            col_shift_reg <= 4'b0001; // Empezar activando la primera columna (solo un bit activo)
            column_index <= 0;
            key_pressed <= 0;
            current_state <= IDLE;
            key_code <= 4'hF;        // Valor por defecto cuando no se presiona ninguna tecla
        end else begin
            current_state <= next_state;
            // Desplazar el bit 1 a la izquierda de forma circular
            col_shift_reg <= {col_shift_reg[2:0], col_shift_reg[3]};
        end
    end

    // Lógica de cambio de estado
    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (row_in != 4'b0000) // Si una fila está activa (hay tecla presionada)
                    next_state = SCAN;
            end
            SCAN: begin
                if (row_in != 4'b0000) begin
                    row_capture = row_in;
                    key_pressed = 1;
                    next_state = DEBOUNCE; // Ir a debouncing
                end
            end
            DEBOUNCE: begin
                if (row_in == 4'b0000) begin // Esperar que la tecla se libere
                    key_pressed = 0;
                    next_state = IDLE; // Volver a reposo
                end
            end
        endcase
    end

    // Asignación de la salida de las columnas
    assign col_out = col_shift_reg;

    // Generar código de tecla presionada basado en columna activa y fila leída
    always_ff @(posedge clk) begin
        if (key_pressed) begin
            case ({col_shift_reg, row_capture})
                // Mapeo de las combinaciones de columnas y filas a los códigos de tecla
                8'b0001_0001: key_code <= 4'h1;
                8'b0001_0010: key_code <= 4'h2;
                8'b0001_0100: key_code <= 4'h3;
                8'b0001_1000: key_code <= 4'hA;
                8'b0010_0001: key_code <= 4'h4;
                8'b0010_0010: key_code <= 4'h5;
                8'b0010_0100: key_code <= 4'h6;
                8'b0010_1000: key_code <= 4'hB;
                8'b0100_0001: key_code <= 4'h7;
                8'b0100_0010: key_code <= 4'h8;
                8'b0100_0100: key_code <= 4'h9;
                8'b0100_1000: key_code <= 4'hC;
                8'b1000_0001: key_code <= 4'hE; // Esto es usualmente '*'
                8'b1000_0010: key_code <= 4'h0;
                8'b1000_0100: key_code <= 4'hF; // Esto es usualmente '#'
                8'b1000_1000: key_code <= 4'hD;
                default: key_code <= 4'hF; // Valor por defecto si no hay tecla válida
            endcase
        end
    end

    // Asignar el código de la tecla presionada a la salida principal
    assign key_out = key_code;

endmodule
