module module_7_segments # (
    parameter DISPLAY_REFRESH = 27000
)(
    input clk_i,
    input rst_i,
    input [15 : 0] bcd_i,  // 16 bits para 4 dígitos BCD
    output reg [3 : 0] anodo_o,  // 4 bits para los 4 anodos
    output reg [6 : 0] catodo_o,
);

    localparam WIDTH_DISPLAY_COUNTER = $clog2(DISPLAY_REFRESH);
    reg [WIDTH_DISPLAY_COUNTER - 1 : 0] cuenta_salida;

    reg [3 : 0] digito_o;
    reg en_conmutador;
    reg [1:0] contador_digitos;  // 2 bits para contar hasta 4

    // Output refresh counter
    always @ (posedge clk_i) begin
        if(!rst_i) begin
            cuenta_salida <= DISPLAY_REFRESH - 1;
            en_conmutador <= 0;
        end
        else begin
            if(cuenta_salida == 0) begin
                cuenta_salida <= DISPLAY_REFRESH - 1;
                en_conmutador <= 1;
            end
            else begin
                cuenta_salida <= cuenta_salida - 1'b1;
                en_conmutador <= 0;
            end
        end
    end

    // 2-bit counter to select the digit (0 to 3)
    always @ (posedge clk_i) begin
        if(!rst_i) begin
            contador_digitos <= 0;
        end
        else begin 
            if(en_conmutador == 1'b1) begin
                contador_digitos <= contador_digitos + 1'b1;
            end
            else begin
                contador_digitos <= contador_digitos;
            end
        end
    end

    // Multiplexed digits
    always @(contador_digitos) begin
        digito_o = 0;
        anodo_o = 4'b1111;  // Todos los anodos apagados por defecto
        
        case(contador_digitos) 
            2'b00 : begin
                anodo_o  = 4'b1110;  // Activa display de unidades
                digito_o = bcd_i [3 : 0];   // Unidades
            end
            2'b01 : begin
                anodo_o  = 4'b1101;  // Activa display de decenas
                digito_o = bcd_i [7 : 4];   // Decenas
            end
            2'b10 : begin
                anodo_o  = 4'b1011;  // Activa display de centenas
                digito_o = bcd_i [11 : 8];  // Centenas
            end
            2'b11 : begin
                anodo_o  = 4'b0111;  // Activa display de millares
                digito_o = bcd_i [15 : 12]; // Millares
            end
            default: begin
                anodo_o  = 4'b1111;
                digito_o = 0;
            end
        endcase
    end

    // BCD to 7 segments
    always @ (digito_o) begin
        catodo_o  = 7'b1111111;
        
        case(digito_o)
            4'd0: catodo_o  = 7'b1000000;
            4'd1: catodo_o  = 7'b1111001;
            4'd2: catodo_o  = 7'b0100100;
            4'd3: catodo_o  = 7'b0110000;
            4'd4: catodo_o  = 7'b0011001;
            4'd5: catodo_o  = 7'b0010010;
            4'd6: catodo_o  = 7'b0000010;
            4'd7: catodo_o  = 7'b1111000;
            4'd8: catodo_o  = 7'b0000000;
            4'd9: catodo_o  = 7'b0010000;
            default: catodo_o  = 7'b1111111;
        endcase
    end

    

endmodule
