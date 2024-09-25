`timescale 1ns / 1ps

module test;

    // Parámetros
    parameter CLOCK_PERIOD = 37; // 27 MHz

    // Señales de prueba
    reg clk;                     // Reloj
    reg rst;                     // Reset
    reg [3:0] bin;              // Entrada binaria
    wire [3:0] anodo;           // Salida de anodos
    wire [6:0] catodo;          // Salida de cátodos

    // Instanciar el módulo superior
    top_module uut (
        .clk_i(clk),             // Conexión del reloj
        .rst_i(rst),             // Conexión de reset
        .bin_i(bin),             // Conexión de entrada binaria
        .anodo_o(anodo),         // Conexión de salida de anodos
        .catodo_o(catodo)        // Conexión de salida de cátodos
    );

    // Generar señal de reloj
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD / 2) clk = ~clk; // Cambia de estado cada mitad del período
    end

    // Probar diferentes entradas
    initial begin
        // Inicializar señales
        rst = 0;
        bin = 4'b0000;

        // Aplicar reset
        #5 rst = 1;  // Desactivar reset
        #10;

        // Probar diferentes valores de entrada
        bin = 4'b0001; // Entrada: 1
        #100; // Esperar tiempo para observar salida

        bin = 4'b0010; // Entrada: 2
        #100;

        bin = 4'b0011; // Entrada: 3
        #100;

        bin = 4'b0100; // Entrada: 4
        #100;

        bin = 4'b1001; // Entrada: 9
        #100;

        bin = 4'b1010; // Entrada: 10
        #100;

        // Finalizar simulación
        $finish;
    end

    // Monitorear salidas
    initial begin
        $monitor("Time: %0t | Bin: %b | Anodo: %b | Catodo: %b", $time, bin, anodo, catodo);
        $dumpfile("module_7seg.vcd");
        $dumpvars(0, test);
    end

endmodule




