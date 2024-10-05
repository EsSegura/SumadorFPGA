# Calculadora sumadora mediante el uso de dipswitch
### Estudiantes:
-Christian Aparicio Cambronero

-Eric Castro Velazquez

-Esteban Segura García 
## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo

### 3.0 Descripción general del sistema
El sistema implementado consiste en varios módulos en Verilog que interactúan para capturar, acumular y visualizar números en una calculadora de sumas utilizando cuatro displays de 7 segmentos. El módulo principal (module_top) coordina la operación del sistema, comenzando con un proceso de debouncing para limpiar las señales de entrada provenientes de un dipswitch de 4 bits y un botón de suma (suma_btn), eliminando ruidos y asegurando lecturas estables. Luego, el módulo de control de entradas gestiona la acumulación del valor ingresado: cada vez que se presiona el botón de suma, el valor del dipswitch limpio se añade a un acumulador interno. Este valor acumulado se convierte posteriormente a código BCD a través de un módulo de conversión binario a BCD, que transforma el valor de 13 bits del acumulador a un formato BCD de 16 bits, facilitando su representación en el display. Finalmente, el módulo de visualización controla los cuatro displays de 7 segmentos multiplexados, manejando la conmutación de cada display y activando los segmentos correspondientes para mostrar el valor acumulado en un formato decimal legible. De esta forma, el sistema permite al usuario realizar sumas consecutivas y ver el resultado actualizado de manera precisa en los displays de 7 segmentos, garantizando una operación fluida y confiable.

### 3.1 Módulo 1
#### 3.1.1. module_input_control
```SystemVerilog
module input_control (
    input clk,
    input rst,
    input [3:0] dipswitch,
    input suma_btn,
    output reg [11:0] acumulador // Acumulador de 12 bits
);
    reg suma_btn_prev; // Estado previo del botón de suma

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            acumulador <= 12'b0; // Reinicia el acumulador
            suma_btn_prev <= 1'b0; // Reinicia el estado previo del botón
        end
        else begin
            // Detecta el flanco ascendente del botón de suma
            if (suma_btn && !suma_btn_prev) begin
                // Sumar el valor de dipswitches al acumulador
                // Asegura que el valor acumulado no exceda el límite de 12 bits
                acumulador <= acumulador + {8'b0, dipswitch}; // Agregar el valor de los dipswitches
            end
            
            suma_btn_prev <= suma_btn; // Actualiza el estado previo del botón
        end
    end
endmodule
```
#### 3.1.2. Parámetros

No se definen parámetros para este módulo.

#### 3.1.3. Entradas y salidas:

1. `clk` Señal de reloj del sistema utilizada para sincronizar las operaciones internas.
2. `rst` Señal de reinicio activa en bajo (negedge), que se utiliza para resetear el valor del acumulador y el estado del botón.
3. `dispswitch [3:0]`: Señal de 4 bits que representa el número de entrada que se desea sumar al acumulador.
4. `suma_btn`:  Señal del botón de suma que permite acumular el valor del dipswitch al detectar un flanco ascendente (cambio de 0 a 1).
5. `acumulador [11:0]`:Salida de 12 bits que almacena el valor acumulado de las sumas realizadas. El acumulador se actualiza cada vez que se presiona el botón de suma, y puede representar valores hasta un máximo de 12 bits (0 a 4095 en decimal).

##### Descripción del módulo:

El módulo `input_control` gestiona la suma de valores provenientes de un interruptor DIP de 4 bits (`dipswitch`) y los acumula en un registro de 12 bits (`acumulador`) mediante la detección de flancos ascendentes en la señal de un botón de suma (`suma_btn`). El módulo se sincroniza con una señal de reloj (`clk`) y cuenta con una señal de reinicio activo en bajo (`rst`) que establece el acumulador y el estado previo del botón a cero. La operación principal del módulo se basa en detectar el cambio de estado del botón de suma utilizando un registro de estado previo (`suma_btn_prev`), lo que permite identificar el flanco ascendente y realizar la suma del valor del dipswitch al acumulador solo en cada transición de no presionado a presionado. El valor de entrada del dipswitch se amplía a 12 bits concatenando 8 ceros a la izquierda (`{8'b0, dipswitch}`), asegurando que la suma se realice de manera correcta y que el acumulador no exceda su límite de 12 bits. En caso de que la señal de reinicio se active, el módulo restablece el acumulador y el estado del botón, garantizando un estado inicial limpio. El uso de un flanco ascendente para la operación de suma evita la acumulación continua mientras el botón está presionado, proporcionando una operación precisa y sincronizada con el reloj del sistema.

