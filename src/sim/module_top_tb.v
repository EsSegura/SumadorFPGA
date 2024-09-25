`timescale 1ns / 1ps

module testbench;

// Parámetros de simulación
localparam CLK_PERIOD = 37; // 27 MHz -> 1 / 27MHz = 37ns

// Señales para el reloj y reset
logic clk;
logic rst;

// Entradas y salidas para el módulo arithmetic_fsm
logic [11:0] num1_hex;
logic [11:0] num2_hex;
logic new_input;
logic finish_input;
logic [12:0] sum_result;

// Entradas y salidas para el módulo teclado_matricial
logic [3:0] row_in;
logic [3:0] col_out;
logic [3:0] key_out;

// Generación del reloj
initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk; // Cambia el estado cada medio período
end

// Inicialización y estímulos para el testbench
initial begin
    // Inicializar señales
    rst = 1;
    num1_hex = 12'h0;
    num2_hex = 12'h0;
    new_input = 0;
    finish_input = 0;
    row_in = 4'b0000;

    // Esperar un ciclo de reloj
    @(posedge clk);
    
    // Desactivar reset
    rst = 0;

    // Simulación de entradas en arithmetic_fsm
    @(posedge clk);
    num1_hex = 12'h005; // Primer número en hexadecimal (5)
    num2_hex = 12'h003; // Segundo número en hexadecimal (3)
    new_input = 1;      // Indica que hay nuevos datos
    @(posedge clk);
    new_input = 0;      // Limpiar la señal new_input
    @(posedge clk);
    
    // Terminar la suma
    finish_input = 1;
    @(posedge clk);
    finish_input = 0;

    // Simulación de entradas en teclado_matricial
    @(posedge clk);
    row_in = 4'b0001; // Simula la presión de la tecla '1'
    @(posedge clk);
    row_in = 4'b0000; // Liberar la tecla

    // Prueba con otras teclas
    @(posedge clk);
    row_in = 4'b0010; // Simula la presión de la tecla '2'
    @(posedge clk);
    row_in = 4'b0000; // Liberar la tecla

    // Finalizar la simulación
    @(posedge clk);
    $finish;
end

// Instanciación de los módulos
arithmetic_fsm uut_arithmetic (
    .clk(clk),
    .rst(rst),
    .num1_hex(num1_hex),
    .num2_hex(num2_hex),
    .new_input(new_input),
    .finish_input(finish_input),
    .sum_result(sum_result)
);

teclado_matricial uut_teclado (
    .clk(clk),
    .rst(rst),
    .row_in(row_in),
    .col_out(col_out),
    .key_out(key_out)
);

initial begin
        $dumpfile("sumador.vcd");
        $dumpvars(0, testbench);
    end

endmodule
