`timescale 1ns/1ps

module test();

    reg clk_i;
    reg rst_i;
    reg [15:0] bin_i;
    wire [3:0] anodo_o;
    wire [6:0] catodo_o;

    // Instancia del módulo
    module_7_segments uut 
    (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .bin_i(bin_i),
        .anodo_o(anodo_o),
        .catodo_o(catodo_o)
    );

    // Generar el reloj
    always begin
        #5 clk_i = ~clk_i; // Reloj de 10ns (100 MHz)
    end

    // Testbench
    initial begin
        // Inicialización
        clk_i = 0;
        rst_i = 0;
        bin_i = 16'd0;

        // Reset activo por 20ns
        #10 rst_i = 1;
        #20 rst_i = 0;
        #10 rst_i = 1;

        // Prueba 1: Mostrar el número 1234
        bin_i = 16'd1234; // Número binario 1234
        #100000; // Espera suficiente para ver el número en el display

        // Prueba 2: Mostrar el número 5678
        bin_i = 16'd5678; // Número binario 5678
        #100000; // Espera suficiente para ver el número en el display

        // Prueba 3: Mostrar el número 9999
        bin_i = 16'd9999; // Número binario 9999
        #100000; // Espera suficiente para ver el número en el display

        // Prueba 4: Mostrar el número 0
        bin_i = 16'd0; // Número binario 0
        #100000; // Espera suficiente para ver el número en el display

        // Fin de la simulación
        $finish;
    end

    // Mostrar el estado del display
    initial begin
        $monitor("Time: %d, bin_i: %d, anodo_o: %b, catodo_o: %b", 
                 $time, bin_i, anodo_o, catodo_o);
    end

endmodule