#### 3.1.4. Criterios de diseño
![image](https://github.com/user-attachments/assets/c0423cd7-c50d-4287-b045-53b740186084)



### 3.2 Módulo 2
#### 3.2.1 Module_7_segments
```SystemVerilog
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
```
#### 3.2.2. Parámetros

1. `DISPLAY_REFRESH`: Define la cantidad de ciclos de reloj para refrescar el display, para este caso, a 27000Hz.

#### 3.2.3. Entradas y salidas:

1. `clk_i`: Señal de reloj que sincroniza las operaciones del módulo.
2. `rst_i`: Señal de reinicio para inicializar los registros.
3. `bcd_i [15:0]`: Entrada de 16 bits que contiene el valor en BCD a mostrar (4 dígitos).
4. `anodo_o [1:0]`: Controla qué dígito del display está activo.
5. `catodo_o [6:0]`: Controla los segmentos del display para representar el dígito en BCD.
6. `cuenta_salida`: Contador de refresco para el display.
7. `digito_o [3:0]`: Registro que almacena el dígito actual a mostrar en el display.
8. `en_conmutador`: Señal que indica cuándo cambiar entre dígitos.
9. `contador_digitos [1:0]`: Registro que indica si se está mostrando la unidad, decena, centena o millar.
    
##### Descripción del módulo:

El módulo `module_7_segments` está diseñado para controlar un display de 7 segmentos multiplexado, permitiendo la visualización de un valor BCD de 16 bits, que representa hasta 4 dígitos. Utiliza una señal de reloj (`clk_i`) y una señal de reinicio activo en alto (`rst_i`) para sincronizar su funcionamiento. Un contador interno de refresco (`cuenta_salida`) se utiliza para gestionar la frecuencia de conmutación entre los distintos dígitos del display, con un parámetro configurable `DISPLAY_REFRESH` que determina la velocidad de actualización del display. El módulo implementa un contador de 2 bits (`contador_digitos`) que selecciona el dígito actual a visualizar, activando el correspondiente ánodo mientras desactiva los demás. La conversión de cada dígito BCD a su representación en el display de 7 segmentos se realiza mediante una lógica combinacional que asigna la salida de catodo (`catodo_o`) en función del dígito seleccionado.

#### 3.2.4. Criterios de diseño
![image](https://github.com/user-attachments/assets/ae734855-beee-404f-9698-d03191ab727f)




### 3.3 Módulo 3
#### 3.3.1. module_bin_to_bcd
```SystemVerilog
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
```
#### 3.3.2. Parámetros

No se definen parámetros para este módulo

#### 3.3.3. Entradas y salidas:
##### Descripción de la entrada:

1. `binario [11:0]` : Esta es una entrada de 12 bits que representa un número en formato binario. El rango de valores que puede aceptar va de 0 a 4095 (en decimal).
2. `bcd [15:0]`: Esta es la salida de 16 bits que representa el número en formato BCD (Decimal Codificado en Binario), permitiendo representar hasta 4 dígitos decimales.

##### Descripción del módulo:

El módulo `bin_decimal` está diseñado para convertir un número binario de 12 bits en su equivalente en BCD de 16 bits. El proceso de conversión se realiza mediante un algoritmo de desplazamiento que itera a través de cada bit de la entrada binaria. En cada iteración, se verifica si alguno de los grupos de 4 bits en la salida BCD es mayor o igual a 5; si es así, se le suma 3 a ese grupo, siguiendo el método de corrección de BCD. Luego, el módulo desplaza el valor actual de BCD hacia la izquierda, incorporando el siguiente bit de la entrada binaria en la posición menos significativa. Este proceso se repite durante 12 ciclos, asegurando que todos los bits del número binario se conviertan adecuadamente en su representación BCD.

#### 3.3.4. Criterios de diseño
![image](https://github.com/user-attachments/assets/efb5779a-ff11-4b45-8b1f-cd76edcdc59d)


### 3.4 Módulo 4
#### 3.3.1. module_debouncer
```SystemVerilog
module debouncer(
    input clk,             // Reloj principal
    input rst,             // Reset
    input noisy_signal,    // Señal con rebote
    output reg clean_signal // Señal limpia sin rebote
);
    parameter DEBOUNCE_TIME = 27000; // Tiempo de filtro para eliminar rebotes
    reg [15:0] counter;              // Contador de tiempo

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            clean_signal <= 0;
        end
        else begin
            // Si la señal es constante, incrementar el contador
            if (noisy_signal == clean_signal) begin
                counter <= 0;  // Resetear el contador si la señal es constante
            end
            else begin
                counter <= counter + 1;
                if (counter >= DEBOUNCE_TIME) begin
                    clean_signal <= noisy_signal; // Actualizar la señal limpia
                    counter <= 0;
                end
            end
        end
    end
endmodule
```
#### 3.3.2. Parámetros

1. `DEBOUNCE_TIME` : Tiempo de filtro para eliminar rebotes.

#### 3.3.3. Entradas y salidas:
##### Descripción de la entrada:

1. `clk` : Esta es la señal de reloj principal que sincroniza el funcionamiento del módulo.
2. `rst`: Esta es la señal de reinicio que, al ser activada, restablece el módulo a su estado inicial.
3. `noisy_signal`: Esta entrada representa la señal que puede contener rebotes, como un botón mecánico o un interruptor.
4. `clean_signal`: Esta es la salida de la señal limpia, que se produce sin rebotes, proporcionando una señal estable a la salida.

##### Descripción del módulo:

El módulo `debouncer` está diseñado para eliminar el efecto de rebote en señales digitales, como las que provienen de botones. Utiliza un contador que se incrementa en cada ciclo de reloj mientras la señal de entrada `noisy_signal` varía de manera diferente a la última señal limpia. Si la señal es constante y coincide con `clean_signal`, el contador se reinicia a cero. En caso de que se detecte un cambio en la señal ruidosa, el contador comienza a contar. Una vez que el contador alcanza el tiempo definido por `DEBOUNCE_TIME`, se actualiza `clean_signal` con el valor actual de `noisy_signal`, garantizando que cualquier cambio en la señal de entrada sea estable antes de que se refleje en la salida

#### 3.3.4. Criterios de diseño 
![image](https://github.com/user-attachments/assets/2253a8db-cf2b-417e-98f5-b25ae80f8eb9)



### 4. Testbench
Con los modulos listos, se trabajo en un testbench para poder ejecutar todo de la misma forma y al mismo tiempo, y con ello, poder observar las simulaciones y obtener una mejor visualización de como funciona todo el código. 
```SystemVerilog

```
#### Descripción del testbench 



### Otros modulos
En este apartado, se colocará el ultimo modulo, el cual corresponde a la unión de los 4 modulos para poder ejecutar un Makefile de manera correcta y su respectiva sincronización.
```SystemVerilog
module module_top(
    input clk_pi,
    input rst_pi,
    input [3:0] dipswitch,
    input suma_btn,
    output [3:0] anodo_po,
    output [6:0] catodo_po
);
    wire [3:0] dipswitch_clean;
    wire suma_btn_clean;
    wire [12:0] acumulador; // Acumulador para el resultado de los dipswitches
    wire [15:0] codigo_bcd;

    // Debouncing para el dipswitch
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : debouncer_dipswitch
            debouncer u_debouncer(
                .clk(clk_pi),
                .rst(rst_pi),
                .noisy_signal(dipswitch[i]),
                .clean_signal(dipswitch_clean[i])
            );
        end
    endgenerate

    // Debouncing para el botón de suma
    debouncer debounce_suma(
        .clk(clk_pi),
        .rst(rst_pi),
        .noisy_signal(suma_btn),
        .clean_signal(suma_btn_clean)
    );

    // Módulo de control de entradas
    input_control control_inst(
        .clk(clk_pi),
        .rst(rst_pi),
        .dipswitch(dipswitch_clean),  // Entrada limpia
        .suma_btn(suma_btn_clean),
        .acumulador(acumulador)
    );

    // Conversión de binario a BCD
    bin_decimal converter (
        .binario(acumulador), // Usar el acumulador directamente
        .bcd(codigo_bcd)
    );

    // Módulo de display de 7 segmentos
    module_7_segments display (
        .clk_i(clk_pi),
        .rst_i(rst_pi),
        .bcd_i(codigo_bcd),
        .anodo_o(anodo_po),
        .catodo_o(catodo_po)
    );

endmodule
```
#### Parámetros

No se definen parámetros para este módulo.

#### Entradas y salidas:
##### Descripción de la entrada:
1. `clk_i `: Señal de reloj que sincroniza todo el módulo. Esta señal es utilizada para que todos los submódulos puedan operar de manera sincronizada y coordinar el flujo de datos a través del sistema.
2. `rst_i`: Señal de reset asíncrona. Cuando se activa, todos los submódulos internos y el módulo principal se reinician, asegurando que el sistema regrese a un estado conocido antes de iniciar cualquier operación.
3. `dipswitch [3 : 0]` : Señal de entrada de 4 bits proveniente de un conjunto de interruptores, que se utilizará para el control de la operación.
4. `suma_btn` : Botón para activar la suma de los valores del conjunto de interruptores.
5. `anodo_po`: Señal de salida para los pines de anodo del display de 7 segmentos.
6. `catodo_po`: Señal de salida para los pines de cátodo del display de 7 segmentos.

##### Descripción del módulo:

El módulo `module_top` actúa como el nivel superior de un sistema digital que integra varias funcionalidades, incluidas la limpieza de señales, la acumulación y la visualización en 4 displays de 7 segmentos. Comienza con la limpieza de las señales de entrada mediante módulos de "debounce" para eliminar el ruido de las señales de los interruptores y del botón de suma. La señal limpia de los interruptores se envía al módulo `input_control`, que acumula los valores de los interruptores cuando el botón de suma es presionado. Este acumulador de 12 bits se convierte posteriormente a BCD (Código Decimal Binario) a través del módulo `bin_decimal`. Finalmente, el código BCD resultante se utiliza para activar el display de 7 segmentos mediante el módulo `module_7_segments`, el cual maneja las señales de anodo y cátodo para representar los valores acumulados visualmente.

#### Criterios de diseño
![image](https://github.com/user-attachments/assets/97ec0969-b74f-43a4-bd2d-2be2ce1743ec)


## 5. Consumo de recursos

![image](https://github.com/user-attachments/assets/507c66b2-dad5-4df5-b4d1-bec0687e57cd)
   

## 6. Observaciones/Aclaraciones

Se utilizó un dipswitch como herramienta para poder introducir los digitos de forma binaria a la calculadora. Al estar habilitados solo 4 switches, el valor máximo que se puede ingresar es de 4bits, o sea, el número 15 en decimal. Por la tanto, tomando está consideración anterior, la suma máxima que se puede obtener es de resultado 30. Por otra parte, el código esta configurado para poder recibir o soportar más bits, por lo tanto, solo se tendría que aumentar los switches (se utilizó un dipswitch de 8) para poder introducir más números. 

## 7. Problemas encontrados durante el proyecto

Durante el desarrollo del sistema, se presentaron varios problemas. En primer lugar, el teclado no operó correctamente debido a las distintas definiciones de sincronía, lo que impidió la captura precisa de las entradas. Además, se estableció un límite en la introducción de números, permitiendo un máximo de 15, lo que a su vez restringió el resultado máximo posible a 30, limitando así la funcionalidad del acumulador. Otro desafío surgió al cargar el código en la FPGA en un entorno Windows, donde se observó que los ceros no se mostraban correctamente; sin embargo, al realizar la carga en Linux Ubuntu, el circuito funcionó sin errores y la acumulación se realizó de manera adecuada. Asimismo, el tiempo se convirtió en un factor en contra, afectando la capacidad de realizar pruebas con el teclado y poder hacerlo funcionar. Finalmente, se identificó que algunos pines estaban configurados por defecto para emitir un 1 lógico, lo que ocasionó que el dipswitch no funcionara hasta que se reconfiguraron adecuadamente, permitiendo así su correcto funcionamiento en el sistema.

## Apendices:



