`timescale 1ns/1ps

module tb_module_7_segments;

    // Señales del módulo
    reg clk_i;                       // Reloj de entrada
    reg rst_i;                       // Señal de reset
    reg [15:0] bcd_i;                // Entrada BCD de 16 bits
    wire [3:0] anodo_o;              // Señales de anodos
    wire [6:0] catodo_o;             // Señales de catodos (7 segmentos)

    // Parámetros de reloj y simulación
    parameter CLK_PERIOD = 37.037;   // Periodo de 37.037 ns para 27 MHz

    // Instancia del módulo 7 segmentos
    module_7_segments #(
        .DISPLAY_REFRESH(27000)  // Valor de refresh para la multiplexación (ajustable)
    ) uut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .bcd_i(bcd_i),
        .anodo_o(anodo_o),
        .catodo_o(catodo_o)
    );

    // Generador de reloj a 27 MHz
    initial begin
        clk_i = 0;
        forever #(CLK_PERIOD / 2) clk_i = ~clk_i; // Alterna el reloj cada mitad de periodo
    end

    // Proceso de prueba
    initial begin
        // Inicialización de señales
        rst_i = 0;
        bcd_i = 16'h0000; // BCD inicial (0 0 0 0)

        // Aplicar reset
        #100 rst_i = 1;   // Activar reset después de 100 ns
        #100 rst_i = 0;   // Desactivar reset

        // Probar diferentes valores BCD y mostrar información limitada
        #50000 bcd_i = 16'h1234; // Valor BCD: 1234 (millares, centenas, decenas, unidades)
        #1000 $display("BCD: %h | Unidades: %0d | Decenas: %0d | Centenas: %0d | Millares: %0d", 
                        bcd_i, bcd_i[3:0], bcd_i[7:4], bcd_i[11:8], bcd_i[15:12]);

        #50000 bcd_i = 16'h5678; // Valor BCD: 5678
        #1000 $display("BCD: %h | Unidades: %0d | Decenas: %0d | Centenas: %0d | Millares: %0d", 
                        bcd_i, bcd_i[3:0], bcd_i[7:4], bcd_i[11:8], bcd_i[15:12]);

        #50000 bcd_i = 16'h0001; // Valor BCD: 0001
        #1000 $display("BCD: %h | Unidades: %0d | Decenas: %0d | Centenas: %0d | Millares: %0d", 
                        bcd_i, bcd_i[3:0], bcd_i[7:4], bcd_i[11:8], bcd_i[15:12]);

        #50000 bcd_i = 16'h9999; // Valor BCD: 9999
        #1000 $display("BCD: %h | Unidades: %0d | Decenas: %0d | Centenas: %0d | Millares: %0d", 
                        bcd_i, bcd_i[3:0], bcd_i[7:4], bcd_i[11:8], bcd_i[15:12]);

        #50000 $stop; // Finalizar la simulación
    end

    // Monitor para observar solo cambios relevantes
    initial begin
        $display("Time: %0t ns | rst = %b | bcd_i = %h | anodo_o = %b | catodo_o = %b", 
                 $time, rst_i, bcd_i, anodo_o, catodo_o);
    end

endmodule
