`timescale 1ns/1ps

module test;

    // Señales del módulo
    reg clk_pi;                  // Señal de reloj
    reg rst_pi;                  // Señal de reset
    reg [3:0] dipswitch;         // Entrada del dipswitch (5 bits)
    reg suma_btn;                // Botón de suma

    // Salidas del módulo
    wire [3:0] anodo_po;         // Salida de ánodos para displays
    wire [6:0] catodo_po;        // Salida de cátodos para displays
    wire [15:0] acumulador_total; // Acumulador total (16 bits)

    // Parámetros de reloj y simulación
    parameter CLK_PERIOD = 37.037;  // Periodo de 27 MHz
    parameter DELAY_BTN = 1000;       // Delay para simular el botón

    // Instancia del módulo principal
    module_top uut (
        .clk_pi(clk_pi),
        .rst_pi(rst_pi),
        .dipswitch(dipswitch),
        .suma_btn(suma_btn),
        .anodo_po(anodo_po),
        .catodo_po(catodo_po),
        .acumulador_total(acumulador_total)
    );

    // Generador de reloj a 27 MHz
    initial begin
        clk_pi = 0;
        forever #(CLK_PERIOD / 2) clk_pi = ~clk_pi; // Alterna el reloj cada mitad de periodo
    end

    // Proceso de prueba
    initial begin
        // Inicialización de señales
        rst_pi = 0;
        dipswitch = 4'b0000; // Inicialmente en 0
        suma_btn = 0;         // Botón de suma inicialmente desactivado

        // Aplicar reset
        #100 rst_pi = 1;     // Activar reset después de 100 ns
        #100 rst_pi = 0;     // Desactivar reset

        // Probar sumas con diferentes valores del dipswitch
        #50000 dipswitch = 4'b0001; // Añadir 1
        #DELAY_BTN suma_btn = 1;     // Pulsar botón de suma
        #(10*CLK_PERIOD) suma_btn = 0;     // Liberar botón de suma

        #70000 dipswitch = 4'b0010; // Añadir 2
        #DELAY_BTN suma_btn = 1;     // Pulsar botón de suma
        #(10*CLK_PERIOD) suma_btn = 0;     // Liberar botón de suma

        #90000 dipswitch = 4'b0100; // Añadir 4
        #DELAY_BTN suma_btn = 1;     // Pulsar botón de suma
        #(10*CLK_PERIOD) suma_btn = 0;     // Liberar botón de suma

        #120000 dipswitch = 4'b1000; // Añadir 8
        #DELAY_BTN suma_btn = 1;     // Pulsar botón de suma
        #(10*CLK_PERIOD) suma_btn = 0;     // Liberar botón de suma

        #140000 dipswitch = 4'b0101; // Añadir 31
        #DELAY_BTN suma_btn = 1;     // Pulsar botón de suma
        #(10*CLK_PERIOD) suma_btn = 0;     // Liberar botón de suma

        // Finalizar la simulación
        #1000000 $stop;
    end

    // Monitor para observar cambios relevantes
    // Monitor para observar cambios relevantes
    initial begin
        $monitor("Time: %0t ns | Dipswitch: %b | Suma: %b | Acumulador Total: %b | Display: %d", 
                 $time, dipswitch, suma_btn, acumulador_total, anodo_po);
    end


endmodule
