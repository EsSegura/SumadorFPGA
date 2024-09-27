module arithmetic_fsm (
    input logic clk,                    // Señal de reloj de 27 MHz
    input logic rst,                    // Señal de reset
    input logic [11:0] num1_hex,        // Primer número de entrada en hexadecimal (12 bits)
    input logic [11:0] num2_hex,        // Segundo número de entrada en hexadecimal (12 bits)
    input logic new_input,              // Señal que indica nuevos datos listos para sumar
    input logic finish_input,           // Señal que indica que se finaliza la suma
    input logic accumulate_enable,      // Señal para habilitar la acumulación (activada por el teclado)
    output logic [12:0] sum_result      // Resultado de la suma (13 bits para considerar el carry)
);

    // Definir estados de la FSM
    typedef enum logic [1:0] {IDLE, SUM, ACCUMULATE, OUTPUT} state_t;
    state_t state, next_state;

    logic [12:0] stored_result;         // Registro interno para almacenar el resultado anterior

    // Lógica de estado de la FSM
    always_ff @(posedge clk or posedge rst) begin
        if (rst) 
            state <= IDLE;              // Reiniciar estado
        else 
            state <= next_state;        // Avanzar al siguiente estado
    end

    // Lógica combinacional para la transición de estados
    always_comb begin
        // Asignar un valor por defecto
        next_state = state;             // Mantener el estado por defecto

        case (state)
            IDLE: begin
                if (new_input)          // Si hay nuevos datos, ir al estado SUM
                    next_state = SUM;
            end
            SUM: begin
                next_state = OUTPUT;    // Después de sumar, ir a OUTPUT
            end
            ACCUMULATE: begin
                next_state = OUTPUT;    // Sumar el resultado anterior con el nuevo número
            end
            OUTPUT: begin
                if (new_input && accumulate_enable) // Si hay nuevos datos y accumulate_enable está activo, ir a ACCUMULATE
                    next_state = ACCUMULATE;
                else if (finish_input) 
                    next_state = IDLE;  // Volver a IDLE si se finaliza la suma
            end
        endcase
    end

    // Lógica de salida basada en los estados y entradas (máquina de Mealy)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sum_result <= 13'b0;
            stored_result <= 13'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    sum_result <= sum_result; // Mantener el resultado
                end
                SUM: begin
                    sum_result <= num1_hex + num2_hex; // Sumar los dos números (13 bits)
                    stored_result <= num1_hex + num2_hex; // Guardar el resultado
                end
                ACCUMULATE: begin
                    sum_result <= stored_result + num2_hex; // Sumar el resultado anterior con el nuevo número
                    stored_result <= stored_result + num2_hex; // Guardar el nuevo resultado
                end
                OUTPUT: begin
                    sum_result <= sum_result; // Mantener el resultado hasta que haya nuevos datos
                end
            endcase
        end
    end
endmodule
