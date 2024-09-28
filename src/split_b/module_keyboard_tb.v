`timescale 1ns/1ps

module teclado_matricial_tb;

    // Señales de prueba
    logic clk;               // Señal de reloj
    logic rst;               // Señal de reinicio
    logic [3:0] row_in;      // Filas de entrada del teclado
    logic [3:0] col_out;     // Salidas de columnas del teclado
    logic [3:0] key_out;     // Código de tecla presionada

    // Instancia del DUT (Design Under Test)
    teclado_matricial dut (
        .clk(clk),
        .rst(rst),
        .row_in(row_in),
        .col_out(col_out),
        .key_out(key_out)
    );

    // Generar el reloj de 27 MHz
    always #18.518 clk = ~clk; // Período de 37.037 ns (27 MHz)

    // Procedimiento inicial para aplicar estímulos
    initial begin
        // Inicialización de señales
        clk = 0;
        rst = 1;           // Aplicar reinicio
        row_in = 4'b0000;  // Inicialmente, no hay teclas presionadas

        // Liberar el reinicio después de unos ciclos
        #50;
        rst = 0;

        // Simular la presión de la tecla '5' (columna 2, fila 2)
        wait (col_out == 4'b0010);   // Esperar que la columna 2 esté activa
        #20;                         // Esperar un ciclo de reloj
        row_in = 4'b0010;            // Activar fila 2 (tecla '5')
        #40;                         // Esperar suficiente tiempo para detectar la tecla

        // Simular la liberación de la tecla '5'
        row_in = 4'b0000;            // Ninguna tecla presionada
        #100;                        // Esperar unos ciclos más

        // Simular la presión de la tecla '0' (columna 4, fila 2)
        wait (col_out == 4'b1000);   // Esperar que la columna 4 esté activa
        #20;
        row_in = 4'b0010;            // Activar fila 2 (tecla '0')
        #40;                         // Esperar suficiente tiempo para detectar la tecla

        // Simular la liberación de la tecla '0'
        row_in = 4'b0000;
        #100;

        // Detener la simulación
        $stop;
    end

    // Monitoreo de señales clave
    initial begin
        $monitor("Tiempo: %0t | col_out = %b | row_in = %b | key_out = %h", $time, col_out, row_in, key_out);
    end

endmodule
