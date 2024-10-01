module module_bin_to_bcd #(
    parameter WIDTH = 4
)(
    input clk,
    input rst_i,
    input [WIDTH - 1 : 0] bin_i,
    output reg [15:0] bcd_o // 4 dígitos BCD
);

    reg [3:0] unidades;
    reg [3:0] decenas;
    reg [3:0] centenas; // Para números mayores a 99
    reg [3:0] millares; // Para números mayores a 999

    always @(*) begin
        // Inicializar unidades, decenas, centenas y millares
        unidades = bin_i % 10;        // Obtener unidades
        decenas  = (bin_i / 10) % 10; // Obtener decenas
        centenas = (bin_i / 100) % 10; // Obtener centenas (0 para 0-15)
        millares  = (bin_i / 1000) % 10; // Obtener millares (0 para 0-15)
    end

    always @(posedge clk or negedge rst_i) begin
        if (~rst_i) begin
            bcd_o <= 16'b0; // Resetear la salida a 0
        end else begin
            bcd_o <= {millares, centenas, decenas, unidades}; // Asignar BCD directamente
        end
    end
endmodule