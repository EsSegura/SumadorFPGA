module SUM (
    input logic clk,                // Señal de reloj
    input logic [12:0] num1,       // Primer número
    input logic [12:0] num2,       // Segundo número
    output logic [15:0] resultado   // Resultado de la suma
);
    // Asegura que la suma solo se realice al inicio de cada ciclo de reloj
    always_ff @(posedge clk) begin 
        resultado <= num1 + num2;
    end
    
endmodule
