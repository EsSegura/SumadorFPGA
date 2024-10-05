module bin_decimal (
    input [11:0] binario,  // 12 bits para manejar la entrada binaria
    output reg [15:0] bcd   // Salida BCD de 16 bits (4 dígitos)
);
    integer i;

    always @(*) begin
        bcd = 16'b0;  // Inicializar BCD a 0

        // Proceso de conversión de binario a BCD
        for (i = 0; i < 12; i = i + 1) begin
            // Si cualquier grupo de 4 bits en BCD es mayor o igual a 5, suma 3
            if (bcd[3:0] >= 5) 
                bcd[3:0] = bcd[3:0] + 4'd3;
            if (bcd[7:4] >= 5) 
                bcd[7:4] = bcd[7:4] + 4'd3;
            if (bcd[11:8] >= 5) 
                bcd[11:8] = bcd[11:8] + 4'd3;
            if (bcd[15:12] >= 5) 
                bcd[15:12] = bcd[15:12] + 4'd3;

            // Desplaza los bits del binario hacia BCD
            bcd = {bcd[14:0], binario[11-i]}; // Desplaza los bits del binario
        end
    end
endmodule




